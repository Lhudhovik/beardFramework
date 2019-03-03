package beardFramework.graphics.cameras;
import beardFramework.core.BeardGame;
import beardFramework.graphics.core.RenderedObject;
import beardFramework.graphics.core.Visual;
import beardFramework.interfaces.ICameraDependent;
import beardFramework.resources.save.data.StructDataCamera;
import beardFramework.utils.simpleDataStruct.SRect;
import openfl.display.Tile;
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
	public static var MINZOOM(default, null):Float = 0.00001;
	
		
	@:isVar public var name(get, set):String;
	public var zoom(get,set):Float;
	public var viewportWidth(default, set):Float;
	public var viewportHeight(default, set):Float;
	public var centerX(default, set):Float;
	public var centerY(default, set):Float;
	public var viewportX(get, set):Float;
	public var viewportY(get, set):Float;
	public var buffer(default, set):Float;
	public var needRenderUpdate:Bool;
	public var transform(default, null):Matrix;//a : scale X, d: ScaleY
	public var keepRatio:Bool;
	public var ratios:SRect;
	
	public var viewport(default, null):ViewportRect;
	private var attachedObject:RenderedObject;
	
	public function new(name:String, viewPortWidth:Float = 100, viewPortHeight:Float = 57, viewPortX:Float = 0, viewPortY:Float = 0, buffer : Float = 100, keepRatio:Bool = false) 
	{
		transform = new Matrix();
			viewport = {
			x:0,
			y:0,
			width:0,
			height:0
		}	
		
		this.name = name;
		this.viewportWidth  = viewPortWidth;
		this.viewportHeight  = viewPortHeight;
		this.viewportX = viewPortX;
		this.viewportY = viewPortY;
		this.buffer = buffer;
		needRenderUpdate = true;
		this.keepRatio = keepRatio;
		if (keepRatio == true)
		{
			ratios = {
				x: viewportX / BeardGame.Get().window.width,
				y:  viewportY / BeardGame.Get().window.height,
				width: viewportWidth / BeardGame.Get().window.width,
				height: viewportHeight / BeardGame.Get().window.height
			}
		}else ratios = {x:0, y:0, width:0, height:0 };
		
		
		
		centerX = 0;
		centerY = 0;
	}
	
	public function SetViewportRatios(x:Float, y: Float, width:Float, height:Float):Void
	{
		keepRatio = true;
		
		ratios.x=x;
		ratios.y=y;
		ratios.width=width;
		ratios.height=height;
		
		viewportX = BeardGame.Get().window.width * x;
		viewportY = BeardGame.Get().window.height * y;
		viewportWidth = BeardGame.Get().window.width * width;
		viewportHeight = BeardGame.Get().window.height * height;
		
	}
	
	public inline function get_zoom():Float return transform.a;
	
	public function set_zoom(newZoom:Float):Float{
		
		if (newZoom <= 0) newZoom = MINZOOM;
		buffer *= zoom;
		buffer /= newZoom;
		//trace(buffer);
		transform.d = newZoom;
		
		if (transform.a != newZoom) needRenderUpdate = true;
		return transform.a = newZoom;
	}
	
	public inline function Center(centerX:Float=0, centerY:Float=0):Void
	{
		this.centerX = centerX;
		this.centerY = centerY;	
	}
	
	public function Attach(object:RenderedObject):Void
	{
		attachedObject = object;
		
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
	
	public  function Contains(visual:RenderedObject):Bool{
		
		var success:Bool = (visual.restrictedCameras == null || visual.restrictedCameras.indexOf(name) != -1);
		
		if (success && (success = (((visual.x + visual.width) > (centerX - (viewportWidth*0.5) - buffer)) && (visual.x < (centerX + (viewportWidth *0.5)  + buffer)) && ((visual.y + visual.height) > (centerY - (viewportHeight *0.5) - buffer)) && (visual.y < (centerY + (viewportHeight*0.5) + buffer)))))
		{
			if (visual.displayingCameras != null){
				for (camera in visual.displayingCameras)
					if (camera == this.name) return success;
			
				visual.displayingCameras.add(this.name);
			}
			
		}
		else if (visual.displayingCameras != null)
			for (camera in visual.displayingCameras)
				if (camera == this.name){
					visual.displayingCameras.remove(this.name);
					break;
				}
		
	
		return success;
	}
	
	
	inline function get_viewportX():Float 
	{
		return transform.tx;
	}
	
	inline function set_viewportX(value:Float):Float 
	{
		if (transform.tx != value){
			needRenderUpdate = true;
			viewport.x = Math.round(value);		
		}
		return transform.tx = value;
	}
	
	inline function get_viewportY():Float 
	{
		return transform.ty;
	}
	
	inline function set_viewportY(value:Float):Float 
	{
		if (transform.ty != value){
			needRenderUpdate = true;
			viewport.y = Math.round(value);	
		}
		return transform.ty = value;
	}
		
	inline function get_name():String 
	{
		return name;
	}
	
	inline function set_name(value:String):String 
	{
		return name = value;
	}
	
	public function ToData():StructDataCamera
	{
		
		return {
			
			name:this.name,
			type:"Camera",
			zoom:transform.a,
			viewportWidth:this.viewportWidth,
			viewportHeight:this.viewportHeight,
			centerX:this.centerX,
			centerY:this.centerY,
			viewportX:transform.tx,
			viewportY:transform.ty,
			buffer:this.buffer,
			keepRatio:this.keepRatio,
			ratioX:ratios.x,
			ratioY:ratios.y,
			ratioWidth:ratios.width,
			ratioHeight:ratios.height
			
			
		}
		
	}
	
	public function ParseData(data:StructDataCamera):Void
	{
		this.name = data.name;
		zoom = data.zoom;
		viewportWidth = data.viewportWidth;
		viewportHeight = data.viewportHeight;
		centerX = data.centerX;
		centerY = data.centerY;
		transform.tx = data.viewportX;
		transform.ty = data.viewportY;
		buffer = data.buffer;
		keepRatio = data.keepRatio;
		if (keepRatio)	SetViewportRatios(data.ratioX, data.ratioY, data.ratioWidth, data.ratioHeight);
	
	}
	
	//To Do : update depending on the zoom
	inline function set_buffer(value:Float):Float 
	{
		if (buffer != value) needRenderUpdate = true;
		return buffer = value;
	}
	
	inline function set_centerX(value:Float):Float 
	{
		if(centerX != value) needRenderUpdate = true;
		return centerX = value;
	}
	
	inline function set_centerY(value:Float):Float 
	{
		if (centerY != value) needRenderUpdate = true;
		return centerY = value;
	}
	
	inline function set_viewportWidth(value:Float):Float 
	{
		trace("viewpotWidth changed");
		if (viewportWidth != value){
			needRenderUpdate = true;
			viewport.width = Math.round(value);	
		}
		
		return viewportWidth = value;
	}
	
	function set_viewportHeight(value:Float):Float 
	{
		if (viewportHeight != value){
			needRenderUpdate = true;
			viewport.height = Math.round(value);	
		}
		return viewportHeight = value;
	}
	
	public function AdjustResize():Void
	{
		if (keepRatio)
		{
			viewportX = BeardGame.Get().window.width * ratios.x;
			viewportY = BeardGame.Get().window.height * ratios.y;
			viewportWidth = BeardGame.Get().window.width * ratios.width;
			viewportHeight = BeardGame.Get().window.height * ratios.height;
			
		}
	}
	
	public function Update():Void
	{
		if (attachedObject != null)
			Center(attachedObject.x + attachedObject.width * 0.5, attachedObject.y + attachedObject.height * 0.5);
		
	}
	
}

typedef ViewportRect = 
{
	var x:Int;
	var y:Int;
	var width:Int;
	var height:Int;
	
}