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
		trace('ending');
		var didEnd = false;
		this.ended.handle(() -> {
			trace('ended');
			didEnd = true;
		});
		trace('ended');
		if (didEnd) {
			trace('ended');
			return false;
		}
		native.close(() -> {
			trace('end');
			this.endTrigger.trigger(Success(false));
		});
		trace('native closed');
		return this.ended.map(_ -> true);
	}
	function close() {

		if(!this.closed) {}
	}
	public function write(chunk:Chunk):Promise<Bool> {
		
		return Future.async(cb -> {
			if (chunk.length == 0) {
				cb(Success(true));
				return;
			}
			var buf = chunk.toBytes();
			trace(buf.length);
			this.native.write(buf, result -> {
				final outcome = result ? Success(true) : Failure(new Error('Unable to write chunk ($chunk)'));
				cb(outcome);
			});
		});
	}
}
