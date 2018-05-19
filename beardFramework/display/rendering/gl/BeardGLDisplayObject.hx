package beardFramework.display.rendering.gl;

import beardFramework.display.cameras.Camera;
import openfl._internal.renderer.opengl.GLDisplayObject;
import openfl.geom.Matrix;
import lime.math.color.ARGB;
import openfl._internal.renderer.RenderSession;
import openfl.display.DisplayObject;
import openfl.geom.Rectangle;

#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end

@:access(openfl.display.DisplayObject)
@:access(openfl.geom.Matrix)
@:access(openfl.geom.Rectangle)
@:keep
/**
 * ...
 * @author Ludo
 */
class BeardGLDisplayObject extends GLDisplayObject 
{
	private static var _adjustedTransform:Matrix;
	public static inline function renderThroughCamera (displayObject:DisplayObject, renderSession:RenderSession,camera:Camera):Void {
		
		if (displayObject.opaqueBackground == null && displayObject.__graphics == null) return;
		if (!displayObject.__renderable || displayObject.__worldAlpha <= 0) return;
		
		if (displayObject.opaqueBackground != null && displayObject.width > 0 && displayObject.height > 0) {
			
			if (_adjustedTransform == null) _adjustedTransform = new Matrix();
			_adjustedTransform.a = displayObject.__renderTransform.a * camera.transform.a + displayObject.__renderTransform.b * camera.transform.c;
			_adjustedTransform.b = displayObject.__renderTransform.a * camera.transform.b + displayObject.__renderTransform.b * camera.transform.d;
			_adjustedTransform.c = displayObject.__renderTransform.c * camera.transform.a + displayObject.__renderTransform.d * camera.transform.c;
			_adjustedTransform.d = displayObject.__renderTransform.c * camera.transform.b + displayObject.__renderTransform.d * camera.transform.d;
			_adjustedTransform.tx = displayObject.__renderTransform.tx * camera.transform.a + displayObject.__renderTransform.ty * camera.transform.c + camera.transform.tx + (displayObject.__renderTransform.tx - camera.centerX);
			_adjustedTransform.ty = displayObject.__renderTransform.tx * camera.transform.b + displayObject.__renderTransform.ty * camera.transform.d + camera.transform.ty + (displayObject.__renderTransform.ty - camera.centerY);
			
			renderSession.maskManager.pushObject (displayObject);
			
			var gl = renderSession.gl;
			
			var rect = Rectangle.__pool.get();
			rect.setTo (0, 0, displayObject.width, displayObject.height);
			renderSession.maskManager.pushRect (rect, _adjustedTransform);
			
			var color:ARGB = (displayObject.opaqueBackground:ARGB);
			gl.clearColor (color.r / 0xFF, color.g / 0xFF, color.b / 0xFF, 1);
			gl.clear (gl.COLOR_BUFFER_BIT);
			
			renderSession.maskManager.popRect ();
			renderSession.maskManager.popObject (displayObject);
			
		}
		
		if (displayObject.__graphics != null) {
			
			BeardGLShape.renderThroughCamera(displayObject, renderSession, camera);
			
		}
		
	}
	
}



			