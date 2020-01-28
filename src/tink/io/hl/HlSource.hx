package tink.io.hl;

import tink.streams.Stream;
import tink.CoreApi;

class HlSource extends Generator<Chunk, Error> {
	function new(target:WrappedReadStream) {
        
		super(Future.async(cb -> {
			target.read().handle(o -> cb(switch o {
				case Success(null):
					var out = sys.io.File.append('./output/chunks.out');

					out.write(haxe.io.Bytes.ofString('===================End chunk\r\n\r\n'));

					out.flush();
					out.close();
					End;
				case Success(chunk):
					var out = sys.io.File.append('./output/chunks.out');
					var bytes = chunk.toBytes();
					out.write(haxe.io.Bytes.ofString('New chunk (${bytes.length} bytes):\r\n\r\n'));
					out.write(bytes);
					out.flush();
					out.close();
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
