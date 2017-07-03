package beardFramework.displaySystem;


import beardFramework.displaySystem.cameras.Camera;
import beardFramework.interfaces.ICameraDependent;
import openfl.display.Graphics;
import openfl.display.Sprite;

/**
 * ...
 * @author Ludo
 */
class BeardSprite extends Sprite implements ICameraDependent{
	
	private var widthChanged:Bool;
	private var heightChanged:Bool;
	private var cachedWidth:Float;
	private var cachedHeight:Float;
	public var restrictedCameras(default, null):Array<String>;

	public function new () 
	{
		
		super ();
		
		widthChanged = heightChanged = true;
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
	
	public function RenderThroughCamera(camera:Camera):Void
	{
		
	
		
	}
	
	override public function __update(transformOnly:Bool, updateChildren:Bool, ?maskGraphics:Graphics = null):Void 
	{
		super.__update(transformOnly, updateChildren, maskGraphics);
		if (!transformOnly) widthChanged = heightChanged = true;
	}
	
	override public function __updateChildren (transformOnly:Bool):Void 
	{
		
		super.__updateChildren (transformOnly);
		
		if(!transformOnly) 	widthChanged = heightChanged = true;
	}
	
	//override function set_width(value:Float):Float 
	//{
		//widthChanged = true;
		//return super.set_width(value);
	//}
	
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
	
	//override function set_height(value:Float):Float 
	//{
		//heightChanged = true;
		//return super.set_height(value);
	//}
	
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
	
	override function get_graphics():Graphics 
	{
		widthChanged = heightChanged = true;
		return super.get_graphics();
	}
	
	
	
}