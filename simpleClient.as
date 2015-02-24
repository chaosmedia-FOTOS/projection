package  {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import fotos.net.PiLEDManager;
	import flash.events.MouseEvent;
	import fotos.net.PiLED;
	
	
	public class Test extends MovieClip {
		public var manager:PiLEDManager;
		
		public function Test() {
			manager = new PiLEDManager; 
			manager.addEventListener(Event.CONNECT, onConnexion)
			btn_ok.addEventListener(MouseEvent.CLICK, send);
		}

		public function onConnexion(e:Event):void{
			txt_status.text = "Connecté!"
		}

		public function send(e:Event):void{
			var led:PiLED = manager.getStripByName("bar");
			manager.setColorRGB(led, uint(txt_fade.text), uint(txt_r.text), uint(txt_g.text), uint(txt_b.text));
		}
	}
	
}
