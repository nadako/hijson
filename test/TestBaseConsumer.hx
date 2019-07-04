import utest.Assert.*;

import hijson.BaseConsumer;

class TestBaseConsumer extends utest.Test {
	static final consumer = new BaseConsumer();

	static function raises(expectedError:Any, func:()->Void, ?pos:haxe.PosInfos) {
		try {
			func();
		} catch (e:Any) {
			same(expectedError, e);
			return;
		}
		fail("no exception raised", pos);
	}

	function testString() {
		raises("Unexpected string", () -> consumer.consumeString("hi"));
	}

	function testNumber() {
		raises("Unexpected number", () -> consumer.consumeNumber("1"));
	}

	function testBool() {
		raises("Unexpected boolean", () -> consumer.consumeBool(true));
	}

	function testNull() {
		raises("Unexpected null", () -> consumer.consumeNull());
	}

	function testArray() {
		raises("Unexpected array", () -> consumer.consumeArray());
	}

	function testObject() {
		raises("Unexpected object", () -> consumer.consumeObject());
	}
}
