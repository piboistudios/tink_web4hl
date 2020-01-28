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
		this.end = Future.async(cb -> {
			this.onceEnded = cb;
		});
		if (onEnd != null) {
			this.end.handle(() -> {
				onEnd();
			});
		}
	}

	public function read():Promise<Null<Chunk>> {
		trace("Read");
		return Future.async(cb -> {
			function attempt() {
				try {
					native.readStart(data -> switch (data) {
						case null: 
							trace("=========================END READ")
							cb(Success(null));
						case d: cb(Success(tink.Chunk.ofBytes(d)));
					});
				} catch (e:Dynamic) {
					cb(Failure(Error.withData('Error while reading from $name', e)));
				}
			}
			attempt();
		});
	}
}
