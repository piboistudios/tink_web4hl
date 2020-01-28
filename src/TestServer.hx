package;

import tink.http.containers.*;
import tink.http.Response;
import tink.web.routing.*;
import tink.io.Source;
import tink.io.Sink;
#if hl
import tink.tcp.hl.HlAcceptor;
#end

using tink.io.Source;
using tink.CoreApi;

class TestServer {
	static var noop = () -> {};

	static function main() {
		var container = new #if hxnodejs  NodeContainer(8080) #else TcpContainer(HlAcceptor.inst.bind.bind(8080))#end;
		// var container =  PhpContainer.inst; //use PhpContainer instead of NodeContainer when targeting PHP
		var router = new Router<Root>(new Root());
		container.run(function(req) {
			return router.route(Context.ofRequest(req)).recover(OutgoingResponse.reportError);
		}).handle(noop);
		trace("Listening at http://localhost:8080");
	}
}

	class Root {
		public function new() {}

		@:post('/large-file')
		public function large_file(body:RealSource) {
			var output = new haxe.io.BytesOutput();
			var outSink = Sink.ofOutput('some-new-sink', output);
			var response = Future.trigger();
			body.pipeTo(outSink).handle(res -> {
				var text = output.getBytes().toString();
				response.trigger(text);
				sys.io.File.saveContent("./output/response.out", text);
			});
			trace("Responding.");
			return response;
		}

		@:get('/')

		// @:get('/$name')
		public function hello() {
			trace("Hello");
			return 'Hello!';
		}
	}
