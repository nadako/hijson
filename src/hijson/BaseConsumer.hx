package hijson;

import haxe.DynamicAccess;
import haxe.ds.StringMap;
import haxe.ds.IntMap;

import hijson.Consumer;

class BaseConsumer<TResult, TArrayContext, TObjectContext> implements Consumer<TResult, TArrayContext, TObjectContext> {
	public function consumeString(s:String):TResult {
		throw "Unexpected string";
	}

	public function consumeNumber(n:String):TResult {
		throw "Unexpected number";
	}

	public function consumeBool(b:Bool):TResult {
		throw "Unexpected boolean";
	}

	public function consumeNull():TResult {
		throw "Unexpected null";
	}

	public function consumeArray():TArrayContext {
		throw "Unexpected array";
	}

	public function addArrayElement(context:TArrayContext, parser:Parser):Void {
		throw "Not implemented";
	}

	public function finalizeArray(context:TArrayContext):TResult {
		throw "Not implemented";
	}

	public function consumeObject():TObjectContext {
		throw "Unexpected object";
	}

	public function addObjectField(context:TObjectContext, name:String, parser:Parser):Void {
		throw "Not implemented";
	}

	public function finalizeObject(context:TObjectContext):TResult {
		throw "Not implemented";
	}
}

class BoolConsumer extends BaseConsumer<Bool, Void, Void> {
	public static final instance = new BoolConsumer();
	function new() {}
	override function consumeBool(b:Bool):Bool return b;
}

class StringConsumer extends BaseConsumer<String, Void, Void> {
	public static final instance = new StringConsumer();
	function new() {}
	override function consumeString(s:String):String return s;
}

class FloatConsumer extends BaseConsumer<Float, Void, Void> {
	public static final instance = new FloatConsumer();
	function new() {}
	override function consumeNumber(n:String):Float return Std.parseFloat(n);
}

class IntConsumer extends BaseConsumer<Int, Void, Void> {
	public static final instance = new IntConsumer();
	function new() {}
	override function consumeNumber(n:String):Int {
		return switch Std.parseInt(n) {
			case null: throw "Unexpected non-integer number";
			case i: i;
		}
	}
}

class NullConsumer<TResult, TArrayContext, TObjectContext> implements Consumer<Null<TResult>, TArrayContext, TObjectContext> {
	final consumer:Consumer<TResult, TArrayContext, TObjectContext>;

	public function new(consumer) {
		this.consumer = consumer;
	}

	public function consumeString(s:String):Null<TResult> return consumer.consumeString(s);
	public function consumeNumber(n:String):Null<TResult> return consumer.consumeNumber(n);
	public function consumeBool(b:Bool):Null<TResult> return consumer.consumeBool(b);
	public function consumeNull():Null<TResult> return null;
	public function consumeArray():TArrayContext return consumer.consumeArray();
	public function addArrayElement(context:TArrayContext, parser:Parser):Void consumer.addArrayElement(context, parser);
	public function finalizeArray(context:TArrayContext):TResult return consumer.finalizeArray(context);
	public function consumeObject():TObjectContext return consumer.consumeObject();
	public function addObjectField(context:TObjectContext, name:String, parser:Parser):Void consumer.addObjectField(context, name, parser);
	public function finalizeObject(context:TObjectContext):TResult return consumer.finalizeObject(context);
}

class ArrayConsumer<TElement, TElementArrayContext, TElementObjectContext> extends BaseConsumer<Array<TElement>, Array<TElement>, Void> {
	final elementConsumer:Consumer<TElement, TElementArrayContext, TElementObjectContext>;

	public function new(elementConsumer) {
		this.elementConsumer = elementConsumer;
	}

	override function consumeArray():Array<TElement> {
		return [];
	}

	override function addArrayElement(array:Array<TElement>, parser:Parser):Void {
		array.push(parser.parseValue(elementConsumer));
	}

	override function finalizeArray(array:Array<TElement>):Array<TElement> {
		return array;
	}
}

class DynamicAccessConsumer<TValue, TValueArrayContext, TValueObjectContext> extends BaseConsumer<DynamicAccess<TValue>, Void, DynamicAccess<TValue>> {
	final valueConsumer:Consumer<TValue, TValueArrayContext, TValueObjectContext>;

	public function new(valueConsumer) {
		this.valueConsumer = valueConsumer;
	}

	override function consumeObject():DynamicAccess<TValue> {
		return {};
	}

	override function addObjectField(object:DynamicAccess<TValue>, name:String, parser:Parser):Void {
		object.set(name, parser.parseValue(valueConsumer));
	}

	override function finalizeObject(object:DynamicAccess<TValue>):DynamicAccess<TValue> {
		return object;
	}
}

class StringMapConsumer<TValue, TValueArrayContext, TValueObjectContext> extends BaseConsumer<StringMap<TValue>, Void, StringMap<TValue>> {
	final valueConsumer:Consumer<TValue, TValueArrayContext, TValueObjectContext>;

	public function new(valueConsumer) {
		this.valueConsumer = valueConsumer;
	}

	override function consumeObject():StringMap<TValue> {
		return new StringMap();
	}

	override function addObjectField(object:StringMap<TValue>, name:String, parser:Parser):Void {
		object.set(name, parser.parseValue(valueConsumer));
	}

	override function finalizeObject(object:StringMap<TValue>):StringMap<TValue> {
		return object;
	}
}

class IntMapConsumer<TValue, TValueArrayContext, TValueObjectContext> extends BaseConsumer<IntMap<TValue>, Void, IntMap<TValue>> {
	final valueConsumer:Consumer<TValue, TValueArrayContext, TValueObjectContext>;

	public function new(valueConsumer) {
		this.valueConsumer = valueConsumer;
	}

	override function consumeObject():IntMap<TValue> {
		return new IntMap();
	}

	override function addObjectField(object:IntMap<TValue>, name:String, parser:Parser):Void {
		var key = Std.parseInt(name);
		if (key == null) throw "Invalid object key for IntMap";
		object.set(key, parser.parseValue(valueConsumer));
	}

	override function finalizeObject(object:IntMap<TValue>):IntMap<TValue> {
		return object;
	}
}
