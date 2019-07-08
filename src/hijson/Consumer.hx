package hijson;

interface Consumer<TResult, TArrayContext, TObjectContext> {
	function consumeString(s:String):TResult;
	function consumeNumber(n:String):TResult;
	function consumeBool(b:Bool):TResult;
	function consumeNull():TResult;
	function consumeArray():TArrayContext;
	function addArrayElement(context:TArrayContext, parser:Parser):Void;
	function finalizeArray(context:TArrayContext):TResult;
	function consumeObject():TObjectContext;
	function addObjectField(context:TObjectContext, name:String, parser:Parser):Void;
	function finalizeObject(context:TObjectContext):TResult;
}
