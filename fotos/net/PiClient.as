package fotos.net {

import flash.errors.IOError;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.events.ProgressEvent;
import flash.net.Socket;
import flash.events.TimerEvent;
import flash.utils.Timer;
import flash.system.Security;

	internal class PiClient extends Socket {
		
		private var _server:String;
		private var _port:uint;
		private var retryTimer:Timer;

		/******
		** Constructor
		*******/

		public function PiClient(server:String = "localhost", port:uint = 8888):void {
			super();
			
			_server = server;
			_port = port;
			
			init();
		}

		public function sendString(data:String):Boolean {
			if(!connected)
				return false;
			
			data += "\n" //Separator, incase data is sent in a single packet
			try{
				trace("Sending: " + data);
				
				//Write data in Socket
				writeUTFBytes(data);

				//Send it
				flush();
			}
			catch(e:IOError){
				trace(e);
				return false;
			}
			
			return true;
		}

		private function init():void {
			//Create all event listener
			addEventListener(Event.CLOSE, onClose);
			addEventListener(Event.CONNECT, onConnect);
			addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			addEventListener(ProgressEvent.SOCKET_DATA, onReceive);
			
			//Timer for retrying connexion
			retryTimer = new Timer(timeout);
			retryTimer.addEventListener(TimerEvent.TIMER, connectToServer);
			retryTimer.start();
			connectToServer();

			//Policy file setting
			Security.loadPolicyFile("xmlsocket://" + _server + ":" + _port);
		}

		private function connectToServer(e:TimerEvent = null):void {
			//Code to connect to pi
			trace("Attempting to connect to " + _server + ":" +_port + " ...");
			try{
				connect(_server, _port);
			}
			catch(e:Error){
				trace(e);
			}
		}

		/******
		** Event handler
		*******/

		private function onClose(e:Event):void {
			trace("Closing socket");
			retryTimer.start();
			connectToServer();
		}

		private function onConnect(e:Event):void {
			trace("Connexion established");
			retryTimer.stop();
			sendString("info begin");
		}

		private function onIOError(e:IOErrorEvent):void {
			trace("IOErrorEvent: " + e);
		}

		private function onSecurityError(e:SecurityErrorEvent):void {
			trace("SecurityErrorEvent: " + e);
		}

		private function onReceive(e:ProgressEvent):void {
			trace("Received: ");
			trace(readUTFBytes(bytesAvailable));
		}
	}
}