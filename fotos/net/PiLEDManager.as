package fotos.net{

	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.system.System;
	import flash.events.EventDispatcher;

	public class PiLEDManager extends EventDispatcher {

		private var _socket:PiClient;
		private var _ledConfig:XML;
		private var _ledTab:Array = new Array;

		/******
		** Access methods
		*******/

		public function get serverIP():String {
			return _ledConfig.serverinfo.ip;
		}

		public function get serverPort():uint {
			return _ledConfig.serverinfo.port;
		}

		public function get ledTab():Array {
			return _ledTab;
		}
		
		public function get connected():Boolean {
			return _socket.connected;
		}

		public function getStripByName(name:String):PiLED {
			for each (var cluster in _ledConfig.ledinfo.cluster) {
				for each (var strip in cluster.strip) {
					if(strip.@name == name)
						return new PiLED(strip.@name, strip.r, strip.v, strip.b);
				}
			}
			return null;
		}

		public function getClusterByName(name:String):Array{
			for each (var cluster in _ledConfig.ledinfo.cluster){
				if(cluster.@name == name){
					var clusterTab = new Array;
					for each (var strip in cluster.strip){
						clusterTab.push(new PiLED(strip.@name, strip.r, strip.v, strip.b));
					}
					return clusterTab;
				}
			}
			return null;
		}
		
		/******
		** Constructor
		*******/

		public function PiLEDManager(configFilePath:String = "LEDConfig.xml"):void {

			//Load the XML config file
			var xmlLoader:URLLoader = new URLLoader;
			xmlLoader.addEventListener(Event.COMPLETE, onLoad);
			xmlLoader.addEventListener(IOErrorEvent.IO_ERROR, onError);
			xmlLoader.load(new URLRequest(configFilePath));
		}

		/******
		** Methods
		*******/

		public function setColorRGB(led:PiLED, ms:uint, r:uint, g:uint, b:uint):Boolean {
			//Send data to pi
			return led != null &&
				   _socket.sendString("led " + ms + " " + led.rPin + " " + r) &&
				   _socket.sendString("led " + ms + " " + led.gPin + " " + g) &&
				   _socket.sendString("led " + ms + " " + led.bPin + " " + b);
		}


		public function setColorHex(led:PiLED, ms:uint, color:uint):Boolean {
			var rgb:Array = hex2rgb(color);
			return setColorRGB(led, ms, rgb[0], rgb[1], rgb[2]);
		}
		
		public function setClusterColorRGB(name:String, ms:uint, r:uint, g:uint, b:uint):Boolean {
			var res:Boolean = true;
			for each (var strip:PiLED in getClusterByName(name)) {
				res = setColorRGB(strip, ms, r, g, b) && res;
			}
			return res;
		}

		public function setClusterColorHex(name:String, ms:uint, color:uint):Boolean {
			var res:Boolean = true;
			for each (var strip:PiLED in getClusterByName(name)) {
				res = setColorHex(strip, ms, color) && res;
			}
			return res;
		}
		
		/******
		** Event handler
		*******/

		private function onLoad(e:Event):void {
			var xmlLoader:URLLoader = e.currentTarget as URLLoader;
			_ledConfig = new XML(xmlLoader.data);

			//Config file loaded, initialing
			_socket = new PiClient(serverIP, serverPort); //Initialise the connection to the PI
			_socket.addEventListener(Event.CLOSE, socketEventRelay);
			_socket.addEventListener(Event.CONNECT, socketEventRelay);
			//Initialise array
			for each (var cluster in _ledConfig.ledinfo.cluster) {
				var currCluster:Array = new Array;

				for each (var strip in cluster.strip) {
					currCluster.push(new PiLED(strip.@name, strip.r, strip.v, strip.b));
				}
				_ledTab.push(currCluster);
			}

			xmlLoader.removeEventListener(Event.COMPLETE, onLoad);
			xmlLoader.removeEventListener(IOErrorEvent.IO_ERROR, onError);
		}

		private function onError(e:IOErrorEvent):void {
			var xmlLoader:URLLoader = e.currentTarget as URLLoader;

			trace(e.errorID + ": " + e.text);

			xmlLoader.removeEventListener(Event.COMPLETE, onLoad);
			xmlLoader.removeEventListener(IOErrorEvent.IO_ERROR, onError);

			System.exit(0); //IO errors are fatal
		}

		private function socketEventRelay(e:Event):void {
			dispatchEvent(e);
		}

		/******
		** Static methods
		*******/

		public static function rgb2hex(r:uint, g:uint, b:uint):uint {
			return (r * 0xFFFF) + (g * 0xFF) + (b);
		}

		public static function hex2rgb(hex:uint):Array {
			var res:Array = new Array;
			res.push(( hex >> 16 ) & 0xFF);
			res.push(( hex >> 8 ) & 0xFF);
			res.push(hex & 0xFF);
			return res;
		}
	}
}