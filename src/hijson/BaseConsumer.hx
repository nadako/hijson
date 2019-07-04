package hijson;

import hijson.Consumer;

class BaseConsumer<T> implements Consumer<T> {
	public function new() {}

	public function consumeString(s:String):T {
		throw "Unexpected string";
	}

	public function consumeNumber(n:String):T {
		throw "Unexpected number";
	}

	public function consumeBool(b:Bool):T {
		throw "Unexpected boolean";
	}

	public function consumeNull():T {
		throw "Unexpected null";
	}

	public function consumeArray():ArrayConsumer<T> {
		throw "Unexpected array";
	}

	public function consumeObject():ObjectConsumer<T> {
		throw "Unexpected object";
	}
}
