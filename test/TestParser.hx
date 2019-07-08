import utest.Assert.*;

import hijson.Consumer;
import hijson.Parser;

class TestParser extends utest.Test {
	static final consumer = new TestConsumer();

	function testString() {
		equals("<string>hello", hijson.Parser.parse('"hello"', consumer));
	}

	function testNumber() {
		equals("<number>123", hijson.Parser.parse('123', consumer));
	}

	function testBool() {
		equals("<bool>true", hijson.Parser.parse('true', consumer));
		equals("<bool>false", hijson.Parser.parse('false', consumer));
	}

	function testNull() {
		equals("<null>", hijson.Parser.parse('null', consumer));
	}

	function testArray() {
		equals("<array><string>hi,<number>1", hijson.Parser.parse('["hi", 1]', consumer));
	}

	function testObject() {
		equals("<object>a:<string>hi,b:<number>1", hijson.Parser.parse('{"a": "hi", "b": 1}', consumer));
	}
}

private class TestConsumer implements Consumer<String, Array<String>, Array<{key:String, value:String}>> {
	public function new() {}

	public function consumeString(s:String):String {
		return "<string>" + s;
	}

	public function consumeNumber(n:String):String {
		return "<number>" + n;
	}

	public function consumeBool(b:Bool):String {
		return "<bool>" + (if (b) "true" else "false");
	}

	public function consumeNull():String {
		return "<null>";
	}

	public function consumeArray():Array<String> {
		return [];
	}

	public function addArrayElement(acc:Array<String>, parser:Parser) {
		acc.push(parser.parseValue(this));
	}

	public function finalizeArray(acc:Array<String>):String {
		return "<array>" + acc.join(",");
	}

	public function consumeObject():Array<{key:String, value:String}> {
		return [];
	}

	public function addObjectField(acc:Array<{key:String, value:String}>, name:String, parser:Parser) {
		acc.push({key: name, value: parser.parseValue(this)});
	}
	public function finalizeObject(acc:Array<{key:String, value:String}>):String {
		var buf = new StringBuf(), first = true;
		for (item in acc) {
			if (first) first = false else buf.add(",");
			buf.add(item.key);
			buf.add(":");
			buf.add(item.value);
		}
		return "<object>" + buf.toString();
	}
}
