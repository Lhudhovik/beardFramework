package beardFramework.displaySystem.renderers.gl;

import beardFramework.displaySystem.cameras.Camera;
import lime.math.color.ARGB;
import openfl._internal.renderer.opengl.GLDisplayObject;
import openfl._internal.renderer.RenderSession;
import openfl.display.DisplayObject;
import openfl.display.Stage;
import openfl.geom.Matrix;
import openfl.geom.Rectangle;

@:access(openfl._internal.renderer.opengl.GLRenderer)
@:access(openfl.display.DisplayObject)
@:access(openfl.display.Stage)
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
	public static inline function renderThroughCamera (displayObject:DisplayObject, renderSession:RenderSession, camera:Camera):Void {
		
		if (displayObject.opaqueBackground == null && displayObject.__graphics == null) return;
		if (!displayObject.__renderable || displayObject.__worldAlpha <= 0) return;
		
		if (displayObject.opaqueBackground != null && !displayObject.__cacheBitmapRender && displayObject.width > 0 && displayObject.height > 0) {
			
			renderSession.maskManager.pushObject (displayObject);
			
			if (_adjustedTransform == null) _adjustedTransform = new Matrix();
			_adjustedTransform.a = displayObject.__renderTransform.a * camera.transform.a + displayObject.__renderTransform.b * camera.transform.c;
			_adjustedTransform.b = displayObject.__renderTransform.a * camera.transform.b + displayObject.__renderTransform.b * camera.transform.d;
			_adjustedTransform.c = displayObject.__renderTransform.c * camera.transform.a + displayObject.__renderTransform.d * camera.transform.c;
			_adjustedTransform.d = displayObject.__renderTransform.c * camera.transform.b + displayObject.__renderTransform.d * camera.transform.d;
			_adjustedTransform.tx = displayObject.__renderTransform.tx * camera.transform.a + displayObject.__renderTransform.ty * camera.transform.c + camera.transform.tx;
			_adjustedTransform.ty = displayObject.__renderTransform.tx * camera.transform.b + displayObject.__renderTransform.ty * camera.transform.d + camera.transform.ty;
			
			var gl = renderSession.gl;
			
			var rect = Rectangle.__pool.get ();
			rect.setTo (0, 0, displayObject.width, displayObject.height);
			renderSession.maskManager.pushRect (rect, _adjustedTransform);
			
			var color:ARGB = (displayObject.opaqueBackground:ARGB);
			gl.clearColor (color.r / 0xFF, color.g / 0xFF, color.b / 0xFF, 1);
			gl.clear (gl.COLOR_BUFFER_BIT);
			
			renderSession.maskManager.popRect ();
			renderSession.maskManager.popObject (displayObject);
			
			Rectangle.__pool.release (rect);
			
		}
		
		if (displayObject.__graphics != null) {
			
			GLShape.render (displayObject, renderSession);
			
		}
		
	}
	
}