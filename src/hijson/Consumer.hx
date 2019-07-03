package hijson;

interface Consumer<T> {
	function consumeString(s:String):T;
	function consumeNumber(n:String):T;
	function consumeBool(b:Bool):T;
	function consumeNull():T;
	function consumeArray():ArrayConsumer<T>;
	function consumeObject():ObjectConsumer<T>;
}

interface ArrayConsumer<T> {
	function addElement(parser:Parser):Void;
	function complete():T;
}

interface ObjectConsumer<T> {
	function addField(name:String, parser:Parser):Void;
	function complete():T;
}
