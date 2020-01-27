package tink.tcp.hl;

import tink.tcp.OpenPort;
import hl.uv.Tcp;
import tink.io.hl.*;
import sys.net.*;
using tink.io.Source;
using tink.io.Sink;
using tink.CoreApi;

class HlAcceptor {
	static public var inst(default, null):HlAcceptor = new HlAcceptor();

	function new() {}

	public function bind(?port:Int):Promise<OpenPort> {
        return Future.async(cb -> {
            var s = new SignalTrigger<Session>();
            var server = new Tcp();
            server.bind( new Host("127.0.0.1"), port != null ? port : 8080);
            server.listen(10, () -> {
                var cnx = server.accept();
                var from:Endpoint = {
                    host: "dummy",
                    port: 0
                };
                var to:Endpoint = {
                    host: "localhost",
                    port: port
                };
                var closed = Future.trigger();
                var stream = HlSource.wrap('Inbound s tream from $to', cnx, 32,  closed.trigger.bind(Noise));
                s.trigger({
                    sink: cast HlSink.wrap('Outbound stream to $from', cnx),
                    incoming: {from: from, to: to, stream: stream, closed: closed},
                    destroy: () -> {
                        cnx.close(() -> {
                            
                        });
                    }
                });
                
            });
            haxe.Timer.delay(() -> {
                var res = Success(new OpenPort(s, 8080));
                cb(res);
                trace(res);
            }, 0);
            
        });
	}
}
