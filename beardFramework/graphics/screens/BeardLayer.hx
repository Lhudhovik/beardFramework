package beardFramework.graphics.screens;
import beardFramework.core.BeardGame;
import beardFramework.graphics.objects.RenderedObject;
import beardFramework.graphics.core.Renderer;
import beardFramework.graphics.objects.WorldObject;
import beardFramework.interfaces.IBatchable;
import beardFramework.interfaces.IRenderable;
import beardFramework.systems.aabb.AABB;
import beardFramework.systems.aabb.AABBTree;
import beardFramework.resources.MinAllocArray;


/**
 * ...
 * @author Ludo
 */
class BeardLayer
{
	public static var DEPTH_CONTENT:Float = 1;
	public static var DEPTH_UI:Float = 0;
	public static var DEPTH_LOADING:Float = -1;
	public static var DEPTH_DEBUG:Float = -1;
	
	@:isVar public var canRender(get, set):Bool;
	public var depth:Float; 
	public var maxObjectsCount(default, null):Int;
	public var name:String;
	public var id:Int;
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
		canRender = true;
		
		
	}

	public function VisualHitTest(x:Float, y:Float):Bool
	{
		
		
		return true;
	}
	
	public function AddMultiple(objects:Array<RenderedObject>):Void
	{
		
		for (i in 0...objects.length)
			Add(objects[i]);
		
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
				object.canRender = this.canRender;
				if(Std.is(object, IBatchable)) cast(object, IBatchable).RequestBufferIndex();
				object.isDirty = true;
				renderedObjects.set(object.name, object);
			}
	
		}
		
	}
	
	public function Add(object:RenderedObject):Void
	{
		//trace(object.name);
		if (!renderedObjects.exists(object.name))
		{
			//if(object.name == null)		trace(object.layer.id);
			if (object.layer != null && object.layer != this) object.layer.Remove(object);
			object.layer = this;
			object.z = (object.z ==-1) ? insertionDepth++ : object.z;
			object.canRender =  this.canRender;
			
			renderedObjects.set(object.name, object);
			
			if (object.onAABBTree){
				
				AddAABB(object);
				//trace(aabbs);
			}
			
			object.isDirty = true;
			
			if (Std.is(object, IBatchable)){
				
				cast(object, IBatchable).RequestBufferIndex();
				cast(object, IBatchable).renderingBatch.UpdateRenderedData();
		
			}
			else if (Std.is(object, IRenderable))
			{
				Renderer.Get().AddRenderable(cast object);
			}
		}
	}
	
	public inline function Remove(object:RenderedObject):Void
	{
		if (!renderedObjects.exists(object.name))
		{
			renderedObjects.remove(object.name);
			if (Std.is(object, IBatchable)) cast(object, IBatchable).ReleaseBufferIndex();
			else if (Std.is(object, IRenderable))
				Renderer.Get().RemoveRenderable(cast object);
			
			//object.isDirty = false;
			if (object.onAABBTree && aabbs[object.name] != null){
				
				aabbTree.Remove(aabbs[object.name]);
				aabbs[object.name] = null;
			}
			
			
		}
	}
	
	public function AddAABB(object:WorldObject):Void
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
	
	public function RemoveAABB(object:WorldObject):Void
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
	
	function get_canRender():Bool 
	{
		return canRender;
	}
	
	function set_canRender(value:Bool):Bool 
	{
		
		for (object in renderedObjects)
			object.canRender = value;
		return canRender = value;
	}
	
	

}


enum BeardLayerType
{
	CONTENT;
	UI;
	LOADING;
	
}