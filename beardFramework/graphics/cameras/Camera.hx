package beardFramework.graphics.cameras;
import beardFramework.core.BeardGame;
import beardFramework.graphics.core.RenderedObject;
import beardFramework.graphics.core.BatchedVisual;
import beardFramework.graphics.rendering.Framebuffer;
import beardFramework.graphics.rendering.Renderer;
import beardFramework.interfaces.ICameraDependent;
import beardFramework.resources.save.data.StructDataCamera;
import beardFramework.utils.data.DataU;
import beardFramework.utils.simpleDataStruct.SRect;
import lime.graphics.opengl.GL;
import lime.graphics.opengl.GLFramebuffer;
import lime.math.Matrix4;
import openfl.display.Tile;
import openfl.geom.Point;
import openfl.geom.Rectangle;


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
	public var zoom(default,set):Float;
	public var viewportWidth(default, set):Float;
	public var viewportHeight(default, set):Float;
	public var centerX(default, set):Float;
	public var centerY(default, set):Float;
	public var viewportX(default, set):Float;
	public var viewportY(default, set):Float;
	public var buffer(default, set):Float;
	public var needViewUpdate:Bool;
	public var keepRatio:Bool;
	public var ratios:SRect;
	public var framebuffer:Framebuffer;
	
	
	public var viewport(default, null):ViewportRect;
	public var view:Matrix4;
	public var projection:Matrix4;
	private var attachedObject:RenderedObject;
	
	
	
	public function new(name:String, viewPortWidth:Float = 100, viewPortHeight:Float = 57, viewPortX:Float = 0, viewPortY:Float = 0, buffer : Float = 100, keepRatio:Bool = false) 
	{
		
		viewport = {x:0,y:0,width:0,height:0}	
		
		this.name = name;
		this.viewportWidth  = viewPortWidth;
		this.viewportHeight  = viewPortHeight;
		this.viewportX = viewPortX;
		this.viewportY = viewPortY;
		this.buffer = buffer;
		zoom = 1;
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
		
		projection = new Matrix4();
		projection.identity();
		//projection.createOrtho( 0,viewportWidth, viewportHeight, 0, Renderer.Get().VISIBLEDEPTHLIMIT, -Renderer.Get().VISIBLEDEPTHLIMIT);
		projection.createOrtho( 0,BeardGame.Get().window.width, BeardGame.Get().window.height, 0, Renderer.Get().VISIBLEDEPTHLIMIT, -Renderer.Get().VISIBLEDEPTHLIMIT);
		view = new Matrix4();
		needViewUpdate = true;
		
		framebuffer = new Framebuffer();
		framebuffer.Bind(GL.FRAMEBUFFER);
		framebuffer.CreateTexture("color", BeardGame.Get().window.width, BeardGame.Get().window.height, GL.RGB, GL.RGB, GL.UNSIGNED_BYTE, GL.COLOR_ATTACHMENT0);
		framebuffer.CreateRenderBuffer("depth", GL.RENDERBUFFER, GL.DEPTH24_STENCIL8, BeardGame.Get().window.width, BeardGame.Get().window.height, GL.DEPTH_STENCIL_ATTACHMENT);
		framebuffer.UnBind(GL.FRAMEBUFFER);
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
	
	public function set_zoom(newZoom:Float):Float{
		
		if (newZoom <= 0) newZoom = MINZOOM;
		
		if (newZoom != zoom)
		{
			buffer *= zoom;
			buffer /= newZoom;
			needViewUpdate = true;
		}
		
		return zoom = newZoom;
	}
	
	public inline function Center(centerX:Float=0, centerY:Float=0):Void
	{
		this.centerX = centerX;
		this.centerY = centerY;	
		needViewUpdate = true;
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
		utilRect.x = viewportX;
		utilRect.y = viewportY;
		
		return utilRect;
	}

	public function ContainsPoint(point:Point):Bool
	{
		if (utilRect == null)
		utilRect = new Rectangle( );
		
		utilRect.width = this.viewportWidth;
		utilRect.height = this.viewportHeight;
		utilRect.x = viewportX;
		utilRect.y = viewportY;
		
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
	
	
	
	inline function set_viewportX(value:Float):Float 
	{
		if (viewportX != value){
			needViewUpdate = true;
			viewport.x = Math.round(value);		
		}
		return viewportX = value;
	}
	
	inline function get_viewportY():Float 
	{
		return viewportY;
	}
	
	inline function set_viewportY(value:Float):Float 
	{
		if (viewportY != value){
			needViewUpdate = true;
			viewport.y = Math.round(value);	
		}
		return viewportY = value;
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
			zoom:zoom,
			viewportWidth:this.viewportWidth,
			viewportHeight:this.viewportHeight,
			centerX:this.centerX,
			centerY:this.centerY,
			viewportX:viewportX,
			viewportY:viewportY,
			buffer:this.buffer,
			keepRatio:this.keepRatio,
			ratioX:ratios.x,
			ratioY:ratios.y,
			ratioWidth:ratios.width,
			ratioHeight:ratios.height,
			additionalData:""
			
			
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
		viewportX = data.viewportX;
		viewportY= data.viewportY;
		buffer = data.buffer;
		keepRatio = data.keepRatio;
		if (keepRatio)	SetViewportRatios(data.ratioX, data.ratioY, data.ratioWidth, data.ratioHeight);
		
		needViewUpdate = true;
	
	}
	
	//To Do : update depending on the zoom
	inline function set_buffer(value:Float):Float 
	{
		if (buffer != value) needViewUpdate = true;
		return buffer = value;
	}
	
	inline function set_centerX(value:Float):Float 
	{
		if(centerX != value) needViewUpdate = true;
		return centerX = value;
	}
	
	inline function set_centerY(value:Float):Float 
	{
		if (centerY != value) needViewUpdate = true;
		return centerY = value;
	}
	
	inline function set_viewportWidth(value:Float):Float 
	{
		
		if (viewportWidth != value){
			viewport.width = Math.round(value);	
			if (projection != null)
			{
				projection.identity();
				//projection.createOrtho( 0,value, viewportHeight, 0, Renderer.Get().VISIBLEDEPTHLIMIT, -Renderer.Get().VISIBLEDEPTHLIMIT);
				projection.createOrtho( 0,BeardGame.Get().window.width, BeardGame.Get().window.height, 0, Renderer.Get().VISIBLEDEPTHLIMIT, -Renderer.Get().VISIBLEDEPTHLIMIT);
			}
			
			needViewUpdate = true;	
		}
		
		return viewportWidth = value;
	}
	
	function set_viewportHeight(value:Float):Float 
	{
		if (viewportHeight != value){
			viewport.height = Math.round(value);
			if (projection != null)
			{
				projection.identity();
				//projection.createOrtho( 0, viewportWidth,  value, 0, Renderer.Get().VISIBLEDEPTHLIMIT, -Renderer.Get().VISIBLEDEPTHLIMIT);
				projection.createOrtho( 0,BeardGame.Get().window.width, BeardGame.Get().window.height, 0, Renderer.Get().VISIBLEDEPTHLIMIT, -Renderer.Get().VISIBLEDEPTHLIMIT);
			}
			needViewUpdate = true;
			
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
			if (projection != null)
			{
				projection.identity();
				//projection.createOrtho( 0, viewportWidth,  viewportHeight, 0, Renderer.Get().VISIBLEDEPTHLIMIT, -Renderer.Get().VISIBLEDEPTHLIMIT);
				projection.createOrtho( 0,BeardGame.Get().window.width, BeardGame.Get().window.height, 0, Renderer.Get().VISIBLEDEPTHLIMIT, -Renderer.Get().VISIBLEDEPTHLIMIT);
			}
			needViewUpdate = true;
		}
	}
	
	public function UpdateView():Void
	{
		
		view.identity();
		view.appendScale(zoom,zoom,1);
		view.appendTranslation( (viewportX + viewportWidth * 0.5) - centerX, (viewportY + viewportHeight * 0.5) - centerY, -1);
		//view.appendRotation(this.rotation, new Vector4(0, 0, 1));
		//DataU.DeepTrace(view);
		
		framebuffer.UpdateTextureSize("color", viewport.width, viewport.height);
		
		needViewUpdate = false;
	}
	
	public function Update():Void
	{
		if (attachedObject != null)
			Center(attachedObject.x + attachedObject.width * 0.5, attachedObject.y + attachedObject.height * 0.5);
			
		if (needViewUpdate) UpdateView();
		
	}
	
}

typedef ViewportRect = 
{
	var x:Int;
	var y:Int;
	var width:Int;
	var height:Int;
	
}