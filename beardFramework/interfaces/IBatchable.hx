package beardFramework.interfaces;

/**
 * @author 
 */
interface IBatchable 
{
	public var bufferIndex(get, set):Int;
	public var renderingBatch(get, set):IBatch;
	public var isDirty(get, set):Bool;
	public function RequestBufferIndex():Void;
	public function ReleaseBufferIndex():Void;
}