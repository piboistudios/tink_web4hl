package;

import tink.http.containers.*;
import tink.http.Response;
import tink.web.routing.*;
import tink.streams.Stream;
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
		var container = new #if hxnodejs NodeContainer(8080) #else TcpContainer(HlAcceptor.inst.bind2.bind(8080)) #end;
		// var container =  PhpContainer.inst; //use PhpContainer instead of NodeContainer when targeting PHP
		var router = new Router<Root>(new Root());
		container.run(function(req) {
			return router.route(Context.ofRequest(req)).recover(OutgoingResponse.reportError);
		}).handle(noop);
		trace("Listening at http://localhost:8080");
	}
}

typedef TestPayload = {
	var name:String;
	var job:String;
	var age:Int;
};

class Root {
	public function new() {}

	@:post('/test-upload')
	
	public function upload(body:{ datafile1: tink.web.forms.FormFile }) {
		final file = body.datafile1;
		trace('upload?');
		return file.saveTo('./${file.fileName}').flatMap(_ -> {
			trace('Saved ${file.fileName} (${file.mimeType}, ${file.size})');
			return Noise;
		});
	}

	@:post('/large-file')
	public function large_file(body:RealSource) {
		var output = new haxe.io.BytesOutput();
		var outSink = Sink.ofOutput('some-new-sink', output);
		var response = Future.trigger();
		var chunks = [];
		trace(body);
		body.pipeTo(outSink).handle(res -> {
			var text = output.getBytes().toString();
			response.trigger(text);
			sys.io.File.saveContent("./output/response.out", text);
		});
		trace("Responding.");
		return response;
	}

	@:post('/xml')
	public function xml(body:String) {
		trace(body);
		final data = new haxe.xml.Access(Xml.parse(body).firstElement());
		return haxe.Json.stringify({
			name: data.node.Name.innerData,
			age: data.node.Age.innerData,
			job: data.node.Job.innerData
		});
	}

	@:get("/test-xml-parser")
	public function test_xml_parser() {
		final xml = '<Entity>
		<Name>Gabriel</Name>
		<Job>Software Engineer</Job>
		<Age>23</Age>
	</Entity>';
		var parsed = new tink.xml.Structure<{
			var name:String;
			var job:String;
			var age:Int;
		}>().read(xml).sure();
		return haxe.Json.stringify(parsed);
	}

	@:get('/')

	// @:get('/$name')
	public function hello() {
		trace("Hello");
		return 'Hello!';
	}
}
