package beardFramework.display.heritage;

import beardFramework.display.cameras.Camera;
import beardFramework.display.rendering.gl.BeardGLDisplayObject;
import beardFramework.interfaces.ICameraDependent;
import openfl.display.DisplayObject;
import openfl.display.Graphics;
import openfl.display.Sprite;
import openfl._internal.renderer.RenderSession;
import openfl.geom.Point;

@:access(openfl.display.Graphics)
@:access(openfl.geom.Point)

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
	public var displayingCameras(default, null):List<String>;
	private var hitFocusOverChildren:Bool;

	public function new () 
	{
		
		super ();
		
		widthChanged = heightChanged = true;
		displayingCameras = new List<String>();
		hitFocusOverChildren = true;
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
		
		BeardGLDisplayObject.renderThroughCamera(this, renderSession, camera);
		
		var utilX:Float;
		var utilY:Float;
		var childSharesCam:Bool;
		for (child in __children) {
			
			if (Std.is(child, ICameraDependent)){
						
				//cast(child, ICameraDependent).displayingCameras.remove(camera.name);
				//cast(child, ICameraDependent).displayingCameras.add(camera.name);
			
				childSharesCam = false;
				for (cam in cast(child, ICameraDependent).displayingCameras)
					if (childSharesCam = (cam == camera.name)) break;
			
				if (!childSharesCam) cast(child, ICameraDependent).displayingCameras.add(camera.name);
				cast(child, ICameraDependent).RenderThroughCamera(camera, renderSession);
			}
			else{
				utilX = child.__transform.tx;
				utilY = child.__transform.ty;
				child.__transform.tx = camera.viewportX +(utilX - camera.centerX);
				child.__transform.ty = camera.viewportY + (utilY - camera.centerY);
				child.__update(true, true);
				child.__renderGL (renderSession);
				child.__transform.tx = utilX;
				child.__transform.ty = utilY;
			}
			
		}
		
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
	
	public function beardHitTest(x:Float, y:Float, shapeFlag:Bool, stack:Array<DisplayObject>, interactiveOnly:Bool, hitObject:DisplayObject):Bool 
	{
		var stackSize : Int = stack!= null? stack.length:0;
		super.__hitTest(x, y, shapeFlag, stack, interactiveOnly, hitObject);
		if (stack != null && stack.length > stackSize) stack.push(this);		
		return true;
	}
	
	
	/* INTERFACE beardFramework.interfaces.ICameraDependent */
	
	public function RenderMaskThroughCamera(camera:Camera, renderSession:RenderSession):Void 
	{
		//BeardGLDisplayObject.renderThroughCamera(this, renderSession, camera);
	}
	
	override private function __hitTest(x:Float, y:Float, shapeFlag:Bool, stack:Array<DisplayObject>, interactiveOnly:Bool, hitObject:DisplayObject):Bool 
	{
		
		//trace("*****************  " + this.name +" hit Test");
		var stackSize : Int = stack != null? stack.length:0;
		var success:Bool = false;
		
		super.__hitTest(x, y, shapeFlag, stack, interactiveOnly, hitObject);
		
		if (stack != null && stack.length > stackSize){
			success = true;
			//trace("---------------------------" + this.name +"      hit succeeded");
			if (hitFocusOverChildren == true){
				stack.push(this);	
				//trace(this.name + "  added to stack");
			}
		}
		return success;
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