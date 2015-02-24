package {
	
import flash.display.Sprite;
import flash.events.Event;
import flash.events.ProgressEvent;
import flash.net.Socket;

	public class Main extends Sprite{

		private var _socket:Socket;

		public function Main():void {
			_socket = new Socket;

			_socket.addEventListener(Event.CLOSE, onClose);
			_socket.addEventListener(Event.CONNECT, onConnect);
			_socket.addEventListener(ProgressEvent.SOCKET_DATA, onReceive);

			_socket.connect("localhost", 8888);
		}

		private function onClose(e:Event):void {
			trace("Déconnecté du serveur");
		}


		private function onConnect(e:Event):void {
			trace("Connecté au serveur");

			var chaine = "Hello world";
			trace("Envoyé: " + chaine);
			_socket.writeUTFBytes(chaine);
			_socket.flush();
		}


		private function onReceive(e:ProgressEvent):void {
			trace("Reçus: " + _socket.readUTFBytes(_socket.bytesAvailable));
		}

	}
}