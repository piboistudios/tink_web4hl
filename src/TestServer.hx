package;
import tink.http.containers.*;
import tink.http.Response;
import tink.web.routing.*;
import tink.tcp.hl.HlAcceptor;
class TestServer {
	static var noop = () -> {};
    static function main() {
        var container = new TcpContainer(HlAcceptor.inst.bind.bind(8080)); 
        //var container =  PhpContainer.inst; //use PhpContainer instead of NodeContainer when targeting PHP
        var router = new Router<Root>(new Root());
        container.run(function(req) {
            return router.route(Context.ofRequest(req))
                .recover(OutgoingResponse.reportError);
		}).handle(noop);
		trace("Listening at http://localhost:8080");
		
    }
}

class Root {
    public function new() {}

    @:get('/')
    @:get('/$name')
    public function hello(name = 'World')
        return 'Hello, $name!';
}

