import utest.Assert.*;

import hijson.DynamicConsumer.instance as consumer;

class TestDynamicConsumer extends utest.Test {
	function testString() {
		equals("hello", hijson.Parser.parse('"hello"', consumer));
	}

	function testNumber() {
		var v = hijson.Parser.parse('123', consumer);
		equals(123, v);
		isTrue(Std.is(v, Int));

		v = hijson.Parser.parse('123.5', consumer);
		equals(123.5, v);
		isTrue(Std.is(v, Float));
	}

	function testBool() {
		isTrue(hijson.Parser.parse('true', consumer));
		isFalse(hijson.Parser.parse('false', consumer));
	}

	function testNull() {
		isNull(hijson.Parser.parse('null', consumer));
	}

	function testArray() {
		same(["hi", 1], hijson.Parser.parse('["hi", 1]', consumer));
	}

	function testObject() {
		same({a: "hi", b: 1}, hijson.Parser.parse('{"a": "hi", "b": 1}', consumer));
	}
}
