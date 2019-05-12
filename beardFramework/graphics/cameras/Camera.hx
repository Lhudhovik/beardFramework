package beardFramework.graphics.cameras;
import beardFramework.core.BeardGame;
import beardFramework.graphics.core.RenderedObject;
import beardFramework.graphics.core.BatchedVisual;
import beardFramework.graphics.rendering.Framebuffer;
import beardFramework.graphics.rendering.Renderer;
import beardFramework.interfaces.ICameraDependent;
import beardFramework.resources.save.data.StructDataCamera;
import beardFramework.utils.data.DataU;
import beardFramework.utils.graphics.Color;
import beardFramework.utils.libraries.StringLibrary;
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
	public var zoom(default, set):Float;
	public var viewportWidth(get,set):Float;
	public var viewportHeight(get, set):Float;
	public var centerX(default, set):Float;
	public var centerY(default, set):Float;
	public var viewportX(default, set):Float;
	public var viewportY(default, set):Float;
	public var buffer(default, set):Float;
	public var needViewUpdate:Bool;
	public var keepRatio(default, set):Bool;
	public var framebuffer:Framebuffer;
	public var clearColor:Color;
	
	
	public var viewport(default, null):ViewportRect;
	public var view:Matrix4;
	public var projection:Matrix4;
	private var attachedObject:RenderedObject;
	private var dimensionsRatio:Float; // height/width
	private var screenRatios:SRect;
	private var width(default, set):Float;
	private var height(default, set):Float;
	
	public function new(name:String, viewPortWidth:Float = 100, viewPortHeight:Float = 57, viewPortX:Float = 0, viewPortY:Float = 0, buffer : Float = 100, keepRatio:Bool = true, clearColor:Color = Color.BLACK) 
	{
		
		viewport = {x:0,y:0,width:0,height:0}	
		
		this.name = name;
		this.width  = viewPortWidth;
		this.height  = viewPortHeight;
		this.dimensionsRatio = height / width;
		this.viewportX = viewPortX;
		this.viewportY = viewPortY;
		viewport.width = Math.round(width);	
		viewport.height = Math.round(height);	
		this.buffer = buffer;
		zoom = 1;
		this.clearColor = clearColor;
		this.keepRatio = keepRatio;
		
		screenRatios = {
			x: viewportX / BeardGame.Get().window.width,
			y:  viewportY / BeardGame.Get().window.height,
			width: width / BeardGame.Get().window.width,
			height: height / BeardGame.Get().window.height
		}
				
		centerX = 0;
		centerY = 0;
		
		projection = new Matrix4();
		projection.identity();
		//projection.createOrtho( 0,width, height, 0, Renderer.Get().VISIBLEDEPTHLIMIT, -Renderer.Get().VISIBLEDEPTHLIMIT);
		projection.createOrtho( 0,BeardGame.Get().window.width, BeardGame.Get().window.height, 0, Renderer.Get().VISIBLEDEPTHLIMIT, -Renderer.Get().VISIBLEDEPTHLIMIT);
		view = new Matrix4();
		needViewUpdate = true;
		
		framebuffer = new Framebuffer();
		framebuffer.Bind(GL.FRAMEBUFFER);
		framebuffer.CreateTexture(StringLibrary.COLOR, BeardGame.Get().window.width, BeardGame.Get().window.height, GL.RGB, GL.RGB, GL.UNSIGNED_BYTE, GL.COLOR_ATTACHMENT0,true);
		framebuffer.CreateRenderBuffer(StringLibrary.DEPTH, GL.RENDERBUFFER, GL.DEPTH24_STENCIL8, BeardGame.Get().window.width, BeardGame.Get().window.height, GL.DEPTH_STENCIL_ATTACHMENT);
		
		framebuffer.quad.width = viewport.width;
		framebuffer.quad.height = viewport.height;
		framebuffer.quad.x = viewport.x;
		framebuffer.quad.y = viewport.y;
		
		framebuffer.UnBind(GL.FRAMEBUFFER);
	}
	
	public function SetViewportRatios(x:Float, y: Float, width:Float, height:Float,keepRatio:Bool = true):Void
	{
		
		this.keepRatio = false;
		screenRatios.x=x;
		screenRatios.y=y;
		screenRatios.width=width;
		screenRatios.height=height;
		
		//viewportX = BeardGame.Get().window.width * x;
		//viewportY = BeardGame.Get().window.height * y;
		//this.width = BeardGame.Get().window.width * width;
		//this.height  = BeardGame.Get().window.height * height;
		
		AdjustResize();
	
		this.keepRatio = keepRatio;
	}
		
	inline public function SetDimensions(width:Float, height:Float, keepRatio:Bool=true):Void
	{
		this.keepRatio = false;
		this.width = width;
		this.height = height;
		this.keepRatio = keepRatio;
		
	}
	
	public function set_zoom(newZoom:Float):Float
	{
		
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
	
	public  function Contains(visual:RenderedObject):Bool
	{
		
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
			ratioX:screenRatios.x,
			ratioY:screenRatios.y,
			ratioWidth:screenRatios.width,
			ratioHeight:screenRatios.height,
			additionalData:""
			
			
		}
		
	}
	
	public function ParseData(data:StructDataCamera):Void
	{
		this.name = data.name;
		zoom = data.zoom;
		this.width = data.viewportWidth;
		this.height = data.viewportHeight;
		centerX = data.centerX;
		centerY = data.centerY;
		viewportX = data.viewportX;
		viewportY= data.viewportY;
		buffer = data.buffer;
		keepRatio = data.keepRatio;
		screenRatios.x = data.ratioX;
		screenRatios.y = data.ratioY;
		screenRatios.width = data.ratioWidth;
		screenRatios.height = data.ratioHeight;
			
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
		
		if (width != value){
	
			width = value;
		
			if (keepRatio)
			{
				height = width * dimensionsRatio;
			}
			
		}
		
		return width;
	}
	
	inline function set_viewportHeight(value:Float):Float 
	{
		if (height != value){
			
			height = value;
			
			if (keepRatio)
			{
				width = height / dimensionsRatio;
			}
		}
		return height;
	}
	
	inline function get_viewportWidth():Float return width;
	
	inline function get_viewportHeight():Float return height;
	
	
	public function AdjustResize():Void
	{
		//
		framebuffer.Bind(GL.FRAMEBUFFER);
		GL.enable(GL.DEPTH_TEST);
		GL.clearColor(clearColor.getRedf(), clearColor.getGreenf(), clearColor.getBluef(),1);
		GL.clear(GL.COLOR_BUFFER_BIT);
		GL.clear(GL.DEPTH_BUFFER_BIT);
		
		
		if (keepRatio)
		{
			
			viewportX = BeardGame.Get().window.width * screenRatios.x;
			viewportY = BeardGame.Get().window.height * screenRatios.y;
			var newWidth:Float = BeardGame.Get().window.width * screenRatios.width;
			var newHeight:Float = BeardGame.Get().window.height * screenRatios.height;
			
			if(newWidth < newHeight)  
			viewportWidth = newWidth;
			else viewportHeight = newHeight;
			
		}
		else
		{
			//trace(screenRatios.height);
			viewportX = BeardGame.Get().window.width * screenRatios.x;
			viewportY = BeardGame.Get().window.height * screenRatios.y;
			viewportWidth = BeardGame.Get().window.width * screenRatios.width;
			viewportHeight = BeardGame.Get().window.height * screenRatios.height;
		
		}
		if (projection != null)
		{
			projection.identity();
			projection.createOrtho( 0,BeardGame.Get().window.width, BeardGame.Get().window.height, 0, Renderer.Get().VISIBLEDEPTHLIMIT, -Renderer.Get().VISIBLEDEPTHLIMIT);
		}
		
		if (framebuffer != null && framebuffer.quad != null){
			framebuffer.UpdateTextureSize(StringLibrary.COLOR, viewport.width, viewport.height);
			framebuffer.quad.shader.Use();
			framebuffer.quad.shader.SetMatrix4fv(StringLibrary.PROJECTION, Renderer.Get().projection);
			framebuffer.quad.width = viewport.width;
			framebuffer.quad.height = viewport.height;
		}
		
		framebuffer.UnBind(GL.FRAMEBUFFER);
		needViewUpdate = true;
	}
	
	public function UpdateView():Void
	{
		
		view.identity();
		view.appendRotation(this.rotation, new Vector4(0, 0, 1));
		view.appendScale(zoom, zoom, 1);
		view.appendTranslation(  viewportWidth*0.5 -centerX,  viewportHeight*0.5 - centerY, -1);
		
		//DataU.DeepTrace(view);
		
		if (framebuffer != null && framebuffer.quad != null){
				framebuffer.quad.x = viewportX;
				framebuffer.quad.y = viewportY;
		}
	
		
		needViewUpdate = false;
	}
	
	public function Update():Void
	{
		if (attachedObject != null)
			Center(attachedObject.x + attachedObject.width * 0.5, attachedObject.y + attachedObject.height * 0.5);
			
		if (needViewUpdate) UpdateView();
		
	}
	
	function set_keepRatio(value:Bool):Bool 
	{
		
		if (keepRatio != value && value == true)
		{
			dimensionsRatio = height / width;
		}
		
		return keepRatio = value;
	}
	
	function set_width(value:Float):Float 
	{
		if (width != value){
			viewport.width = Math.round(value);
			needViewUpdate = true;	
		}
		return width = value;
	}
	
	function set_height(value:Float):Float 
	{
		if (height != value){
			viewport.height = Math.round(value);
			needViewUpdate = true;	
		}
		return height = value;
	}
	
}

typedef ViewportRect = 
{
	var x:Int;
	var y:Int;
	var width:Int;
	var height:Int;
	
}