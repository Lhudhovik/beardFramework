package beardFramework.display.core;
import beardFramework.resources.assets.AssetManager;
import beardFramework.resources.assets.Atlas.SubTextureData;
import haxe.ds.Vector;
import lime.graphics.opengl.GL;
import lime.utils.Float32Array;
import openfl.geom.Matrix;

/**
 * ...
 * @author 
 */
class Visual 
{

	public var bufferIndex:Int;
	public var atlas:String;
	public var alpha:Float;
	public var name:String;
	public var color:UInt;
	public var texture:String;
	public var textureWidth(default, null):Int;
	public var textureHeight(default, null):Int;
	public var visible:Bool;
	
	public var x(get, set):Float;
	public var y(get, set):Float;
	public var width(get, set):Float;
	public var height(get, set):Float;	
	public var rotation (get, set):Float;
	public var scaleX (get, set):Float;
	public var scaleY (get, set):Float;

	private var cachedWidth:Float;
	private var cachedHeight:Float;
	private var cachedScaleX:Null<Float>;
	private var cachedScaleY:Null<Float>;
	private var cachedRotation:Null<Float>;
	private var rotationCosine:Float;
	private var rotationSine:Float;
	private var transform:Matrix;
		
	
	
	public function new(texture:String, atlas:String ) 
	{
	
		this.texture = texture;
		this.atlas = atlas;
		transform = new Matrix();
		visible = true;
		alpha = 1;
		color = 0xffffff;
		
		var texture:SubTextureData = AssetManager.Get().GetSubTextureData(texture, atlas);
		textureWidth = Math.round(texture.imageArea.width);
		textureHeight = Math.round(texture.imageArea.height);
		
		
	}
	
	inline function get_x():Float 
	{
		return transform.tx;
	}
	
	function set_x(value:Float):Float 
	{
		return transform.tx = value;
	}
	
	inline function get_y():Float 
	{
		return transform.ty;
	}
	
	function set_y(value:Float):Float 
	{
		return transform.ty = value;
	}
	
	function get_width():Float 
	{
		return cachedWidth;
	}
	
	function set_width(value:Float):Float 
	{
		if (value != textureWidth)			
			scaleX = value / textureWidth;
			
		else 		
			scaleX = 1;
				
		return value;
	}
	
	function get_height():Float 
	{
		return cachedHeight;
	}
	
	function set_height(value:Float):Float 
	{
		if (value != textureHeight)			
			scaleY = value / textureHeight;
			
		else 		
			scaleY = 1;
				
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
				
				var rotation = this.rotation;
				
				var a = rotationCosine * value;
				var b = rotationSine * value;
				
				transform.a = a;
				transform.b = b;
				
			}
			
		}
		cachedWidth = textureWidth * value;
		
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
				
				var rotation = this.rotation;
				
				var c = -rotationSine * value;
				var d = rotationCosine * value;
				
				transform.c = c;
				transform.d = d;
				
			}
			
		}
		
		cachedHeight = textureHeight * value;
		
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
		
		return value;
		
	}
	
	public function ToVertexAttributes():Float32Array
	{
		
		return new Float32Array(null, []);
		
		
	}
	
	
}

