package beardFramework.display.renderers.gl;

import beardFramework.display.cameras.Camera;
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
@:access(beardFramework.display.cameras.Camera)


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
			
			if (_adjustedTransform == null) _adjustedTransform = new Matrix ();
			_adjustedTransform.a = bitmap.__renderTransform.a * camera.zoom;
			_adjustedTransform.b = bitmap.__renderTransform.b * camera.transform.d;
			_adjustedTransform.c = bitmap.__renderTransform.c * camera.zoom;
			_adjustedTransform.d = bitmap.__renderTransform.d * camera.transform.d;
			_adjustedTransform.tx = camera.transform.tx + camera.viewportWidth*0.5 +  (bitmap.__renderTransform.tx - camera.centerX) *camera.zoom;
			_adjustedTransform.ty = camera.transform.ty + camera.viewportHeight *0.5 + (bitmap.__renderTransform.ty - camera.centerY) *camera.zoom;
		
			
			//_adjustedTransform.a = bitmap.__renderTransform.a * camera.zoom;
			//_adjustedTransform.b = bitmap.__renderTransform.b;
			//_adjustedTransform.c = bitmap.__renderTransform.c;
			//_adjustedTransform.d = bitmap.__renderTransform.d * camera.transform.d;
			//_adjustedTransform.tx = camera.transform.tx + (bitmap.__renderTransform.tx - camera.cameraX);
			//_adjustedTransform.ty =  camera.transform.ty + (bitmap.__renderTransform.ty - camera.cameraY);
			
			//trace(_adjustedTransform.tx);
			
			//trace(_adjustedTransform.ty);
			//trace(_adjustedTransform.ty);
			
			renderSession.blendModeManager.setBlendMode (bitmap.__worldBlendMode);
			renderSession.maskManager.pushObject (bitmap);
			
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