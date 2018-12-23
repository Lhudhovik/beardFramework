package beardFramework.display.core;
import beardFramework.display.rendering.DefaultRenderer;
import beardFramework.display.rendering.TextRenderer;
import beardFramework.display.rendering.VisualRenderer;
import beardFramework.resources.assets.AssetManager;
import beardFramework.utils.MinAllocArray;
import haxe.ds.Vector;

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
	@:isVar public var visible(get, set):Bool;
	public var renderedObjects:Array<RenderedObject>;
	
	
	public function new(name:String, depth :Float, maxObjectsCount:Int=100000) 
	{
		this.name = name;
		this.depth = depth;
		this.maxObjectsCount = maxObjectsCount;
		renderedObjects = new Array<RenderedObject>();	
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
			
			if (renderedObjects.indexOf(object) == -1)
			{
			
				object.layer = this;
				object.z = (object.z ==-1) ? renderedObjects.length : object.z;
				object.visible = this.visible;
				object.bufferIndex =  object.renderer.AllocateBufferIndex();
				object.isDirty = true;
				renderedObjects.push(object);
			}
	
		}
		
	}
	
	public function Add(object:RenderedObject, updateBuffer:Bool = true):Void
	{
		if (renderedObjects.indexOf(object) == -1)
		{
			
			object.layer = this;
			object.z = (object.z ==-1) ? renderedObjects.length : object.z;
			object.visible = this.visible;
			object.bufferIndex = object.renderer.AllocateBufferIndex();
			object.isDirty = true;
			renderedObjects.push(object);
			
			if (updateBuffer) object.renderer.UpdateRenderedData();
		}
	}
		
	public inline function Remove(object:RenderedObject):Void
	{
		if (renderedObjects.indexOf(object) != -1)
		{
			trace("removeing");
			renderedObjects.remove(object);
			object.bufferIndex = object.renderer.FreeBufferIndex(object.bufferIndex);
			object.isDirty = false;
		}
	}
	
	function get_visible():Bool 
	{
		return visible;
	}
	
	function set_visible(value:Bool):Bool 
	{
		
		for (visual in renderedObjects)
			visual.visible = value;
		return visible = value;
	}
	

}


enum BeardLayerType
{
	CONTENT;
	UI;
	LOADING;
	
}