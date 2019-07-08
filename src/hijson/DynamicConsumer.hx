package hijson;

import haxe.DynamicAccess;
import hijson.Consumer;

class DynamicConsumer implements Consumer<Any, Array<Any>, DynamicAccess<Any>> {
	function new() {}

	public static final instance = new DynamicConsumer();

	public function consumeString(s:String):Any {
		return s;
	}

	public function consumeNumber(n:String):Any {
		var f = Std.parseFloat(n);
		var i = Std.int(f);
		return if (i == f) i else f;
	}

	public function consumeBool(b:Bool):Any {
		return b;
	}

	public function consumeNull():Any {
		return null;
	}

	public function consumeArray():Array<Any> {
		return [];
	}

	public function addArrayElement(array:Array<Any>, parser:Parser) {
		array.push(parser.parseValue(this));
	}

	public function finalizeArray(array:Array<Any>):Any {
		return array;
	}

	public function consumeObject():DynamicAccess<Any> {
		return {};
	}

	public function addObjectField(object:DynamicAccess<Any>, name:String, parser:Parser):Void {
		object.set(name, parser.parseValue(this));
	}

	public function finalizeObject(object:DynamicAccess<Any>):Any {
		return object;
	}
}
