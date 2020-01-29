package tink.io.hl;

import tink.CoreApi;
import hl.uv.Stream;

class WrappedReadStream {
	var native:Stream;
	var name:String;
	var end:Promise<Null<Chunk>>;
	var onceEnded:Callback<Null<Chunk>>;
	var chunkSize:Null<Int>;

	public function new(name, native, chunkSize, onEnd) {
		this.name = name;
		this.native = native;
		this.chunkSize = chunkSize;
		this.end = Future.async(function(cb) {
			this.onceEnded = cb;
		});
		if (onEnd != null) {
			this.end.handle(function(()) {
				onEnd();
			});
		}
	}

	public function read():Promise<Null<Chunk>> {
		return Future.async(function(cb) {
			function attempt() {
				try {
					native.readStart(function(data) switch (data) {
						case null: 
							cb(Success(null));
						case d: 
							native.readStop();
							cb(Success(tink.Chunk.ofBytes(d)));
					});
				
				} catch(e:haxe.io.Eof) {
					cb(Success(null));
				} 
				catch (e:Dynamic) {
					cb(Failure(Error.withData('Error while reading from $name', e)));
				}
			}
			attempt();
		});
	}
}
