package beardFramework.display.core;

import beardFramework.core.BeardGame;
import beardFramework.display.cameras.Camera;
import beardFramework.display.heritage.BeardTileMap;
import beardFramework.interfaces.ICameraDependent;
import lime.app.Application;
import openfl._internal.renderer.RenderSession;
import openfl._internal.renderer.opengl.GLDisplayObject;
import openfl._internal.renderer.opengl.GLBitmap;
import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;
import openfl.display.Tile;
import openfl.display.Tilemap;
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
	private var maps:Array<BeardTileMap>;
	public function new(name:String) 
	{
		super();
		this.name = name;
		maps = new Array<BeardTileMap>();
		
	}

	private override function __renderGL (renderSession:RenderSession):Void 
	{
		
		if (!__renderable || __worldAlpha <= 0) return;
		
		var utilX:Float;
		var utilY:Float;
	
		renderSession.filterManager.pushObject (this);
		
		for (camera in BeardGame.Get().cameras.iterator()){
		
			//if (!camera.needRenderUpdate) continue;
			//
			//camera.needRenderUpdate = false;
			
			renderSession.maskManager.pushRect (camera.GetRect(), camera.transform);
			
			for (child in __children) {
				
				
				
				if (Std.is(child, ICameraDependent) && camera.Contains(cast child)){
					
					
					//if (Std.is(child, ICameraDependent)){
						
						//cast(child, ICameraDependent).displayingCameras.remove(camera.name);
						//cast(child, ICameraDependent).displayingCameras.add(camera.name);
						cast(child, ICameraDependent).RenderThroughCamera(camera, renderSession);
		//
					//}
					//else{
						//utilX = child.__transform.tx;
						//utilY = child.__transform.ty;
						//child.__transform.tx =  camera.viewportX + camera.viewportWidth*0.5 +  (utilX- camera.centerX) *camera.zoom;
						//child.__transform.ty = 	camera.viewportY + camera.viewportHeight*0.5 +  (utilY- camera.centerY) *camera.zoom;
						//child.__update(true, true);
						//child.__renderGL (renderSession);
						//child.__transform.tx = utilX;
						//child.__transform.ty = utilY;
					//
					//}
					
				}else if (Std.is(child, ICameraDependent)){
					
						for (cam in cast(child, ICameraDependent).displayingCameras)
							if (cam == camera.name)
							{
								cast(child, ICameraDependent).displayingCameras.remove(camera.name);
								break;
							}
				}
				else {
					//trace(child.name);
					child.__renderGL (renderSession);
				}
			}
		
			renderSession.maskManager.popRect ();
		}
		
		for (orphan in __removedChildren) {
				
			if (orphan.stage == null) {
				
				orphan.__cleanup ();
				
			}
				
		}
		
		__removedChildren.length = 0;
		
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
	
	override function set_width(value:Float):Float 
	{
		for (map in maps)
			map.width = value;
		return super.set_width(value);
	}
	
	override function set_height(value:Float):Float 
	{
		for (map in maps)
			map.height = value;
		return super.set_height(value);
	}
	override function set_scaleX(value:Float):Float 
	{
		super.set_scaleX(value);
		for (map in maps)	
			map.width = this.width;
		return scaleX;
	}
	
	override function set_scaleY(value:Float):Float 
	{
		super.set_scaleY(value);
		for (map in maps)
			map.height = this.height;
		return scaleY;
	}
	
	
	public inline function AddVisual(visual:BeardVisual):Void
	{
		var existingMap:Bool = false;
		for (map in maps)
			if (map.HasTileset(visual.atlas)){
				
				map.addTile(visual);
				existingMap = true;
				break;
			}
		
		if (!existingMap){
			var map:BeardTileMap = new BeardTileMap(Application.current.window.width,Application.current.window.height);
			map.addTile(visual);
			maps.push(map);
			this.addChild(map);
			//trace("child map added");
		}
		
		
			
	}
	
	public inline function RemoveVisual(visual:BeardVisual):Void
	{
		for (map in maps)
			if (map.contains(visual)) 
				map.removeTile(visual);
	}
}