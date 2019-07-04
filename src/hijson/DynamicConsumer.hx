package hijson;

import hijson.Consumer;

class DynamicConsumer implements Consumer<Any> {
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

	public function consumeArray():DynamicArrayConsumer {
		return DynamicArrayConsumer.instance;
	}

	public function consumeObject():DynamicObjectConsumer {
		return DynamicObjectConsumer.instance;
	}
}


class DynamicArrayConsumer implements ArrayConsumer<Any> {
	var currentArray:Null<Array<Any>>;
	function new() {}

	public static final instance = new DynamicArrayConsumer();

	public function addElement(parser:Parser) {
		if (currentArray == null) currentArray = [];
		currentArray.push(parser.parseValue(DynamicConsumer.instance));
	}

	public function complete():Any {
		var result = currentArray;
		currentArray = null;
		return result;
	}
}

class DynamicObjectConsumer implements ObjectConsumer<Any> {
	var currentObject:Null<haxe.DynamicAccess<Any>>;
	function new() {}

	public static final instance = new DynamicObjectConsumer();

	public function addField(name:String, parser:Parser):Void {
		if (currentObject == null) currentObject = {};
		currentObject.set(name, parser.parseValue(DynamicConsumer.instance));
	}

	public function complete():Any {
		var result = currentObject;
		currentObject = null;
		return result;
	}
}
