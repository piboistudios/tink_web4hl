package tink.io.hl;

import hl.uv.Stream;
import tink.Chunk;

using tink.CoreApi;

class WrappedWriteStream {
	var ended:Promise<Bool>;
	var onEnd:Callback<Bool>;
	var native:Stream;
	var name:String;

	public function new(name, native) {
		this.name = name;
		this.native = native;
		this.ended = Future.async(cb -> {
			this.onEnd = cb;
		});
	}

	public function end():Promise<Bool> {
		var didEnd = false;
		this.ended.handle(() -> {
			didEnd = true;
		}).dissolve();

		if (didEnd)
			return false;
		var retVal = Future.async(cb -> {
			native.close(() -> {
				cb(true);
			});
		});
		return retVal;
	}

	public function write(chunk:Chunk):Promise<Bool> {
		return Future.async(cb -> {
			var buf = chunk.toBytes();
			this.native.write(buf, result -> {
				final outcome = result ? Success(true) : Failure(new Error('Unable to write chunk ($chunk)'));
				this.onEnd.invoke(result);
				cb(outcome);
			});
		});
	}
}
