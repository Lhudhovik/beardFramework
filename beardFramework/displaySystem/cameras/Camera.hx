package beardFramework.displaySystem.cameras;
import beardFramework.interfaces.ICameraDependent;
import openfl.geom.Matrix;
import openfl.geom.Rectangle;
import openfl.display.DisplayObject;

/**
 * ...
 * @author Ludo
 */
class Camera
{
	private static var utilRect:Rectangle;
	public var id(default, null):String;
	public var zoom(get,set):Float;
	public var width:Float;
	public var height:Float;
	public var x:Float;
	public var y:Float;
	public var viewportX(get, set):Float;
	public var viewportY(get, set):Float;
	public var buffer:Float;
	//a : scale X, d: ScaleY
	public var transform(default, null):Matrix;
	
	public function new(id:String, width:Float = 100, height:Float = 57, buffer : Float = 100) 
	{
		transform = new Matrix();
		this.id = id;
		this.width = width;
		this.height = height;
		this.buffer = buffer;
		
	}
	
	
	
	public inline function get_zoom():Float return transform.a;
	public function set_zoom(newZoom:Float):Float{
		
		transform.d = newZoom;
		return transform.a = newZoom;
	}
	
	
	
	public function GetRect():Rectangle
	{
		if (utilRect == null)
		utilRect = new Rectangle();
		
		utilRect.width = this.width;
		utilRect.height = this.height;
		utilRect.x = 0;
		utilRect.y = 0;
		
		return utilRect;
	}
	
	public function Contains(object:DisplayObject):Bool{
		
		var success:Bool = (cast(object, ICameraDependent).restrictedCameras == null || cast(object, ICameraDependent).restrictedCameras.indexOf(id) != -1);
		
		if (success)
			success = (((object.x + object.width) > (x - buffer)) && (object.x < (x + width + buffer)) && ((object.y + object.height) > (y - buffer)) && (object.y < (y + height + buffer)));
	
		return success;
	}
	
	inline function get_viewportX():Float 
	{
		return transform.tx;
	}
	
	inline function set_viewportX(value:Float):Float 
	{
		return transform.tx = value;
	}
	
	inline function get_viewportY():Float 
	{
		return transform.ty;
	}
	
	inline function set_viewportY(value:Float):Float 
	{
		return transform.ty = value;
	}
	
	
	
	
}