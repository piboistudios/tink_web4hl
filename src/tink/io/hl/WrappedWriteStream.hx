package tink.io.hl;

import hl.uv.Stream;
import tink.Chunk;

using tink.CoreApi;

class WrappedWriteStream {
	var ended:Promise<Bool>;
	var endTrigger:FutureTrigger<Outcome<Bool, tink.core.Error>>;
	var onEnd:Callback<Bool>;
	var native:Stream;
	var name:String;
	var closed:Bool;

	public function new(name, native) {
		this.name = name;
		this.native = native;
		this.endTrigger = Future.trigger();
		this.ended = this.endTrigger.asFuture();
	}

	public function end():Promise<Bool> {
		var didEnd = false;
		this.ended.handle(() -> {
			didEnd = true;
		});

		if (didEnd) {
			return false;
		}
		native.close(() -> {
			this.endTrigger.trigger(Success(false));
		});

		return this.ended.map(_ -> true);
	}

	public function write(chunk:Chunk):Promise<Bool> {
		return Future.async(cb -> {
			if (chunk.length == 0) {
				cb(Success(true));
				return;
			}
			var buf = chunk.toBytes();

			this.native.write(buf, result -> {
				final outcome = result ? Success(true) : Failure(new Error('Unable to write chunk ($chunk)'));
				cb(outcome);
			});
		}).first(this.ended);
	}
}
