package beardFramework.display.core;

import beardFramework.display.cameras.Camera;
import beardFramework.display.renderers.gl.BeardGLDisplayObject;
import beardFramework.interfaces.ICameraDependent;
import openfl._internal.renderer.RenderSession;
import openfl.display.Graphics;
import openfl.text.TextField;

/**
 * ...
 * @author Ludo
 */
class BeardTextField extends TextField implements ICameraDependent
{
	private var widthChanged:Bool;
	private var heightChanged:Bool;
	private var cachedWidth:Float;
	private var cachedHeight:Float;
	//override render
	public function new() 
	{
		super();
		displayingCameras = new List<String>();
	}
	
	
	public var restrictedCameras(default, null):Array<String>;
	public var displayingCameras(default, null):List<String>;
	
	public function AuthorizeCamera(addedCameraID:String):Void 
	{
		if (restrictedCameras == null) restrictedCameras = new Array<String>();
		
		if (restrictedCameras.indexOf(addedCameraID) == -1) restrictedCameras.push(addedCameraID);
	}
	
	public function ForbidCamera(forbiddenCameraID:String):Void 
	{
		if (restrictedCameras != null) restrictedCameras.remove(forbiddenCameraID);
	}
	
	public function RenderThroughCamera(camera:Camera, renderSession:RenderSession):Void 
	{
		BeardGLDisplayObject.renderThroughCamera(this, renderSession, camera);
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
	
	override function __updateLayout():Void 
	{
		super.__updateLayout();
		widthChanged = heightChanged = true;
	}
	
	override public function __update(transformOnly:Bool, updateChildren:Bool, ?maskGraphics:Graphics = null):Void 
	{
		super.__update(transformOnly, updateChildren, maskGraphics);
		if (!transformOnly) widthChanged = heightChanged = true;
	}
	
	override public function __updateChildren(transformOnly:Bool):Void 
	{
		super.__updateChildren(transformOnly);
		if (!transformOnly) widthChanged = heightChanged = true;
	}
	
	override function __updateText(value:String):Void 
	{
		super.__updateText(value);
		widthChanged = heightChanged = true;
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