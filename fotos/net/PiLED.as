package fotos.net {
		
	public class PiLED {
		
		private var _name:String
		private var _rPin:uint;
		private var _gPin:uint;
		private var _bPin:uint;

		public function get name():String {
			return _name;
		}
		
		public function get rPin():uint {
			return _rPin;
		}

		public function get gPin():uint {
			return _gPin;
		}

		public function get bPin():uint {
			return _bPin;
		}

		public function PiLED(n:String, r:uint, g:uint, b:uint) {
			_name = n;
			_rPin = r;
			_gPin = g;
			_bPin = b;
		}
	}
}