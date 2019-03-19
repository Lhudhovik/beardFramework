package beardFramework.interfaces;
import beardFramework.graphics.rendering.batches.BatchTemplateData;
import beardFramework.resources.MinAllocArray;
import lime.graphics.opengl.GLProgram;

/**
 * @author 
 */
interface IBatch extends IRenderable
{
  	public var needOrdering:Bool;
	private var dirtyObjects:MinAllocArray<IBatchable>;
		
	public function UpdateRenderedData():Void;
	public function IsEmpty():Bool;
	
	public function Init(batchData:BatchTemplateData):Void;
	public function AllocateBufferIndex(index:Int=-1):Int;
	public function FreeBufferIndex(index:Int):Int;
	public function AddDirtyObject(object:IBatchable):Void;
	public function RemoveDirtyObject(object:IBatchable):Void;
}