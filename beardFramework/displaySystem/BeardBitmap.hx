package beardFramework.displaySystem;

import beardFramework.interfaces.ICameraDependent;
import openfl._internal.renderer.RenderSession;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.PixelSnapping;
import openfl.geom.Matrix;
import openfl.geom.Rectangle;

/**
 * ...
 * @author Ludo
 */
class BeardBitmap extends Bitmap implements ICameraDependent
{
	private var widthChanged:Bool;
	private var heightChanged:Bool;
	private var cachedWidth:Float;
	private var cachedHeight:Float;
	public var restrictedCameras(default,null):Array<String>;
	public function new(bitmapData:BitmapData=null, pixelSnapping:PixelSnapping=null, smoothing:Bool=false) 
	{
		super(bitmapData, pixelSnapping, smoothing);
		heightChanged = widthChanged = true;
	}
	//as soon as we authorize a camera, others won't display the bitmap unless they are authorized too
	public function AuthorizeCamera(addedCameraID : String):Void
	{
		if (restrictedCameras == null) restrictedCameras = new Array<String>();
		
		if (restrictedCameras.indexOf(addedCameraID) == -1) restrictedCameras.push(addedCameraID);
	}
	public function ForbidCamera(forbiddenCameraID : String):Void
	{
		if (restrictedCameras != null) restrictedCameras.remove(forbiddenCameraID);
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
	
	
	override function __renderCairo(renderSession:RenderSession):Void 
	{
		super.__renderCairo(renderSession);
	}
	override function __renderDOM(renderSession:RenderSession):Void 
	{
		super.__renderDOM(renderSession);
	}
	override function __renderGL(renderSession:RenderSession):Void 
	{
		super.__renderGL(renderSession);
	}
	override function __renderCanvas(renderSession:RenderSession):Void 
	{
		super.__renderCanvas(renderSession);
	}

}