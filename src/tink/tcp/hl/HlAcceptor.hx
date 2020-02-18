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

	public function bind2(port:Int):Promise<OpenPort>
		return Future.async(cb -> {
			var s = new SignalTrigger<Session>();
			tink.tcp.Server.bind(port).handle(o -> switch (o) {
				case Success(server):
					server.connected.handle(cnx -> {
						var closeTrigger = Future.trigger();
						var closed = closeTrigger.asFuture();
						var onClosed = cnx -> {
							closeTrigger.trigger(Noise);
						};
						@:privateAccess cnx.onClose = onClosed;
						s.trigger({
							sink: cnx.sink,
							incoming: {
								from: cnx.peer,
								to: {
									host: "127.0.0.1",
									port: port
								},
								stream: cnx.source,
								closed: closed
							},
							destroy: () -> {
								cnx.close();
								return;
							}
						});
					});
				case Failure(e): cb(Failure(e));
			});
			cb(Success(new OpenPort(s, port)));
		});

	public function bind(?_port:Int):Promise<OpenPort> {
		return Future.async(cb -> {
			var s = new SignalTrigger<Session>();
			var port = _port != null ? _port : 8080;
			var server = new Tcp();
			server.bind(new Host("127.0.0.1"), port);
			server.listen(10, () -> {
				var cnx = server.accept();
				var from:Endpoint = {
					host: "127.0.0.1",
					port: port
				};
				var to:Endpoint = {
					host: "127.0.0.1",
					port: port
				};
				var closed = Future.trigger();
				var stream = HlSource.wrap('Inbound s tream from $to', cnx, null, closed.trigger.bind(Noise));
				s.trigger({
					sink: cast HlSink.wrap('Outbound stream to $from', cnx),
					incoming: {
						from: from,
						to: to,
						stream: stream,
						closed: closed
					},
					destroy: () -> {
						cnx.readStop();
						cnx.close(() -> {});
					}
				});
			});
			haxe.Timer.delay(() -> {
				var res = Success(new OpenPort(s, port));
				cb(res);
			}, 0);
		});
	}
}
