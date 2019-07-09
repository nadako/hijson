package hijson;

/**
	A JSON consumer that takes a parsed JSON value and
	produces desired Haxe value out of it. A `Consumer` instance
	has to be passed to the `Parser` methods.

	It has three type parameters:

	 - `TResult` - the type of the result, produced by this consumer
	 - `TArrayContext` - JSON array parsing context (see `Consumer.consumeArray`)
	 - `TObjectContext` - JSON object parsing context (see `Consumer.consumeObject`)
**/
interface Consumer<TResult, TArrayContext, TObjectContext> {
	/**
		Consume a JSON string and produce the result value.
	**/
	function consumeString(s:String):TResult;

	/**
		Consume a JSON number and produce the result value.

		Number is passed as a string, because JSON defines no restrictions
		about the number precision and one is free to parse it into any type (e.g. haxe.Int64).
	**/
	function consumeNumber(n:String):TResult;

	/**
		Consume a JSON boolean and produce the result value.
	**/
	function consumeBool(b:Bool):TResult;

	/**
		Consume a JSON null and produce the result value.
	**/
	function consumeNull():TResult;

	/**
		Start consuming the JSON array. This is called when parser encounters the `[` symbol.

		This method should return the "array context", which will be passed over
		to `addArrayElement` and `finalizeArray` while parsing the array.
	**/
	function consumeArray():TArrayContext;

	/**
		Add an array element. This is called when parser is about to parse the next array element.

		The `context` is the value returned by the `consumeArray` method.
		This method MUST call `parser.parseValue` ONCE with some `Consumer` instance and can use its
		return value to modify the `context` (e.g. push the value to the Array).
	**/
	function addArrayElement(context:TArrayContext, parser:Parser):Void;

	/**
		Finalize the JSON array and produce the result value.
		This is called when parser encounters the `]` symbol.

		The `context` is the value returned by the `consumeArray` method.
	**/
	function finalizeArray(context:TArrayContext):TResult;

	/**
		Start consuming the JSON object. This is called when parser encounters the `{` symbol.

		This method should return the "object context", which will be passed over
		to `addObjectField` and `finalizeObject` while parsing the object.
	**/
	function consumeObject():TObjectContext;

	/**
		Add an object field. This is called when parser is about to parse the next object field.

		The `context` is the value returned by the `consumeObject` method.
		This method MUST call `parser.parseValue` ONCE with some `Consumer` instance and can use its
		return value to modify the `context` (e.g. store the value in an object field).
	**/
	function addObjectField(context:TObjectContext, name:String, parser:Parser):Void;

	/**
		Finalize the JSON object and produce the result value.
		This is called when parser encounters the `}` symbol.

		The `context` is the value returned by the `consumeObject` method.
	**/
	function finalizeObject(context:TObjectContext):TResult;
}
