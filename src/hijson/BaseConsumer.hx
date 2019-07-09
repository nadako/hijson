package hijson;

import haxe.DynamicAccess;
import haxe.ds.Option;
import haxe.ds.StringMap;
import haxe.ds.IntMap;

import hijson.Consumer;

/**
	A convenient base class for implementing consumers.

	Implementation of every method throws an "Unexpected <JSON value type>" exception.
	The methods can then be overriden in a subclass to support parsing needed JSON values.
**/
class BaseConsumer<TResult, TArrayContext, TObjectContext> implements Consumer<TResult, TArrayContext, TObjectContext> {
	/** Complain about unexpected string **/
	public function consumeString(s:String):TResult {
		throw "Unexpected string";
	}

	/** Complain about unexpected number **/
	public function consumeNumber(n:String):TResult {
		throw "Unexpected number";
	}

	/** Complain about unexpected boolean **/
	public function consumeBool(b:Bool):TResult {
		throw "Unexpected boolean";
	}

	/** Complain about unexpected null **/
	public function consumeNull():TResult {
		throw "Unexpected null";
	}

	/**
		Complain about unexpected array.

		Note that when overriding this method, you MUST also override
		`addArrayElement` and `finalizeArray` methods.
	**/
	public function consumeArray():TArrayContext {
		throw "Unexpected array";
	}

	/** Complain about being unimplemented, see `BaseConsumer.consumeArray` **/
	public function addArrayElement(context:TArrayContext, parser:Parser):Void {
		throw "Not implemented";
	}

	/** Complain about being unimplemented, see `BaseConsumer.consumeArray` **/
	public function finalizeArray(context:TArrayContext):TResult {
		throw "Not implemented";
	}

	/**
		Complain about unexpected object.

		Note that when overriding this method, you MUST also override
		`addObjectField` and `finalizeObject` methods.
	**/
	public function consumeObject():TObjectContext {
		throw "Unexpected object";
	}

	/** Complain about being unimplemented, see `BaseConsumer.consumeObject` **/
	public function addObjectField(context:TObjectContext, name:String, parser:Parser):Void {
		throw "Not implemented";
	}

	/** Complain about being unimplemented, see `BaseConsumer.consumeObject` **/
	public function finalizeObject(context:TObjectContext):TResult {
		throw "Not implemented";
	}
}

/**
	Standard Bool consumer. Produces Haxe Bool values from JSON boolean.

	There's only a single instance of `BoolConsumer`, available via `BoolConsumer.instance`.
**/
class BoolConsumer extends BaseConsumer<Bool, Void, Void> {
	public static final instance = new BoolConsumer();
	function new() {}
	override function consumeBool(b:Bool):Bool return b;
}

/**
	Standard String consumer. Produces Haxe String values from JSON string.

	There's only a single instance of `StringConsumer`, available via `StringConsumer.instance`.
**/
class StringConsumer extends BaseConsumer<String, Void, Void> {
	public static final instance = new StringConsumer();
	function new() {}
	override function consumeString(s:String):String return s;
}

/**
	Standard Float consumer. Produces Haxe Float values from JSON number.

	There's only a single instance of `FloatConsumer`, available via `FloatConsumer.instance`.
**/
class FloatConsumer extends BaseConsumer<Float, Void, Void> {
	public static final instance = new FloatConsumer();
	function new() {}
	override function consumeNumber(n:String):Float return Std.parseFloat(n);
}

/**
	Standard Int consumer. Produces Haxe Int values from JSON number.

	Throws an exception if the JSON number is not parseable as Int.

	There's only a single instance of `IntConsumer`, available via `IntConsumer.instance`.
**/
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

/**
	Int64 consumer. Produces `haxe.Int64` values from JSON number.

	There's only a single instance of `Int64Consumer`, available via `Int64Consumer.instance`.
**/
class Int64Consumer extends BaseConsumer<haxe.Int64, Void, Void> {
	public static final instance = new Int64Consumer();
	function new() {}
	override function consumeNumber(n:String):haxe.Int64 {
		return haxe.Int64.parseString(n);
	}
}

/**
	Nullable value consumer. Produces `null` from JSON null and delegates other values consumption
	to a `Consumer` instance specified in the constructor.
**/
class NullConsumer<TResult, TArrayContext, TObjectContext> implements Consumer<Null<TResult>, TArrayContext, TObjectContext> {
	final consumer:Consumer<TResult, TArrayContext, TObjectContext>;

	/**
		Create a nullable value consumer using the given `consumer` for parsing non-null JSON values.
	**/
	public function new(consumer) {
		this.consumer = consumer;
	}

	/** Delegate processing to the consumer given to the constructor **/
	public function consumeString(s:String):Null<TResult> return consumer.consumeString(s);

	/** Delegate processing to the consumer given to the constructor **/
	public function consumeNumber(n:String):Null<TResult> return consumer.consumeNumber(n);

	/** Delegate processing to the consumer given to the constructor **/
	public function consumeBool(b:Bool):Null<TResult> return consumer.consumeBool(b);

	/** Produce the `null` value from JSON null **/
	public function consumeNull():Null<TResult> return null;

	/** Delegate processing to the consumer given to the constructor **/
	public function consumeArray():TArrayContext return consumer.consumeArray();

	/** Delegate processing to the consumer given to the constructor **/
	public function addArrayElement(context:TArrayContext, parser:Parser):Void consumer.addArrayElement(context, parser);

	/** Delegate processing to the consumer given to the constructor **/
	public function finalizeArray(context:TArrayContext):TResult return consumer.finalizeArray(context);

	/** Delegate processing to the consumer given to the constructor **/
	public function consumeObject():TObjectContext return consumer.consumeObject();

	/** Delegate processing to the consumer given to the constructor **/
	public function addObjectField(context:TObjectContext, name:String, parser:Parser):Void consumer.addObjectField(context, name, parser);

	/** Delegate processing to the consumer given to the constructor **/
	public function finalizeObject(context:TObjectContext):TResult return consumer.finalizeObject(context);

}

/**
	`haxe.ds.Option` consumer. Produces `None` from JSON null, delegates other values consumption
	to a `Consumer` instance specified in the constructor while wrapping the result in `Some`.
**/
class OptionConsumer<TResult, TArrayContext, TObjectContext> implements Consumer<Option<TResult>, TArrayContext, TObjectContext> {
	final consumer:Consumer<TResult, TArrayContext, TObjectContext>;

	/**
		Create a `haxe.ds.Option` consumer using the given `consumer` for parsing non-null JSON values.
	**/
	public function new(consumer) {
		this.consumer = consumer;
	}

	/** Delegate processing to the consumer given to the constructor and wrap the result in `Some` **/
	public function consumeString(s:String):Option<TResult> return Some(consumer.consumeString(s));

	/** Delegate processing to the consumer given to the constructor and wrap the result in `Some` **/
	public function consumeNumber(n:String):Option<TResult> return Some(consumer.consumeNumber(n));

	/** Delegate processing to the consumer given to the constructor and wrap the result in `Some` **/
	public function consumeBool(b:Bool):Option<TResult> return Some(consumer.consumeBool(b));

	/** Produce `None` value from JSON null **/
	public function consumeNull():Option<TResult> return None;

	/** Delegate processing to the consumer given to the constructor and wrap the result in `Some` **/
	public function consumeArray():TArrayContext return consumer.consumeArray();

	/** Delegate processing to the consumer given to the constructor and wrap the result in `Some` **/
	public function addArrayElement(context:TArrayContext, parser:Parser):Void consumer.addArrayElement(context, parser);

	/** Delegate processing to the consumer given to the constructor and wrap the result in `Some` **/
	public function finalizeArray(context:TArrayContext):Option<TResult> return Some(consumer.finalizeArray(context));

	/** Delegate processing to the consumer given to the constructor and wrap the result in `Some` **/
	public function consumeObject():TObjectContext return consumer.consumeObject();

	/** Delegate processing to the consumer given to the constructor and wrap the result in `Some` **/
	public function addObjectField(context:TObjectContext, name:String, parser:Parser):Void consumer.addObjectField(context, name, parser);

	/** Delegate processing to the consumer given to the constructor and wrap the result in `Some` **/
	public function finalizeObject(context:TObjectContext):Option<TResult> return Some(consumer.finalizeObject(context));
}

/**
	Standard Array consumer. Produces Haxe `Array` values from JSON arrays,
	using the `Consumer` given to its constructor for parsing array elements.
**/
class ArrayConsumer<TElement, TElementArrayContext, TElementObjectContext> extends BaseConsumer<Array<TElement>, Array<TElement>, Void> {
	final elementConsumer:Consumer<TElement, TElementArrayContext, TElementObjectContext>;

	/**
		Create a new `Array` consumer.
		The given `elementConsumer` will be used for parsing JSON array elements.
	**/
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

/**
	`haxe.DynamicAccess` consumer. Produces Haxe anonymous structures from JSON objects,
	using the `Consumer` given to its constructor for parsing object field values.
**/
class DynamicAccessConsumer<TValue, TValueArrayContext, TValueObjectContext> extends BaseConsumer<DynamicAccess<TValue>, Void, DynamicAccess<TValue>> {
	final valueConsumer:Consumer<TValue, TValueArrayContext, TValueObjectContext>;

	/**
		Create a new `haxe.DynamicAccess` consumer.
		The given `valueConsumer` will be used for parsing JSON object field values.
	**/
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

/**
	`haxe.ds.StringMap` consumer. Produces StringMap from JSON objects,
	using the `Consumer` given to its constructor for parsing field values.
**/
class StringMapConsumer<TValue, TValueArrayContext, TValueObjectContext> extends BaseConsumer<StringMap<TValue>, Void, StringMap<TValue>> {
	final valueConsumer:Consumer<TValue, TValueArrayContext, TValueObjectContext>;

	/**
		Create a new `haxe.ds.StringMap` consumer.
		The given `valueConsumer` will be used for parsing JSON object field values.
	**/
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

/**
	`haxe.ds.IntMap` consumer. Produces IntMap from JSON objects, parsing field names
	as `Int` and using the `Consumer` given to its constructor for parsing field values.

	Throws an exception if the field name cannot be parsed as `Int`.
**/
class IntMapConsumer<TValue, TValueArrayContext, TValueObjectContext> extends BaseConsumer<IntMap<TValue>, Void, IntMap<TValue>> {
	final valueConsumer:Consumer<TValue, TValueArrayContext, TValueObjectContext>;

	/**
		Create a new `haxe.ds.IntMap` consumer.
		The given `valueConsumer` will be used for parsing JSON object field values.
	**/
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
