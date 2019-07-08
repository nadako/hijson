import utest.Assert.*;

import hijson.Parser;
import hijson.BaseConsumer;

private class ConstructibleBaseConsumer extends BaseConsumer<Void, Void, Void> {
	public function new() {}
}

class TestBaseConsumer extends utest.Test {
	static final baseConsumer = new ConstructibleBaseConsumer();

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
		raises("Unexpected string", () -> baseConsumer.consumeString("hi"));
	}

	function testNumber() {
		raises("Unexpected number", () -> baseConsumer.consumeNumber("1"));
	}

	function testBool() {
		raises("Unexpected boolean", () -> baseConsumer.consumeBool(true));
	}

	function testNull() {
		raises("Unexpected null", () -> baseConsumer.consumeNull());
	}

	function testArray() {
		raises("Unexpected array", () -> baseConsumer.consumeArray());
	}

	function testObject() {
		raises("Unexpected object", () -> baseConsumer.consumeObject());
	}

	function testBoolConsumer() {
		isTrue(BoolConsumer.instance.consumeBool(true));
		isFalse(BoolConsumer.instance.consumeBool(false));
		raises("Unexpected null", () -> BoolConsumer.instance.consumeNull());
	}

	function testStringConsumer() {
		equals("hello", StringConsumer.instance.consumeString("hello"));
		raises("Unexpected null", () -> StringConsumer.instance.consumeNull());
	}

	function testFloatConsumer() {
		equals(1.5, FloatConsumer.instance.consumeNumber("1.5"));
		equals(1, FloatConsumer.instance.consumeNumber("1"));
		raises("Unexpected null", () -> FloatConsumer.instance.consumeNull());
	}

	function testIntConsumer() {
		equals(1, IntConsumer.instance.consumeNumber("1"));
		// TODO:
		// raises("Unexpected non-integer number", () -> IntConsumer.instance.consumeNumber("1.5"));
		raises("Unexpected null", () -> IntConsumer.instance.consumeNull());
	}

	function testNullConsumer() {
		var consumer = new NullConsumer(IntConsumer.instance);
		equals(1, consumer.consumeNumber("1"));
		isNull(consumer.consumeNull());
	}

	function testStandardArrayConsumer() {
		var consumer = new ArrayConsumer(IntConsumer.instance);
		same([1,2,3], Parser.parse("[1,2,3]", consumer));
		raises("Unexpected string", () -> Parser.parse('[1,2,3,"hi"]', consumer));
	}

	function testDynamicAccessConsumer() {
		var consumer = new DynamicAccessConsumer(IntConsumer.instance);
		same({a: 1, b: 2}, Parser.parse('{"a": 1, "b": 2}', consumer));
		raises("Unexpected string", () -> Parser.parse('{"a": "hi"}', consumer));
	}

	function testStringMapConsumer() {
		var consumer = new StringMapConsumer(IntConsumer.instance);
		same(["a" => 1, "b" => 2], Parser.parse('{"a": 1, "b": 2}', consumer));
		raises("Unexpected string", () -> Parser.parse('{"a": "hi"}', consumer));
	}

	function testIntMapConsumer() {
		var consumer = new IntMapConsumer(IntConsumer.instance);
		same([1 => 2, 3 => 4], Parser.parse('{"1": 2, "3": 4}', consumer));
		raises("Unexpected string", () -> Parser.parse('{"1": "hi"}', consumer));
		// TODO:
		// raises("Invalid object key for IntMap", () -> Parser.parse('{"1.5": 1}', consumer));
		raises("Invalid object key for IntMap", () -> Parser.parse('{"lol": "hi"}', consumer));
	}
}
