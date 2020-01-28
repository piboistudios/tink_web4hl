import tink.testrunner.Runner;
import tink.unit.TestBatch;
import tink.unit.Assert.assert;

using tink.CoreApi;

class RunTests {
	static function main() {
		Runner.run(TestBatch.make([new ClientServerTests()])).handle(res -> {
			Runner.exit(res);
		});
	}
}

class ClientServerTests {
	public var asserts = new tink.unit.AssertionBuffer();

	public function new() {}
    @:timeout(10000000)
	public function test_large_file_endpoint() {
		var input = sys.io.File.getContent("./test/fixtures/sample.txt");
		TestClient.inst.large_file(input).handle(res -> {
			switch (res) {
				case Failure(res):
					sys.io.File.saveContent("./output/large_file_error.json", haxe.Json.stringify({
						message: res.message,
						code: res.code,
						data: res.data,
						pos: res.pos,
						callStack: res.callStack,
						exceptionStack: res.exceptionStack
					}));
				case Success(res):
					var output = new haxe.io.BytesOutput();
					var outSink = tink.io.Sink.ofOutput('std-sink', output);
					res.body.pipeTo(outSink, {end: true}).handle(res -> {
						var response = output.getBytes().toString();

						asserts.assert(response == input);
						asserts.done();
					});
			}
			return false;
		});
		return asserts;
	}
}
