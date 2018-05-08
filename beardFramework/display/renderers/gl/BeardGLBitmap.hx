package beardFramework.display.renderers.gl;

import beardFramework.display.cameras.Camera;
import openfl._internal.renderer.opengl.GLBitmap;
import openfl._internal.renderer.opengl.GLRenderer;
import openfl._internal.renderer.opengl.GLMaskManager;
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
@:access(openfl.geom.ColorTransform)
@:access(beardFramework.display.cameras.Camera)


/**
 * ...
 * @author Ludo
 */
class BeardGLBitmap extends GLBitmap 
{
	private static var _adjustedTransform:Matrix = new Matrix();
	public static function renderThroughCamera (bitmap:Bitmap, renderSession:RenderSession, camera:Camera):Void {
		
		if (!bitmap.__renderable || bitmap.__worldAlpha <= 0) return;
		
		if (bitmap.__bitmapData != null && bitmap.__bitmapData.__isValid) {
			
			var renderer:GLRenderer = cast renderSession.renderer;
			var gl = renderSession.gl;
			
			//if (_adjustedTransform == null) _adjustedTransform = new Matrix ();
			_adjustedTransform.a = bitmap.__renderTransform.a * camera.zoom;
			_adjustedTransform.b = bitmap.__renderTransform.b * camera.transform.d;
			_adjustedTransform.c = bitmap.__renderTransform.c * camera.zoom;
			_adjustedTransform.d = bitmap.__renderTransform.d * camera.transform.d;
			_adjustedTransform.tx = camera.transform.tx + camera.viewportWidth*0.5 +  (bitmap.__renderTransform.tx - camera.centerX) *camera.zoom;
			_adjustedTransform.ty = camera.transform.ty + camera.viewportHeight *0.5 + (bitmap.__renderTransform.ty - camera.centerY) *camera.zoom;
		
			
			renderSession.blendModeManager.setBlendMode (bitmap.__worldBlendMode);
			renderSession.maskManager.pushObject (bitmap);
			
			renderSession.filterManager.pushObject (bitmap);
			
			var shader = renderSession.shaderManager.initShader (bitmap.shader);
			renderSession.shaderManager.setShader (shader);
			
			shader.data.uImage0.input = bitmap.__bitmapData;
			shader.data.uImage0.smoothing = renderSession.allowSmoothing && (bitmap.smoothing || renderSession.upscaled);
			shader.data.uMatrix.value = renderer.getMatrix (_adjustedTransform);
			
			var useColorTransform = !bitmap.__worldColorTransform.__isDefault ();
			if (shader.data.uColorTransform.value == null) shader.data.uColorTransform.value = [];
			shader.data.uColorTransform.value[0] = useColorTransform;
			
			renderSession.shaderManager.updateShader (shader);
			
			gl.bindBuffer (gl.ARRAY_BUFFER, bitmap.__bitmapData.getBuffer (gl, bitmap.__worldAlpha, bitmap.__worldColorTransform));
			
			gl.vertexAttribPointer (shader.data.aPosition.index, 3, gl.FLOAT, false, 26 * Float32Array.BYTES_PER_ELEMENT, 0);
			gl.vertexAttribPointer (shader.data.aTexCoord.index, 2, gl.FLOAT, false, 26 * Float32Array.BYTES_PER_ELEMENT, 3 * Float32Array.BYTES_PER_ELEMENT);
			gl.vertexAttribPointer (shader.data.aAlpha.index, 1, gl.FLOAT, false, 26 * Float32Array.BYTES_PER_ELEMENT, 5 * Float32Array.BYTES_PER_ELEMENT);
			
			if (true || useColorTransform) {
				
				gl.vertexAttribPointer (shader.data.aColorMultipliers.index, 4, gl.FLOAT, false, 26 * Float32Array.BYTES_PER_ELEMENT, 6 * Float32Array.BYTES_PER_ELEMENT);
				gl.vertexAttribPointer (shader.data.aColorMultipliers.index + 1, 4, gl.FLOAT, false, 26 * Float32Array.BYTES_PER_ELEMENT, 10 * Float32Array.BYTES_PER_ELEMENT);
				gl.vertexAttribPointer (shader.data.aColorMultipliers.index + 2, 4, gl.FLOAT, false, 26 * Float32Array.BYTES_PER_ELEMENT, 14 * Float32Array.BYTES_PER_ELEMENT);
				gl.vertexAttribPointer (shader.data.aColorMultipliers.index + 3, 4, gl.FLOAT, false, 26 * Float32Array.BYTES_PER_ELEMENT, 18 * Float32Array.BYTES_PER_ELEMENT);
				gl.vertexAttribPointer (shader.data.aColorOffsets.index, 4, gl.FLOAT, false, 26 * Float32Array.BYTES_PER_ELEMENT, 22 * Float32Array.BYTES_PER_ELEMENT);
				
			}
			
			gl.drawArrays (gl.TRIANGLE_STRIP, 0, 4);
			
			#if gl_stats
				GLStats.incrementDrawCall (DrawCallContext.STAGE);
			#end
			
			renderSession.filterManager.popObject (bitmap);
			renderSession.maskManager.popObject (bitmap);
			
		}
		
	}
	
	public static function renderMaskThroughCamera (bitmap:Bitmap, renderSession:RenderSession, camera:Camera):Void {
		
		if (bitmap.__bitmapData != null && bitmap.__bitmapData.__isValid) {
			
			var renderer:GLRenderer = cast renderSession.renderer;
			var gl = renderSession.gl;
			
			_adjustedTransform.a = bitmap.__renderTransform.a * camera.zoom;
			_adjustedTransform.b = bitmap.__renderTransform.b * camera.transform.d;
			_adjustedTransform.c = bitmap.__renderTransform.c * camera.zoom;
			_adjustedTransform.d = bitmap.__renderTransform.d * camera.transform.d;
			_adjustedTransform.tx = camera.transform.tx + camera.viewportWidth*0.5 +  (bitmap.__renderTransform.tx - camera.centerX) *camera.zoom;
			_adjustedTransform.ty = camera.transform.ty + camera.viewportHeight *0.5 + (bitmap.__renderTransform.ty - camera.centerY) *camera.zoom;
			
			
			var shader = GLMaskManager.maskShader;
			renderSession.shaderManager.setShader (shader);
			
			shader.data.uImage0.input = bitmap.__bitmapData;
			shader.data.uImage0.smoothing = renderSession.allowSmoothing && (bitmap.smoothing || renderSession.upscaled);
			shader.data.uMatrix.value = renderer.getMatrix (_adjustedTransform);
			
			renderSession.shaderManager.updateShader (shader);
			
			gl.bindBuffer (gl.ARRAY_BUFFER, bitmap.__bitmapData.getBuffer (gl, bitmap.__worldAlpha, bitmap.__worldColorTransform));
			
			gl.vertexAttribPointer (shader.data.aPosition.index, 3, gl.FLOAT, false, 26 * Float32Array.BYTES_PER_ELEMENT, 0);
			gl.vertexAttribPointer (shader.data.aTexCoord.index, 2, gl.FLOAT, false, 26 * Float32Array.BYTES_PER_ELEMENT, 3 * Float32Array.BYTES_PER_ELEMENT);
			
			gl.drawArrays (gl.TRIANGLE_STRIP, 0, 4);
			
			#if gl_stats
				GLStats.incrementDrawCall (DrawCallContext.STAGE);
			#end
			
		}
		
	}
}