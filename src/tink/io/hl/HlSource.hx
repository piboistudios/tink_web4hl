package tink.io.hl;

import tink.streams.Stream;
import tink.CoreApi;

class HlSource extends Generator<Chunk, Error> {
	function new(target:WrappedReadStream) {
        
		super(Future.async(cb -> {
			target.read().handle(o -> cb(switch o {
				case Success(null):
					End;
				case Success(chunk):
					Link(chunk, new HlSource(target));
				case Failure(e): 
                    
                    Fail(e);
			}));
		} #if !tink_core_2, true #end));
	}

	static public function wrap(name, native, chunkSize, onEnd) {
		return new HlSource(new WrappedReadStream(name, native, chunkSize, onEnd));
	}
}
