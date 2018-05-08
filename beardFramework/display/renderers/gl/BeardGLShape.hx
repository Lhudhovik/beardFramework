package beardFramework.display.renderers.gl;

import lime.utils.Float32Array;
import openfl._internal.renderer.cairo.CairoGraphics;
import openfl._internal.renderer.canvas.CanvasGraphics;
import beardFramework.display.cameras.Camera;
import openfl._internal.renderer.opengl.GLRenderer;
import openfl._internal.renderer.opengl.GLShape;
import openfl._internal.renderer.RenderSession;
import openfl.display.BitmapData;
import openfl.display.DisplayObject;
import openfl.display.Graphics;
import openfl.filters.BitmapFilter;
import openfl.geom.Matrix;


#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end

@:access(openfl.display.DisplayObject)
@:access(openfl.display.BitmapData)
@:access(openfl.display.Graphics)
@:access(openfl.filters.BitmapFilter)
@:access(openfl.geom.Matrix)

/**
 * ...
 * @author Ludo
 */
class BeardGLShape extends GLShape
{
	private static var _adjustedTransform:Matrix;
	public static inline function renderThroughCamera (shape:DisplayObject, renderSession:RenderSession, camera:Camera):Void {
		
		if (!shape.__renderable || shape.__worldAlpha <= 0) return;
		
		var graphics = shape.__graphics;
		
		if (graphics != null) {
			
			#if (js && html5)
			CanvasGraphics.render (graphics, renderSession, shape.__renderTransform);
			#elseif lime_cairo
			CairoGraphics.render (graphics, renderSession, shape.__renderTransform);
			#end
			
			var bounds = graphics.__bounds;
			
			if (graphics.__bitmap != null && graphics.__visible) {
				
				var renderer:GLRenderer = cast renderSession.renderer;
				var gl = renderSession.gl;
				
				
				if (_adjustedTransform == null) _adjustedTransform = new Matrix ();
				_adjustedTransform.a = graphics.__worldTransform.a * camera.transform.a + graphics.__worldTransform.b * camera.transform.c;
				_adjustedTransform.b = graphics.__worldTransform.a * camera.transform.b + graphics.__worldTransform.b * camera.transform.d;
				_adjustedTransform.c = graphics.__worldTransform.c * camera.transform.a + graphics.__worldTransform.d * camera.transform.c;
				_adjustedTransform.d = graphics.__worldTransform.c * camera.transform.b + graphics.__worldTransform.d * camera.transform.d;
				_adjustedTransform.tx = graphics.__worldTransform.tx * camera.transform.a + graphics.__worldTransform.ty * camera.transform.c + camera.transform.tx + (graphics.__worldTransform.tx - camera.centerX);
				_adjustedTransform.ty = graphics.__worldTransform.tx * camera.transform.b + graphics.__worldTransform.ty * camera.transform.d + camera.transform.ty + (graphics.__worldTransform.ty - camera.centerY);
			
				
				
				renderSession.blendModeManager.setBlendMode (shape.__worldBlendMode);
				renderSession.maskManager.pushObject (shape);
				
				var shader = renderSession.filterManager.pushObject (shape);
				
				shader.data.uImage0.input = graphics.__bitmap;
				shader.data.uImage0.smoothing = renderSession.allowSmoothing;
				shader.data.uMatrix.value = renderer.getMatrix (_adjustedTransform);
				
				renderSession.shaderManager.setShader (shader);
				
				gl.bindBuffer (gl.ARRAY_BUFFER, graphics.__bitmap.getBuffer (gl, shape.__worldAlpha, shape.__worldColorTransform));
				gl.vertexAttribPointer (shader.data.aPosition.index, 3, gl.FLOAT, false, 6 * Float32Array.BYTES_PER_ELEMENT, 0);
				gl.vertexAttribPointer (shader.data.aTexCoord.index, 2, gl.FLOAT, false, 6 * Float32Array.BYTES_PER_ELEMENT, 3 * Float32Array.BYTES_PER_ELEMENT);
				gl.vertexAttribPointer (shader.data.aAlpha.index, 1, gl.FLOAT, false, 6 * Float32Array.BYTES_PER_ELEMENT, 5 * Float32Array.BYTES_PER_ELEMENT);
				
				gl.drawArrays (gl.TRIANGLE_STRIP, 0, 4);
				
				renderSession.filterManager.popObject (shape);
				renderSession.maskManager.popObject (shape);
				
			}
			
		}
		
	}
	
}