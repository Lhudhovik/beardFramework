package beardFramework.interfaces;
import beardFramework.graphics.batches.BatchRenderingData;
import beardFramework.resources.MinAllocArray;
import haxe.ds.Vector;
import lime.graphics.opengl.GLProgram;

/**
 * @author 
 */
interface IBatch extends IRenderable
{
  	public var needOrdering:Bool;
	private var dirtyObjects:MinAllocArray<IBatchable>;
	public var vertices:Vector<Float>;
		
	public function UpdateRenderedData():Void;
	public function IsEmpty():Bool;
	
	public function Init(batchData:BatchRenderingData):Void;
	public function AllocateBufferIndex(index:Int=-1):Int;
	public function FreeBufferIndex(index:Int):Int;
	public function AddDirtyObject(object:IBatchable):Void;
	public function RemoveDirtyObject(object:IBatchable):Void;
	public function AddAtlas(atlas:String):Void;
	public function RemoveAtlas(atlas:String):Void;
	
}