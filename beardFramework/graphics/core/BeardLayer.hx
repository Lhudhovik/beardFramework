package beardFramework.graphics.core;
import beardFramework.core.BeardGame;
import beardFramework.graphics.rendering.Renderer;
import beardFramework.systems.aabb.AABB;
import beardFramework.systems.aabb.AABBTree;
import beardFramework.resources.MinAllocArray;


/**
 * ...
 * @author Ludo
 */
class BeardLayer
{
	public static var DEPTH_CONTENT:Float = 0.5;
	public static var DEPTH_UI:Float = 0;
	public static var DEPTH_LOADING:Float = -0.5;
	
	public var depth:Float; 
	public var maxObjectsCount(default, null):Int;
	public var name:String;
	public var id:Int;
	@:isVar public var visible(get, set):Bool;
	public var renderedObjects:Map<String, RenderedObject>;
	public var aabbs:Map<String, AABB>;
	public var aabbTree:AABBTree;

	private var insertionDepth:Int = 0;
	
	public function new(name:String, depth :Float, id:Int, maxObjectsCount:Int=10000) 
	{
		this.name = name;
		this.depth = depth;
		this.id = id;
		this.maxObjectsCount = maxObjectsCount;
		renderedObjects = new Map();	
		aabbs = new Map();
		aabbTree = new AABBTree(5);
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
			
			if (!renderedObjects.exists(object.name))
			{
			
				object.layer = this;
				object.z = (object.z ==-1) ? insertionDepth++ : object.z;
				object.visible = this.visible;
				object.bufferIndex =  object.renderingBatch.AllocateBufferIndex();
				object.isDirty = true;
				renderedObjects.set(object.name, object);
			}
	
		}
		
	}
	
	public function Add(object:RenderedObject, updateBuffer:Bool = true):Void
	{
		trace(object.name);
		if (!renderedObjects.exists(object.name))
		{
			if(object.name == null)		trace(object.layer.id);
			object.layer = this;
			object.z = (object.z ==-1) ? insertionDepth++ : object.z;
			object.visible =  this.visible;
			object.bufferIndex = object.renderingBatch.AllocateBufferIndex();
			renderedObjects.set(object.name, object);
			
			if (object.onAABBTree){
				
				AddAABB(object);
				//trace(aabbs);
			}
			
			object.isDirty = true;
			
			if (updateBuffer){
				
				object.renderingBatch.UpdateRenderedData();
			}
			
		}
	}
	
	public inline function Remove(object:RenderedObject):Void
	{
		if (!renderedObjects.exists(object.name))
		{
			renderedObjects.remove(object.name);
			object.bufferIndex = object.renderingBatch.FreeBufferIndex(object.bufferIndex);
			//object.isDirty = false;
			if (object.onAABBTree && aabbs[object.name] != null){
				
				aabbTree.Remove(aabbs[object.name]);
				aabbs[object.name] = null;
			}
			
			
		}
	}
	
	public function AddAABB(object:RenderedObject):Void
	{
		if(aabbs[object.name] == null) 	aabbs[object.name] = new AABB();
		aabbs[object.name].owner = object.name;
		aabbs[object.name].layer = this.id;
		aabbs[object.name].topLeft.x = object.x;
		aabbs[object.name].topLeft.y = object.y;
		aabbs[object.name].bottomRight.x = object.x + object.width;
		aabbs[object.name].bottomRight.y = object.y + object.height;
		
		aabbTree.Add(aabbs[object.name]);
	}
	
	public function RemoveAABB(object:RenderedObject):Void
	{
		if (aabbs[object.name] != null)
		{
			aabbTree.Remove(aabbs[object.name]);
			aabbs[object.name] = null;
		}
		
	}
	
	public function Update():Void
	{
		if (!aabbTree.IsEmpty()) aabbTree.UpdateTree();
		
	}
	
	function get_visible():Bool 
	{
		return visible;
	}
	
	function set_visible(value:Bool):Bool 
	{
		
		for (object in renderedObjects)
			object.visible = value;
		return visible = value;
	}
	
	

}


enum BeardLayerType
{
	CONTENT;
	UI;
	LOADING;
	
}