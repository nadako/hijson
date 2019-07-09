package hijson;

import haxe.DynamicAccess;
import hijson.Consumer;

/**
	Dynamic consumer copies the behaviour of `haxe.format.JsonParser`
	except that the result type is `Any`, rather than `Dynamic`.

	JSON objects are parsed into Haxe anonymous structures
	and JSON arrays are parsed into `Array<Any>` instances.

	There's only a single instance of DynamicConsumer,
	accessible via `DynamicConsumer.instance`.
**/
class DynamicConsumer implements Consumer<Any, Array<Any>, DynamicAccess<Any>> {
	function new() {}

	public static final instance = new DynamicConsumer();

	@:dox(hide)
	public function consumeString(s:String):Any {
		return s;
	}

	@:dox(hide)
	public function consumeNumber(n:String):Any {
		var f = Std.parseFloat(n);
		var i = Std.int(f);
		return if (i == f) i else f;
	}

	@:dox(hide)
	public function consumeBool(b:Bool):Any {
		return b;
	}

	@:dox(hide)
	public function consumeNull():Any {
		return null;
	}

	@:dox(hide)
	public function consumeArray():Array<Any> {
		return [];
	}

	@:dox(hide)
	public function addArrayElement(array:Array<Any>, parser:Parser) {
		array.push(parser.parseValue(this));
	}

	@:dox(hide)
	public function finalizeArray(array:Array<Any>):Any {
		return array;
	}

	@:dox(hide)
	public function consumeObject():DynamicAccess<Any> {
		return {};
	}

	@:dox(hide)
	public function addObjectField(object:DynamicAccess<Any>, name:String, parser:Parser):Void {
		object.set(name, parser.parseValue(this));
	}

	@:dox(hide)
	public function finalizeObject(object:DynamicAccess<Any>):Any {
		return object;
	}
}
