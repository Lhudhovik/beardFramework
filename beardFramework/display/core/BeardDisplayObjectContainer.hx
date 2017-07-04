package beardFramework.display.core;

import beardFramework.interfaces.ICameraDependent;
import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;
import openfl.display.Graphics;


/**
 * reused of the bitmap code
 * @author Ludo
 */
class BeardDisplayObjectContainer extends DisplayObjectContainer implements ICameraDependent{
	
	
	private var widthChanged:Bool;
	private var heightChanged:Bool;
	private var cachedWidth:Float;
	private var cachedHeight:Float;
	public var restrictedCameras(default, null):Array<String>;
	
	private function new () 
	{
		
		super ();
		
		mouseChildren = true;
		
		__children = new Array<DisplayObject> ();
		__removedChildren = new Vector<DisplayObject> ();
		__tempStack = new Vector<DisplayObject> ();
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
	
	public function RenderThroughCamera(camera:Camera):Void{
		
	
		
	}
		
	override public function addChildAt(child:DisplayObject, index:Int):DisplayObject 
	{
		widthChanged = heightChanged = true;
		return super.addChildAt(child, index);
	}
		
	override public function removeChild(child:DisplayObject):DisplayObject 
	{
		widthChanged = heightChanged = true;
		return super.removeChild(child);
	}
	
	override public function removeChildren(beginIndex:Int = 0, endIndex:Int = 0x7FFFFFFF):Void 
	{
		widthChanged = heightChanged = true;
		super.removeChildren(beginIndex, endIndex);
	}
	
	override public function __update (transformOnly:Bool, updateChildren:Bool, ?maskGraphics:Graphics = null):Void {
		
		super.__update (transformOnly, updateChildren, maskGraphics);
		
		if (!transformOnly) widthChanged = heightChanged = true;
		
	}
	
	
	override public function __updateChildren (transformOnly:Bool):Void {
		
		super.__updateChildren (transformOnly);
		
		if(!transformOnly) 	widthChanged = heightChanged = true;
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
	
	
	
	
}