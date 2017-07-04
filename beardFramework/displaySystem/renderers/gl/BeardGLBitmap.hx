package beardFramework.displaySystem.renderers.gl;

import beardFramework.displaySystem.cameras.Camera;
import openfl._internal.renderer.opengl.GLBitmap;
import openfl._internal.renderer.opengl.GLRenderer;
import lime.utils.Float32Array;
import openfl._internal.renderer.RenderSession;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Stage;
import openfl.filters.BitmapFilter;
import openfl.geom.Matrix;

#if !openfl_debug
@:fileXml(' tags="haxe,release" ')
@:noDebug
#end

@:access(openfl.display.Bitmap)
@:access(openfl.display.BitmapData)
@:access(openfl.display.Stage)
@:access(openfl.filters.BitmapFilter)


/**
 * ...
 * @author Ludo
 */
class BeardGLBitmap extends GLBitmap 
{
	private static var _adjustedTransform:Matrix;
	public static inline function renderThroughCamera (bitmap:Bitmap, renderSession:RenderSession, camera:Camera):Void {
		
		if (!bitmap.__renderable || bitmap.__worldAlpha <= 0) return;
		
		if (bitmap.bitmapData != null && bitmap.bitmapData.__isValid) {
			
			var renderer:GLRenderer = cast renderSession.renderer;
			var gl = renderSession.gl;
			
			renderSession.blendModeManager.setBlendMode (bitmap.__worldBlendMode);
			
			
			_adjustedTransform.a = bitmap.__renderTransform.a * camera.transform.a + bitmap.__renderTransform.b * camera.transform.c;
			_adjustedTransform.b = bitmap.__renderTransform.a * camera.transform.b + bitmap.__renderTransform.b * camera.transform.d;
			_adjustedTransform.c = bitmap.__renderTransform.c * camera.transform.a + bitmap.__renderTransform.d * camera.transform.c;
			_adjustedTransform.d = bitmap.__renderTransform.c * camera.transform.b + bitmap.__renderTransform.d * camera.transform.d;
			_adjustedTransform.tx = bitmap.__renderTransform.tx * camera.transform.a + bitmap.__renderTransform.ty * camera.transform.c + camera.transform.tx;
			_adjustedTransform.ty = bitmap.__renderTransform.tx * camera.transform.b + bitmap.__renderTransform.ty * camera.transform.d + camera.transform.ty;
			
			
			renderSession.maskManager.pushObject (bitmap);
			//renderSession.maskManager.p (bitmap);
			
			var shader = renderSession.filterManager.pushObject (bitmap);
	
			

			shader.data.uImage0.input = bitmap.bitmapData;
			shader.data.uImage0.smoothing = renderSession.allowSmoothing && (bitmap.smoothing || renderSession.upscaled);
			shader.data.uMatrix.value = renderer.getMatrix (_adjustedTransform);
			
			renderSession.shaderManager.setShader (shader);
			
			gl.bindBuffer (gl.ARRAY_BUFFER, bitmap.bitmapData.getBuffer (gl, bitmap.__worldAlpha));
			gl.vertexAttribPointer (shader.data.aPosition.index, 3, gl.FLOAT, false, 6 * Float32Array.BYTES_PER_ELEMENT, 0);
			gl.vertexAttribPointer (shader.data.aTexCoord.index, 2, gl.FLOAT, false, 6 * Float32Array.BYTES_PER_ELEMENT, 3 * Float32Array.BYTES_PER_ELEMENT);
			gl.vertexAttribPointer (shader.data.aAlpha.index, 1, gl.FLOAT, false, 6 * Float32Array.BYTES_PER_ELEMENT, 5 * Float32Array.BYTES_PER_ELEMENT);
			
			gl.drawArrays (gl.TRIANGLE_STRIP, 0, 4);
			
			renderSession.filterManager.popObject (bitmap);
			renderSession.maskManager.popObject (bitmap);
			
		}
		
	}
	
	
}