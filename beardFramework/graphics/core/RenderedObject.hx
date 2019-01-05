package beardFramework.graphics.core;
import beardFramework.graphics.rendering.Renderer;
import beardFramework.interfaces.ICameraDependent;


/**
 * ...
 * @author 
 */
class RenderedObject implements ICameraDependent
{
	
	@:isVar public var alpha(get, set):Float;
	@:isVar public var bufferIndex(get, set):Int;
	public var height(get, set):Float;	
	public var width(get, set):Float;
	@:isVar public var isDirty(get, set):Bool = false;
	@:isVar public var name(get, set):String;
	@:isVar public var stockageID:Int;
	@:isVar public var visible(get, set):Bool;
	@:isVar public var rotation (get, set):Float;
	@:isVar public var scaleX (get, set):Float;
	@:isVar public var scaleY (get, set):Float;
	@:isVar public var x(get, set):Float;
	@:isVar public var y(get, set):Float;
	@:isVar public var z(get, set):Float;
	@:isVar public var color(get, set):UInt;

	public var layer:BeardLayer;
	public var displayingCameras(default, null):List<String>;	
	public var renderer:Renderer;
	public var renderDepth(default,null):Float;
	public var restrictedCameras(default, null):Array<String>;
	public var rotationCosine(default,null):Float;
	public var rotationSine(default,null):Float;
	
	private var cachedWidth:Float;
	private var cachedHeight:Float;
	@:isVar public var renderingBatch(get, set):String;
	
	public function new() 
	{
		
		visible = true;
		alpha = 1;
		color = 0xffffff;
		z = -1;
		renderDepth = -2;
		scaleX = scaleY = 1;
		cachedWidth = cachedHeight = 0;
		rotation = 0;
		rotationSine = Math.sin (0);
		rotationCosine = Math.cos (0);
		bufferIndex = -1;
		stockageID = -1;
		displayingCameras = new List<String>();
		renderingBatch = "default";
		
	}
	
	inline public function get_x():Float 
	{
		return x;
	}
	
	public function set_x(value:Float):Float 
	{
		if(value != x) isDirty = true;
		return x = value;
	}
	
	inline public function get_y():Float 
	{
		return y;
	}
	
	public function set_y(value:Float):Float 
	{
		if(value != x) isDirty = true;
		return y = value;
	}
	
	inline public function get_width():Float 
	{
		return cachedWidth;
	}
	
	public function set_width(value:Float):Float 
	{
		if (value != cachedWidth)
		{
			scaleX = (value *scaleX) / cachedWidth;
			isDirty = true;
		}
		
		return value;
	}
	
	inline public function get_height():Float 
	{
		return cachedHeight;
	}
	
	public function set_height(value:Float):Float 
	{
		if (value != cachedHeight)			
		{ 
			scaleY = (value*scaleY) / cachedHeight;
			isDirty = true;
		}
		
		return value;
	}
	
	inline public function get_scaleX ():Float 
	{
		
		return scaleX;
		
	}
	
	public function set_scaleX (value:Float):Float 
	{
		
		if (value != scaleX)
		{
			
			cachedWidth = (cachedWidth/scaleX) * value;	
			scaleX = value;
			isDirty = true;
		}
		
		return value;
		
	}
	
	inline public function get_scaleY ():Float 
	{
		
		return scaleY;
		
	}
	
	public function set_scaleY (value:Float):Float 
	{
		if (value != scaleY)
		{
			
			cachedHeight = (cachedHeight/scaleY) * value;	
			scaleY = value;
			isDirty = true;
		}
		return value;
		
	}
	
	inline public function get_rotation ():Float 
	{
		
		return rotation;
		
	}
	
	public function set_rotation (value:Float):Float 
	{
		
		if (value != rotation) {
			
			rotation = value;
			var radians = value * (Math.PI / 180);
			rotationSine = Math.sin (radians);
			rotationCosine = Math.cos (radians);
			isDirty = true;
		}
		
		
		return value;
		
	}
	
	public function AuthorizeCamera(addedCameraID:String):Void 
	{
		if (restrictedCameras == null) restrictedCameras = new Array<String>();
		if (restrictedCameras.indexOf(addedCameraID) == -1) restrictedCameras.push(addedCameraID);
	}
	
	public function ForbidCamera(forbiddenCameraID:String):Void 
	{
		if (restrictedCameras != null) restrictedCameras.remove(forbiddenCameraID);
	}
	
	inline function get_z():Float 
	{
		return z;
	}
	
	inline function set_z(value:Float):Float 
	{
		z = value;
		
		if (layer != null)
		{
			renderDepth = layer.depth + (z / layer.maxObjectsCount);	
		}
		
		isDirty = true;
		return z;
	}
	
	function get_name():String 
	{
		return name;
	}
	
	function set_name(value:String):String 
	{
		return name = value;
	}
	
	function get_visible():Bool 
	{
		return visible;
	}
	
	function set_visible(value:Bool):Bool 
	{
		isDirty = true;
		return visible = value;
	}
	
	function get_isDirty():Bool 
	{
		return isDirty;
	}
	
	function  set_isDirty(value:Bool):Bool 
	{
		if (value == true && renderer != null && bufferIndex >= 0) renderer.AddDirtyObject(this, renderingBatch);
		else if ( value == false && renderer != null) renderer.RemoveDirtyObject(this, renderingBatch);
		return isDirty = value;
	}
	
	function get_bufferIndex():Int 
	{
		return bufferIndex;
	}
	
	function set_bufferIndex(value:Int):Int 
	{
		return bufferIndex = value;
	}
	
	function get_alpha():Float 
	{
		return alpha;
	}
	
	function set_alpha(value:Float):Float 
	{
		return alpha = value;
	}
	
	function get_color():UInt 
	{
		return color;
	}
	
	function set_color(value:UInt):UInt 
	{
		isDirty = true;
		return color = value;
	}
	
	public function SetBaseWidth(value:Float):Void
	{
		//trace("base width set to " + value);
		var currentScale:Float = scaleX;
		scaleX = 1;
		cachedWidth = value;
		scaleX = currentScale;
		isDirty = true;
		
	}
	
	public function SetBaseHeight(value:Float):Void
	{
		//trace("base height set to " + value);
		var currentScale:Float = scaleY;
		scaleY = 1;
		cachedHeight = value;
		scaleY = currentScale;
		isDirty = true;
		
	}
	
	function get_renderingBatch():String 
	{
		return renderingBatch;
	}
	
	function set_renderingBatch(value:String):String 
	{
		if (value != renderingBatch)
		{
			if (renderer != null && bufferIndex >=0)
			{
				renderer.RemoveDirtyObject(this, renderingBatch);
				renderer.FreeBufferIndex(bufferIndex, renderingBatch);
				bufferIndex = renderer.AllocateBufferIndex(value);
			}
		
			renderingBatch = value;
			isDirty = true;
			
		}
		
		
		return renderingBatch;
	}
	
	
	
	
	
	
}