package beardFramework.utils.graphics;
import beardFramework.core.BeardGame;
import lime.graphics.Image;
import lime.graphics.opengl.GL;
import lime.graphics.opengl.GLTexture;
import openfl.display.BitmapData;
import openfl.geom.Rectangle;
//import starling.core.Starling;
//import starling.display.BlendMode;
//import starling.display.Image;
//import starling.textures.RenderTexture;
//import starling.textures.Texture;


/**
 * ...
 * @author Ludo
 */
class TextureU
{

	//public static var mergedBitmapData = { };
	
	//public static function createComposedAtlasFromTextures(rgbTexture :Texture, alphaTexture : Texture):Texture {
				//
	//
		//var renderTexture:RenderTexture = new RenderTexture(rgbTexture.width, rgbTexture.height);
		//var imageTemp:Image = new Image(alphaTexture);
		//renderTexture.draw(imageTemp);
		//
		//imageTemp = new Image(rgbTexture);
		//imageTemp.blendMode = BlendMode.MULTIPLY ;
		//Starling.current.context.setBlendFactors(Context3DBlendFactor.DESTINATION_ALPHA, Context3DBlendFactor.ZERO);
		//renderTexture.draw(imageTemp);
		//rgbTexture.dispose();
		//alphaTexture.dispose();
		////trace(renderTexture.width);
		////trace(renderTexture.height);
		//return renderTexture;
	//}
	//public static function createComposedAtlasFromBitmaps(rgbBitmap : Bitmap, alphaBitmap : Bitmap, xml:XML, name :String = ""):TextureAtlas {
		//
		//mergedBitmapData[name] = merge(rgbBitmap, alphaBitmap);
					//return new TextureAtlas(Texture.fromBitmapData( mergedBitmapData[name]), xml) ;	
					//
		////return new TextureAtlas( Texture.fromBitmapData(merge(rgbBitmap, alphaBitmap)), xml) ;		
		//
	//}
	//public static function merge (rgb:Bitmap, alphaBitmap:Bitmap) : BitmapData
	//{
		//var rgbBitmapData:BitmapData = rgb.bitmapData;
		//var alphaBitmapData:BitmapData = alphaBitmap.bitmapData;
		//var resultBitmapData:BitmapData = new BitmapData(rgbBitmapData.width, rgbBitmapData.height, true, 0);
		//resultBitmapData.copyPixels(rgbBitmapData, rgbBitmapData.rect, new Point());
		//resultBitmapData.copyChannel(alphaBitmapData, new Rectangle(0, 0, rgbBitmapData.width, rgbBitmapData.height), new Point(), BitmapDataChannel.ALPHA, BitmapDataChannel.ALPHA);
		//
		//rgb.bitmapData.dispose();
		//alphaBitmap.bitmapData.dispose();
		//trace(resultBitmapData.width);
		//trace(resultBitmapData.height);
		//
		//
		//
		//return resultBitmapData;
	//}
	//public static var tempTexture : Texture;
	public static var rect : Rectangle;
	
	public static inline function GetRectangle():Rectangle
	{
		if (rect == null) rect = new Rectangle();
		return rect;
	}
	
	public static function GetFormat(image:Image):Int
	{
		var __textureInternalFormat:Int = 0;
		var __textureFormat:Int = 0;
		var internalFormat = 0;
		var format=0;
	
		if (image != null) {
			
			
			
			if (image.buffer.bitsPerPixel == 1) {
				
				internalFormat = GL.ALPHA;
				format = GL.ALPHA;
				
			} else {
				__textureInternalFormat = GL.RGBA;
					
				var bgraExtension = null;
				#if (!js || !html5)
				bgraExtension = GL.getExtension ("EXT_bgra");
				if (bgraExtension == null)
					bgraExtension = GL.getExtension ("EXT_texture_format_BGRA8888");
				if (bgraExtension == null)
					bgraExtension = GL.getExtension ("APPLE_texture_format_BGRA8888");
				#end
				
				if (bgraExtension != null) {
					
					__textureFormat = bgraExtension.BGRA_EXT;
					
					#if (!ios && !tvos)
					if (BeardGame.Get().window.context.type == #if (lime >= "7.0.0") OPENGLES #else GLES #end) {
						
						__textureInternalFormat = bgraExtension.BGRA_EXT;
						
					}
					#end
					
				} 
				else	__textureFormat = GL.RGBA;
					
				internalFormat = __textureInternalFormat;
				format = __textureFormat;
				
			}
			
				
		}
		
		return format;
		
	}
	public static function GetInternalFormat(image:Image):Int
	{
		var __textureInternalFormat:Int = 0;
		var __textureFormat:Int = 0;
		var internalFormat = 0;
		var format;
	
		if (image != null) {
			
			
			
			if (image.buffer.bitsPerPixel == 1) {
				
				internalFormat = GL.ALPHA;
				format = GL.ALPHA;
				
			} else {
				__textureInternalFormat = GL.RGBA;
					
				var bgraExtension = null;
				#if (!js || !html5)
				bgraExtension = GL.getExtension ("EXT_bgra");
				if (bgraExtension == null)
					bgraExtension = GL.getExtension ("EXT_texture_format_BGRA8888");
				if (bgraExtension == null)
					bgraExtension = GL.getExtension ("APPLE_texture_format_BGRA8888");
				#end
				
				if (bgraExtension != null) {
					
					__textureFormat = bgraExtension.BGRA_EXT;
					
					#if (!ios && !tvos)
					if (BeardGame.Get().window.context.type == #if (lime >= "7.0.0") OPENGLES #else GLES #end) {
						
						__textureInternalFormat = bgraExtension.BGRA_EXT;
						
					}
					#end
					
				} 
				else	__textureFormat = GL.RGBA;
					
				internalFormat = __textureInternalFormat;
				format = __textureFormat;
				
			}
			
				
		}
		
		return internalFormat;
		
	}
	
	public static function GetTexture(image:Image):GLTexture
	{
		var __texture:GLTexture = GL.createTexture ();
		var __textureInternalFormat:Int = 0;
		var __textureFormat:Int = 0;
	
	
		GL.bindTexture (GL.TEXTURE_2D, __texture);
		GL.texParameteri (GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.CLAMP_TO_EDGE);
		GL.texParameteri (GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.CLAMP_TO_EDGE);
		//GL.texParameteri (GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.NEAREST);
		GL.texParameteri (GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.LINEAR);
		//GL.texParameteri (GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.NEAREST);
		GL.texParameteri (GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.LINEAR);
				
		if (image != null) {
			
			var internalFormat, format;
			
			if (image.buffer.bitsPerPixel == 1) {
				
				internalFormat = GL.ALPHA;
				format = GL.ALPHA;
				
			} else {
				__textureInternalFormat = GL.RGBA;
					
				var bgraExtension = null;
				#if (!js || !html5)
				bgraExtension = GL.getExtension ("EXT_bgra");
				if (bgraExtension == null)
					bgraExtension = GL.getExtension ("EXT_texture_format_BGRA8888");
				if (bgraExtension == null)
					bgraExtension = GL.getExtension ("APPLE_texture_format_BGRA8888");
				#end
				
				if (bgraExtension != null) {
					
					__textureFormat = bgraExtension.BGRA_EXT;
					
					#if (!ios && !tvos)
					if (BeardGame.Get().window.context.type == #if (lime >= "7.0.0") OPENGLES #else GLES #end) {
						
						__textureInternalFormat = bgraExtension.BGRA_EXT;
						
					}
					#end
					
				} 
				else	__textureFormat = GL.RGBA;
					
				internalFormat = __textureInternalFormat;
				format = __textureFormat;
				
			}
			
			GL.bindTexture (GL.TEXTURE_2D, __texture);
			
			var textureImage = image;
			
			if (#if openfl_power_of_two !textureImage.powerOfTwo || #end (!textureImage.premultiplied && textureImage.transparent)) {
				
				textureImage = textureImage.clone ();
				textureImage.premultiplied = true;
				#if openfl_power_of_two
				textureImage.powerOfTwo = true;
				#end
				
			}
			
			GL.texImage2D (GL.TEXTURE_2D, 0, internalFormat, textureImage.buffer.width, textureImage.buffer.height, 0, format, GL.UNSIGNED_BYTE, textureImage.data);
			
			GL.bindTexture (GL.TEXTURE_2D, null);
						
		}
				
		return __texture;
	}
	//public static function GetTexture(image:Image):GLTexture
	//{
		//
		//
	//}
}