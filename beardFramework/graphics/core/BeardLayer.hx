package beardFramework.graphics.core;
import beardFramework.utils.MinAllocArray;


/**
 * ...
 * @author Ludo
 */
class BeardLayer
{
	public static var DEPTH_CONTENT:Float = -0.5;
	public static var DEPTH_UI:Float = 0;
	public static var DEPTH_LOADING:Float = 0.5;
	
	public var depth:Float; 
	public var maxObjectsCount(default, null):Int;
	public var name:String;
	public var id:Int;
	@:isVar public var visible(get, set):Bool;
	public var renderedObjects:MinAllocArray<RenderedObject>;
	
	
	public function new(name:String, depth :Float, id:Int, maxObjectsCount:Int=10000) 
	{
		this.name = name;
		this.depth = depth;
		this.id = id;
		this.maxObjectsCount = maxObjectsCount;
		renderedObjects = new MinAllocArray<RenderedObject>();	
		visible = true;
	
		
	}

	public function VisualHitTest(x:Float, y:Float):Bool
	{
		
		
		return true;
	}
	
	public function AddMultiple(objects:Array<RenderedObject>):Void
	{
		
		for (i in 0...objects.length)
			Add(objects[i], false);
		
	}
	
	public function AddMultipleOpti(addedObjects:MinAllocArray<RenderedObject>):Void
	{
		var object:RenderedObject;
		
		for (i in 0...addedObjects.length){
			
			object = addedObjects.get(i);
			
			if (renderedObjects.IndexOf(object) == -1)
			{
			
				object.layer = this;
				object.z = (object.z ==-1) ? renderedObjects.length : object.z;
				object.visible = this.visible;
				object.bufferIndex =  object.renderer.AllocateBufferIndex(object.renderingBatch);
				object.isDirty = true;
				renderedObjects.Push(object);
			}
	
		}
		
	}
	
	public function Add(object:RenderedObject, updateBuffer:Bool = true):Void
	{
		if (renderedObjects.IndexOf(object) == -1)
		{
			
			object.layer = this;
			object.z = (object.z ==-1) ? renderedObjects.length : object.z;
			object.visible =  this.visible;
			object.bufferIndex = object.renderer.AllocateBufferIndex(object.renderingBatch);
			object.isDirty = true;
			renderedObjects.Push(object);
			object.stockageID = renderedObjects.length - 1;
			
			if (updateBuffer) object.renderer.UpdateRenderedData(object.renderingBatch);
		}
	}
		
	public inline function Remove(object:RenderedObject):Void
	{
		if (renderedObjects.IndexOf(object) != -1)
		{
			renderedObjects.Remove(object);
			object.stockageID = -1;
			object.bufferIndex = object.renderer.FreeBufferIndex(object.bufferIndex, object.renderingBatch);
			object.isDirty = false;
			
		}
	}
	
	function get_visible():Bool 
	{
		return visible;
	}
	
	function set_visible(value:Bool):Bool 
	{
		
		for (i in 0...renderedObjects.length)
			renderedObjects.get(i).visible = value;
		return visible = value;
	}
	

}


enum BeardLayerType
{
	CONTENT;
	UI;
	LOADING;
	
}