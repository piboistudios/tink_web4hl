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
				haxe.Timer.delay(() -> onEnd(), 0);
			});
		}
	}

	public function read():Promise<Null<Chunk>> {
		return Future.async(cb -> {
			function attempt() {
				try {

					native.readStart(data -> switch(data) {
						case null: cb(Success(tink.Chunk.EMPTY));
						case d: cb(Success(tink.Chunk.ofBytes(d)));
					});
				}
				catch (e:Dynamic) {
					cb(Failure(Error.withData('Error while reading from $name', e)));
				}
			}
			attempt();
		}).first(this.end);
	}
}
