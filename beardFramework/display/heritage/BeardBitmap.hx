package beardFramework.display.heritage;
import beardFramework.display.cameras.Camera;
import beardFramework.display.rendering.gl.BeardGLBitmap;
import beardFramework.interfaces.ICameraDependent;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.DisplayObject;
import openfl.display.Graphics;
import openfl.display.PixelSnapping;
import openfl._internal.renderer.RenderSession;


/**
 * reused of the bitmap code
 * @author Ludo
 */
class BeardBitmap extends Bitmap implements ICameraDependent
{
	private var widthChanged:Bool;
	private var heightChanged:Bool;
	private var cachedWidth:Float;
	private var cachedHeight:Float;
	public var restrictedCameras(default, null):Array<String>;
	public var displayingCameras(default, null):List<String>;
	public var mouseEnabled:Bool;
	
	public function new (bitmapData:BitmapData = null, pixelSnapping:PixelSnapping = null, smoothing:Bool = false) 
	{
		
		super (bitmapData, pixelSnapping,smoothing);
		mouseEnabled = false;
		heightChanged = widthChanged = true;
		displayingCameras = new List<String>();
	}
	
	public function AuthorizeCamera(addedCameraID : String):Void
	{
		if (restrictedCameras == null) restrictedCameras = new Array<String>();
		
		if (restrictedCameras.indexOf(addedCameraID) == -1) restrictedCameras.push(addedCameraID);
	}
	
	public function ForbidCamera(forbiddenCameraID : String):Void
	{
		if (restrictedCameras != null) restrictedCameras.remove(forbiddenCameraID);
	}
	
	public function RenderThroughCamera(camera:Camera, renderSession:RenderSession):Void
	{
		
		BeardGLBitmap.renderThroughCamera(this, renderSession, camera);
		
	}
	
	override function __hitTest(x:Float, y:Float, shapeFlag:Bool, stack:Array<DisplayObject>, interactiveOnly:Bool, hitObject:DisplayObject):Bool 
	{
		
		//trace("*****************  " + this.name +" hit Test");
		var success:Bool = super.__hitTest(x, y, shapeFlag, stack, interactiveOnly, hitObject);
		
		if (success && mouseEnabled && stack != null){
			//trace( this.name +" added to stack");
			stack.push(this);
		}
		
		return success;
	}
	
	override function set_bitmapData(value:BitmapData):BitmapData 
	{
		heightChanged = widthChanged = true;
		return super.set_bitmapData(value);
	}
	
	override public function __update(transformOnly:Bool, updateChildren:Bool, ?maskGraphics:Graphics = null):Void 
	{
		super.__update(transformOnly, updateChildren, maskGraphics);
		if (!transformOnly) widthChanged = heightChanged = true;
	}
	
	
	/* INTERFACE beardFramework.interfaces.ICameraDependent */
	
	public function RenderMaskThroughCamera(camera:Camera, renderSession:RenderSession):Void 
	{
		BeardGLBitmap.renderMaskThroughCamera(this, renderSession, camera);
	}
	
	override function set_width(value:Float):Float 
	{
		widthChanged = true;
		return super.set_width(value);
	}
	
	override function get_width():Float 
	{
		if (widthChanged){
			cachedWidth = super.get_width();
			widthChanged = false;
		}
		return cachedWidth;
	}
	
	override function get_height():Float 
	{
		if (heightChanged){
			cachedHeight = super.get_height();
			heightChanged = false;
		}
		return cachedHeight;
	}
	
	override function set_height(value:Float):Float 
	{
		heightChanged = true;
		return super.set_height(value);
	}
	
	override function set_scaleX(value:Float):Float 
	{
		widthChanged = true;
		return super.set_scaleX(value);
	}
	
	override function set_scaleY(value:Float):Float 
	{
		heightChanged = true;
		return super.set_scaleY(value);
	}
	
	
	
	
}