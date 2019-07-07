package hijson;

import haxe.DynamicAccess;
import haxe.ds.StringMap;
import haxe.ds.IntMap;

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

class BoolConsumer extends BaseConsumer<Bool> {
	public static final instance = new BoolConsumer();
	override function consumeBool(b:Bool):Bool return b;
}

class StringConsumer extends BaseConsumer<String> {
	public static final instance = new StringConsumer();
	override function consumeString(s:String):String return s;
}

class FloatConsumer extends BaseConsumer<Float> {
	public static final instance = new FloatConsumer();
	override function consumeNumber(n:String):Float return Std.parseFloat(n);
}

class IntConsumer extends BaseConsumer<Int> {
	public static final instance = new IntConsumer();
	override function consumeNumber(n:String):Int {
		return switch Std.parseInt(n) {
			case null: throw "Unexpected non-integer number";
			case i: i;
		}
	}
}

class NullConsumer<T> implements Consumer<Null<T>> {
	final consumer:Consumer<T>;

	public function new(consumer) {
		this.consumer = consumer;
	}

	public function consumeString(s:String):Null<T> return consumer.consumeString(s);
	public function consumeNumber(n:String):Null<T> return consumer.consumeNumber(n);
	public function consumeBool(b:Bool):Null<T> return consumer.consumeBool(b);
	public function consumeNull():Null<T> return null;
	public function consumeArray():ArrayConsumer<Null<T>> return consumer.consumeArray();
	public function consumeObject():ObjectConsumer<Null<T>> return consumer.consumeObject();
}

class StandardArrayConsumer<T> extends BaseConsumer<Array<T>> implements ArrayConsumer<Array<T>> {
	final elementConsumer:Consumer<T>;
	var currentArray:Null<Array<T>>;

	public function new(elementConsumer) {
		super();
		this.elementConsumer = elementConsumer;
	}

	override function consumeArray():ArrayConsumer<Array<T>> return this;

	public function addElement(parser:Parser):Void {
		if (currentArray == null) currentArray = [];
		currentArray.push(parser.parseValue(elementConsumer));
	}

	public function complete():Array<T> {
		var result = currentArray;
		currentArray = null;
		return result;
	}
}

class DynamicAccessConsumer<T> extends BaseConsumer<DynamicAccess<T>> implements ObjectConsumer<DynamicAccess<T>> {
	final valueConsumer:Consumer<T>;
	var currentObject:Null<DynamicAccess<T>>;

	public function new(valueConsumer) {
		super();
		this.valueConsumer = valueConsumer;
	}

	override function consumeObject():ObjectConsumer<DynamicAccess<T>> return this;

	public function addField(name:String, parser:Parser):Void {
		if (currentObject == null) currentObject = {};
		currentObject.set(name, parser.parseValue(valueConsumer));
	}

	public function complete():DynamicAccess<T> {
		var result = currentObject;
		currentObject = null;
		return result;
	}
}

class StringMapConsumer<T> extends BaseConsumer<StringMap<T>> implements ObjectConsumer<StringMap<T>> {
	final valueConsumer:Consumer<T>;
	var currentObject:Null<StringMap<T>>;

	public function new(valueConsumer) {
		super();
		this.valueConsumer = valueConsumer;
	}

	override function consumeObject():ObjectConsumer<StringMap<T>> return this;

	public function addField(name:String, parser:Parser):Void {
		if (currentObject == null) currentObject = new StringMap<T>();
		currentObject.set(name, parser.parseValue(valueConsumer));
	}

	public function complete():StringMap<T> {
		var result = currentObject;
		currentObject = null;
		return result;
	}
}

class IntMapConsumer<T> extends BaseConsumer<IntMap<T>> implements ObjectConsumer<IntMap<T>> {
	final valueConsumer:Consumer<T>;
	var currentObject:Null<IntMap<T>>;

	public function new(valueConsumer) {
		super();
		this.valueConsumer = valueConsumer;
	}

	override function consumeObject():ObjectConsumer<IntMap<T>> return this;

	public function addField(name:String, parser:Parser):Void {
		var key = Std.parseInt(name);
		if (key == null) throw "Invalid object key for IntMap";
		if (currentObject == null) currentObject = new IntMap<T>();
		currentObject.set(key, parser.parseValue(valueConsumer));
	}

	public function complete():IntMap<T> {
		var result = currentObject;
		currentObject = null;
		return result;
	}
}
