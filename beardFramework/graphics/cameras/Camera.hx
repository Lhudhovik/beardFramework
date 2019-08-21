package beardFramework.graphics.cameras;
import beardFramework.core.BeardGame;
import beardFramework.graphics.objects.RenderedObject;
import beardFramework.graphics.core.BatchedVisual;
import beardFramework.graphics.core.Framebuffer;
import beardFramework.graphics.core.Renderer;
import beardFramework.input.MousePos;
import beardFramework.interfaces.IBeardyObject;
import beardFramework.resources.save.data.StructDataCamera;
import beardFramework.utils.data.DataU;
import beardFramework.utils.graphics.Color;
import beardFramework.utils.libraries.StringLibrary;
import beardFramework.utils.math.MathU;
import beardFramework.utils.simpleDataStruct.SRect;
import beardFramework.utils.simpleDataStruct.SVec2;
import lime.graphics.opengl.GL;
import lime.graphics.opengl.GLFramebuffer;
import lime.math.Matrix4;
import lime.math.Vector4;
import openfl.display.Tile;
import openfl.geom.Point;
import openfl.geom.Rectangle;

/**
 * ...
 * @author Ludo
 */
class Camera implements IBeardyObject
{
	private static var utilRect:Rectangle;
	public static var DEFAULT(default, null):String = "default";
	public static var MINZOOM(default, null):Float = 0.00001;

	@:isVar public var name(get, set):String;
	@:isVar public var group(get, set):String;
	
	
	public var isActivated(default, null):Bool;
	public var zoom(default, set):Float;
	public var centerX(default, set):Float;
	public var centerY(default, set):Float;
	public var buffer(default, set):Float;
	public var needViewUpdate:Bool;
	public var framebuffer:Framebuffer;
	public var clearColor:Color;
	public var widthRatio(default, set):Float;
	public var heightRatio(default, set):Float;
	public var view:Matrix4;
	public var projection:Matrix4;
	private var attachedObject:RenderedObject;

	private var width:Float;
	private var height:Float;

	public function new(name:String, widthRatio:Float = 1, heightRatio:Float = 1, buffer : Float = 100, clearColor:Color = Color.BLACK)
	{

		this.name = name;
		this.buffer = buffer;
		this.width = BeardGame.Get().window.width * widthRatio;
		this.height = BeardGame.Get().window.height * heightRatio;
		zoom = 1;
		this.clearColor = clearColor;

		centerX = 0;
		centerY = 0;

		projection = new Matrix4();
		view = new Matrix4();
		
		framebuffer = new Framebuffer(StringLibrary.DEFAULT);
		framebuffer.Bind();

		var width:Int = Std.int(width);
		var height:Int = Std.int(height);


		
		framebuffer.CreateTexture(StringLibrary.COLOR, width, height, GL.RGBA16F, GL.RGBA, GL.FLOAT, GL.COLOR_ATTACHMENT0);
		framebuffer.CreateTexture(StringLibrary.COLOR+1, width, height, GL.RGBA16F, GL.RGBA, GL.FLOAT, GL.COLOR_ATTACHMENT1);

		framebuffer.CreateRenderBuffer(StringLibrary.DEPTH, GL.RENDERBUFFER, GL.DEPTH24_STENCIL8,width,height, GL.DEPTH_STENCIL_ATTACHMENT);

		GL.drawBuffers([GL.COLOR_ATTACHMENT0, GL.COLOR_ATTACHMENT1]);
		
		framebuffer.CheckStatus("Creation");
		framebuffer.UnBind();
		
	
		this.widthRatio  = widthRatio;
		this.heightRatio  = heightRatio;
		AdjustResize();
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

	inline public function GetWidth():Float
	{

		return width;
	}

	inline public function GetHeight():Float
	{

		return height;
	}

	public function GetRect():Rectangle
	{
		if (utilRect == null)
			utilRect = new Rectangle();

		utilRect.width = GetWidth() /zoom;
		utilRect.height = GetHeight()/zoom;
		utilRect.x = 0;
		utilRect.y = 0;

		return utilRect;
	}

	public function ContainsPoint(point:Point):Bool
	{
		if (utilRect == null)
			utilRect = GetRect();

		return utilRect.containsPoint(point);

	}

	public  function Contains(visual:RenderedObject):Bool
	{

		var success:Bool = (visual.HasCamera(this.name));

		if (success && (success = (((visual.x + visual.width) > (centerX - (GetWidth()*0.5) - buffer)) && (visual.x < (centerX + (GetWidth() *0.5)  + buffer)) && ((visual.y + visual.height) > (centerY - (GetHeight() *0.5) - buffer)) && (visual.y < (centerY + (GetHeight()*0.5) + buffer)))))
		{
			if (visual.cameras != null)
			{
				for (camera in visual.cameras)
					if (camera == this.name) return success;

				visual.cameras.add(this.name);
			}

		}
		else if (visual.cameras != null)
			for (camera in visual.cameras)
				if (camera == this.name)
				{
					visual.cameras.remove(this.name);
					break;
				}

		return success;
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
			centerX:this.centerX,
			centerY:this.centerY,
			buffer:this.buffer,
			widthRatio:this.widthRatio,
			heightRatio: this.heightRatio,
			additionalData:""

		}

	}

	public function ParseData(data:StructDataCamera):Void
	{
		this.name = data.name;
		zoom = data.zoom;
		centerX = data.centerX;
		centerY = data.centerY;
		buffer = data.buffer;
		widthRatio = data.widthRatio;
		heightRatio = data.heightRatio;
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
		if (centerX != value) needViewUpdate = true;
		return centerX = value;
	}

	inline function set_centerY(value:Float):Float
	{
		if (centerY != value) needViewUpdate = true;
		return centerY = value;
	}

	public function AdjustResize():Void
	{

		width = BeardGame.Get().window.width * this.widthRatio;
		height =  BeardGame.Get().window.height * this.heightRatio;

		//
		framebuffer.Bind();
		//GL.enable(GL.DEPTH_TEST);
		GL.clearColor(clearColor.getRedf(), clearColor.getGreenf(), clearColor.getBluef(),1);
		GL.clear(GL.COLOR_BUFFER_BIT);
		GL.clear(GL.DEPTH_BUFFER_BIT);

		if (projection != null)
		{
			projection.identity();
			projection.createOrtho( 0,width,height, 0, Renderer.Get().VISIBLE, -Renderer.Get().VISIBLE);
		}

		
		
		//framebuffer.UpdateTextureSize("", Std.int(width), Std.int(height));
		//framebuffer.UpdateRenderBufferSize("", Std.int(width), Std.int(height));
	
		framebuffer.CheckStatus("Adjust Resized");
		framebuffer.UnBind();
		needViewUpdate = true;
	}

	public function UpdateView():Void
	{

		view.identity();
		view.appendScale(zoom, zoom, 1);
		view.appendTranslation(  GetWidth()*0.5 -centerX,  GetHeight()*0.5 - centerY, -1);
		view.appendRotation(0.1, new Vector4(0, 1, 0));
		needViewUpdate = false;
	}

	public inline function GetMousePos():SVec2
	{
		return {x: MousePos.current.x - (GetWidth()*0.5 - centerX), y:MousePos.current.y - (GetHeight()*0.5 - centerY) };
	}

	public function Update():Void
	{
		if (attachedObject != null)
			Center(attachedObject.x + attachedObject.width * 0.5, attachedObject.y + attachedObject.height * 0.5);

		if (needViewUpdate) UpdateView();

	}
	
	public function Activate():Void 
	{
		isActivated = true;
	}
	
	public function DeActivate():Void 
	{
		isActivated = false;
	}
	
	public function Destroy():Void 
	{
		
	}
	
	function get_group():String 
	{
		return group;
	}
	
	function set_group(value:String):String 
	{
		return group = value;
	}

	function set_heightRatio(value:Float):Float 
	{
		if (value != heightRatio)
		{
			heightRatio = value;
			AdjustResize();
			
		}
		return heightRatio;
	}

	
	function set_widthRatio(value:Float):Float 
	{
		if (value != widthRatio)
		{
			widthRatio = value;
			AdjustResize();
			
		}
		return widthRatio;
	}

}

typedef ViewportRect =
{
	var x:Int;
	var y:Int;
	var width:Int;
	var height:Int;

}