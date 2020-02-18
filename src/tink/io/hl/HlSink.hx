package tink.io.hl;

import tink.io.Sink;

using tink.io.PipeResult;

import tink.io.hl.*;

using tink.CoreApi;
using tink.streams.Stream;

class HlSink extends SinkBase<Error, Noise> {
	var target:WrappedWriteStream;

	function new(target) {
		this.target = target;
	}

	override public function consume<EIn>(source:tink.streams.Stream<Chunk, EIn>, options:PipeOptions):Future<PipeResult<EIn, Error, Noise>> {
		var ret = source.forEach(function(c) return target.write(c).map(function(w) return switch w {
			case Success(true):
				Resume;
			case Success(false):
				BackOff;
			case Failure(e):
				Clog(e);
		}));

		if (options.end) {
			ret.handle(function(end) {
				target.end().handle(function(res) {});
			});
		}
		return ret.map(function(c) return c.toResult(Noise));
	}

	static public function wrap(name, native) {
		return new HlSink(new WrappedWriteStream(name, native));
	}
}
