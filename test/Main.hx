class Main {
	static function main() utest.UTest.run([
		new TestParser(),
		new TestDynamicConsumer(),
		new TestBaseConsumer(),
	]);
}
