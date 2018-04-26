package beardFramework.display.cameras;
import beardFramework.interfaces.ICameraDependent;
import beardFramework.resources.save.data.DataCamera;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.display.DisplayObject;

/**
 * ...
 * @author Ludo
 */
class Camera
{
	private static var utilRect:Rectangle;
	public static var DEFAULT(default, null):String = "default";
	@:isVar public var name(get, set):String;
	public var zoom(get,set):Float;
	public var viewportWidth:Float;
	public var viewportHeight:Float;
	public var cameraX:Float;
	public var cameraY:Float;
	public var viewportX(get, set):Float;
	public var viewportY(get, set):Float;
	public var buffer:Float;
	//a : scale X, d: ScaleY
	public var transform(default, null):Matrix;
	
	public function new(name:String, width:Float = 100, height:Float = 57, buffer : Float = 100) 
	{
		transform = new Matrix();
		this.name = name;
		this.viewportWidth = width;
		this.viewportHeight = height;
		this.buffer = buffer;
		
	}
	
	
	
	public inline function get_zoom():Float return transform.a;
	public function set_zoom(newZoom:Float):Float{
		
		buffer *= zoom;
		buffer /= newZoom;
		//trace(buffer);
		transform.d = newZoom;
		return transform.a = newZoom;
	}
	
	
	
	public function GetRect():Rectangle
	{
		if (utilRect == null)
		utilRect = new Rectangle();
		
		utilRect.width = this.viewportWidth/zoom;
		utilRect.height = this.viewportHeight/zoom;
		utilRect.x = 0;
		utilRect.y = 0;
		
		return utilRect;
	}
	
	public function GetOnScreenRect():Rectangle
	{
		if (utilRect == null)
		utilRect = new Rectangle();
		
		utilRect.width = this.viewportWidth;
		utilRect.height = this.viewportHeight;
		utilRect.x = transform.tx;
		utilRect.y = transform.ty;
		
		return utilRect;
	}
	
	public function ContainsPoint(point:Point):Bool
	{
		if (utilRect == null)
		utilRect = new Rectangle( );
		
		utilRect.width = this.viewportWidth;
		utilRect.height = this.viewportHeight;
		utilRect.x = transform.tx;
		utilRect.y = transform.ty;
		
		return utilRect.containsPoint(point);
		
		
	}
	
	public function Contains(object:DisplayObject):Bool{
		
		var success:Bool = (cast(object, ICameraDependent).restrictedCameras == null || cast(object, ICameraDependent).restrictedCameras.indexOf(name) != -1);
		
		if (success)
			success = (((object.x + object.width) > (cameraX - buffer)) && (object.x < (cameraX + viewportWidth + buffer)) && ((object.y + object.height) > (cameraY - buffer)) && (object.y < (cameraY + viewportHeight + buffer)));
	
		//if (this.id == "two"){
			//
			//if (!success) trace(object.x - this.cameraX);
			////trace(object.name + "  " + success);
		//}
		//trace(" left " + (object.x + object.width) + " greater than " + (x - buffer));
		//trace(" right " + (object.x) + " lesser than " + (x + width + buffer));
		//trace(" top " + (object.y + object.height) + " greater than " + (y - buffer));
		//trace(" left " + (object.y) + " lesser than " + (y + height + buffer));
		//trace("------------------------------------------------------------------");
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
	
	
	function get_name():String 
	{
		return name;
	}
	
	function set_name(value:String):String 
	{
		return name = value;
	}
	
	public function ToData():DataCamera
	{
		
		return {
			
			name:this.name,
			type:"Camera",
			zoom:transform.a,
			viewportWidth:this.viewportWidth,
			viewportHeight:this.viewportHeight,
			cameraX:this.cameraX,
			cameraY:this.cameraY,
			viewportX:transform.tx,
			viewportY:transform.ty,
			buffer:this.buffer
			
			
		}
		
	}
	
	public function ParseData(data:DataCamera):Void
	{
		this.name = data.name;
		zoom = data.zoom;
		viewportWidth = data.viewportWidth;
		viewportHeight = data.viewportHeight;
		cameraX = data.cameraX;
		cameraY = data.cameraY;
		transform.tx = data.viewportX;
		transform.ty = data.viewportY;
		buffer = data.buffer;
	
		
	}
	
	
}