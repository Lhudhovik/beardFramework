package beardFramework.display.core;

import beardFramework.core.BeardGame;
import beardFramework.display.cameras.Camera;
import beardFramework.interfaces.ICameraDependent;
import openfl._internal.renderer.RenderSession;
import openfl._internal.renderer.opengl.GLDisplayObject;
import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;
import openfl.geom.Point;
import openfl.geom.Rectangle;

@:access(openfl.geom.Point)
@:access(openfl.geom.Rectangle)

/**
 * ...
 * @author Ludo
 */
class BeardLayer extends DisplayObjectContainer
{

	public function new(name:String) 
	{
		super();
		this.name = name;
	}

	private override function __renderGL (renderSession:RenderSession):Void 
	{
		
		if (!__renderable || __worldAlpha <= 0) return;
		
		GLDisplayObject.render (this, renderSession);
		
		var utilX:Float;
		var utilY:Float;
	
		renderSession.filterManager.pushObject (this);
		
		for (camera in BeardGame.Get().cameras.iterator()){
		
			renderSession.maskManager.pushRect (camera.GetRect(), camera.transform);
			
			for (child in __children) {
				if (camera.Contains(child)){
					
					
					if (Std.is(child, ICameraDependent)){
						
						cast(child, ICameraDependent).displayingCameras.remove(camera.name);
						cast(child, ICameraDependent).displayingCameras.add(camera.name);
						cast(child, ICameraDependent).RenderThroughCamera(camera, renderSession);
					}
					else{
						utilX = child.__transform.tx;
						utilY = child.__transform.ty;
						child.__transform.tx = camera.viewportX +(utilX - camera.cameraX);
						child.__transform.ty = camera.viewportY + (utilY - camera.cameraY);
						child.__update(true, true);
						child.__renderGL (renderSession);
						child.__transform.tx = utilX;
						child.__transform.ty = utilY;
					}
					
				}else{
					if (Std.is(child, ICameraDependent)){
						cast(child, ICameraDependent).displayingCameras.remove(camera.name);
					}
					
				}
				
				
			}
		
			for (orphan in __removedChildren) {
				
				if (orphan.stage == null) {
					
					orphan.__cleanup ();
					
				}
				
			}
		
		__removedChildren.length = 0;
		
			
			renderSession.maskManager.popRect ();
		}
		renderSession.filterManager.popObject (this);
	}
	
	public function ChildHitTest(x:Float, y:Float, shapeFlag:Bool, stack:Array<DisplayObject>, interactiveOnly:Bool, hitObject:DisplayObject):Bool
	{
		if (!hitObject.visible || __isMask || (interactiveOnly && !mouseEnabled && !mouseChildren)) return false;
		if (mask != null && !mask.__hitTestMask (x, y)) return false;
		
		if (__scrollRect != null) {
			
			var point = Point.__pool.get ();
			point.setTo (x, y);
			__getRenderTransform ().__transformInversePoint (point);
			
			if (!__scrollRect.containsPoint (point)) {
				
				Point.__pool.release (point);
				return false;
				
			}
			
			Point.__pool.release (point);
			
		}
		
		var i = __children.length;
		if (interactiveOnly) {
			
			if (stack == null || !mouseChildren) {
				
				while (--i >= 0) {
					
					if (__children[i].__hitTest (x, y, shapeFlag, null, true, cast __children[i])) {
						
						if (stack != null) {
							
							stack.push (hitObject);
							
						}
						
						return true;
						
					}
					
				}
				
			} else if (stack != null) {
				
				var length = stack.length;
				
				var interactive = false;
				var hitTest = false;
				
				while (--i >= 0) {
					
					interactive = __children[i].__getInteractive (null);
					//trace(this + this.name + "     TestHit");
					if (interactive || (mouseEnabled && !hitTest)) {
						
						if (__children[i].__hitTest (x, y, shapeFlag, stack, true, cast __children[i])) {
							//trace(__children[i].name + "     Test Succeeded");
							hitTest = true;
							
							//if (interactive) {
								
								break;
								
							//}
							
						}
						
					}
					
				}
				
				if (hitTest) {
					
					stack.insert (length, hitObject);
					return true;
					
				}
				
			}
			
		} else {
			
			while (--i >= 0) {
				
				__children[i].__hitTest (x, y, shapeFlag, stack, false, cast __children[i]);
				
			}
			
		}
		
		return false;
	}
}