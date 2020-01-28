package;

import tink.http.clients.*;
import tink.web.proxy.Remote;
import tink.io.Source;
import tink.io.Sink;
import tink.url.Host;
import tink.CoreApi;

class TestClient {
	public static var inst = new Remote<Root>(new StdClient(), new RemoteEndpoint(new Host('127.0.0.1', 8080)));
}

interface Root {
	@:post('/large-file')
	function large_file(body:String):String;

	@:get('/')
	function hello():String;
}
