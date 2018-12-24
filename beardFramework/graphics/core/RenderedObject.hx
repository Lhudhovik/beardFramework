package beardFramework.graphics.core;
import beardFramework.graphics.rendering.Renderer;
import beardFramework.interfaces.ICameraDependent;
import openfl.geom.Matrix;

/**
 * ...
 * @author 
 */
class RenderedObject implements ICameraDependent
{
	
	public var alpha:Float;
	@:isVar public var bufferIndex(get, set):Int;
	public var color:UInt;
	public var displayingCameras(default, null):List<String>;
	public var height(get, set):Float;	
	@:isVar public var isDirty(get, set):Bool = false;
	public var layer:BeardLayer;
	@:isVar public var name(get, set):String;
	public var renderer:Renderer;
	public var renderDepth(default,null):Float;
	public var restrictedCameras(default, null):Array<String>;
	@:isVar public var visible(get, set):Bool;
	public var rotation (get, set):Float;
	public var scaleX (get, set):Float;
	public var scaleY (get, set):Float;
	public var width(get, set):Float;
	public var x(get, set):Float;
	public var y(get, set):Float;
	@:isVar public var z(get, set):Float;
	private var cachedHeight:Float;
	private var cachedRotation:Null<Float>;
	private var cachedScaleX:Null<Float>;
	private var cachedScaleY:Null<Float>;
	private var cachedWidth:Float;
	private var rotationCosine:Float;
	private var rotationSine:Float;
	private var transform:Matrix;
	
	
	
	public function new() 
	{
		
		transform = new Matrix();
		
		visible = true;
		alpha = 1;
		color = 0xffffff;
		z = -1;
		renderDepth = -2;
		width = 0;
		height = 0;
		bufferIndex = -1;
		
		
		displayingCameras = new List<String>();
		
		
	}
	
	inline function get_x():Float 
	{
		return transform.tx;
	}
	
	function set_x(value:Float):Float 
	{
		isDirty = true;
		return transform.tx = value;
	}
	
	inline function get_y():Float 
	{
		return transform.ty;
	}
	
	function set_y(value:Float):Float 
	{
		isDirty = true;
		return transform.ty = value;
	}
	
	function get_width():Float 
	{
		return cachedWidth;
	}
	
	function set_width(value:Float):Float 
	{
		if (value != cachedWidth)			
			scaleX = value / cachedWidth;
			
		else 		
			scaleX = 1;
		
		isDirty = true;
		return value;
	}
	
	function get_height():Float 
	{
		return cachedHeight;
	}
	
	function set_height(value:Float):Float 
	{
		if (value != cachedHeight)			
			scaleY = value / cachedHeight;
			
		else 		
			scaleY = 1;
		
		isDirty = true;
		return value;
	}
	
	private function get_scaleX ():Float 
	{
		
		if (cachedScaleX == null) {
			
			if (transform.b == 0) {
				
				cachedScaleX = transform.a;
				
			} else {
				
				cachedScaleX = Math.sqrt (transform.a * transform.a + transform.b * transform.b);
				
			}
			
		}
		
		return cachedScaleX;
		
	}
	
	private function set_scaleX (value:Float):Float 
	{
		
		if (cachedScaleX != value) {
			
			cachedScaleX = value;
			
			if (transform.b == 0) {
				
				transform.a = value;
				
			} else {
				
				//var rotation = this.rotation;
				
				var a = rotationCosine * value;
				var b = rotationSine * value;
				
				transform.a = a;
				transform.b = b;
				
			}
			
		}
		cachedWidth = cachedWidth * value;
		
		isDirty = true;
		return value;
		
	}
	
	private function get_scaleY ():Float 
	{
		
		if (cachedScaleY == null) {
			
			if (transform.c == 0) {
				
				cachedScaleY = transform.d;
				
			} else {
				
				cachedScaleY = Math.sqrt (transform.c * transform.c + transform.d * transform.d);
				
			}
			
		}
		
		return cachedScaleY;
		
	}
	
	private function set_scaleY (value:Float):Float 
	{
		
		if (cachedScaleY != value) {
			
			cachedScaleY = value;
			
			if (transform.c == 0) {
				
				transform.d = value;
				
			} else {
				
				//var rotation = this.rotation;
				
				var c = -rotationSine * value;
				var d = rotationCosine * value;
				
				transform.c = c;
				transform.d = d;
				
			}
			
		}
		
		cachedHeight = cachedHeight * value;
		isDirty = true;
		
		return value;
		
	}
	
	private function get_rotation ():Float 
	{
		
		if (cachedRotation == null) {
		
			if (transform.b == 0 && transform.c == 0) {
				
				cachedRotation = 0;
				rotationSine = 0;
				rotationCosine = 1;
				
			} else {
				
				var radians = Math.atan2 (transform.d, transform.c) - (Math.PI / 2);
				
				cachedRotation = radians * (180 / Math.PI);
				rotationSine = Math.sin (radians);
				rotationCosine = Math.cos (radians);
				
			}
			
		}
		
		return cachedRotation;
		
	}
	
	private function set_rotation (value:Float):Float 
	{
		
		if (value != cachedRotation) {
			
			cachedRotation = value;
			var radians = value * (Math.PI / 180);
			rotationSine = Math.sin (radians);
			rotationCosine = Math.cos (radians);
						
			transform.a = rotationCosine * cachedScaleX;
			transform.b = rotationSine * cachedScaleX;
			transform.c = -rotationSine * cachedScaleY;
			transform.d = rotationCosine * cachedScaleY;
			
			
		}
		
		isDirty = true;
		
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
	
	function set_isDirty(value:Bool):Bool 
	{
		if (value == true && renderer != null && bufferIndex >= 0) renderer.AddDirtyObject(this);
		else if ( value == false && renderer != null) renderer.RemoveDirtyObject(this);
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
	
	
	
	
	
	
	
}