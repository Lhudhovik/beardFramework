package utils;
import starling.core.Starling;
import starling.display.BlendMode;
import starling.display.Image;
import starling.textures.RenderTexture;
import starling.textures.Texture;


/**
 * ...
 * @author Ludo
 */
class TextureUtils
{

	public static var mergedBitmapData = { };
	
	public static function createComposedAtlasFromTextures(rgbTexture :Texture, alphaTexture : Texture):Texture {
				
	
		var renderTexture:RenderTexture = new RenderTexture(rgbTexture.width, rgbTexture.height);
		var imageTemp:Image = new Image(alphaTexture);
		renderTexture.draw(imageTemp);
		
		imageTemp = new Image(rgbTexture);
		imageTemp.blendMode = BlendMode.MULTIPLY ;
		Starling.current.context.setBlendFactors(Context3DBlendFactor.DESTINATION_ALPHA, Context3DBlendFactor.ZERO);
		renderTexture.draw(imageTemp);
		rgbTexture.dispose();
		alphaTexture.dispose();
		//trace(renderTexture.width);
		//trace(renderTexture.height);
		return renderTexture;
	}
	public static function createComposedAtlasFromBitmaps(rgbBitmap : Bitmap, alphaBitmap : Bitmap, xml:XML, name :String = ""):TextureAtlas {
		
		mergedBitmapData[name] = merge(rgbBitmap, alphaBitmap);
					return new TextureAtlas(Texture.fromBitmapData( mergedBitmapData[name]), xml) ;	
					
		//return new TextureAtlas( Texture.fromBitmapData(merge(rgbBitmap, alphaBitmap)), xml) ;		
		
	}
	public static function merge (rgb:Bitmap, alphaBitmap:Bitmap) : BitmapData
	{
		var rgbBitmapData:BitmapData = rgb.bitmapData;
		var alphaBitmapData:BitmapData = alphaBitmap.bitmapData;
		var resultBitmapData:BitmapData = new BitmapData(rgbBitmapData.width, rgbBitmapData.height, true, 0);
		resultBitmapData.copyPixels(rgbBitmapData, rgbBitmapData.rect, new Point());
		resultBitmapData.copyChannel(alphaBitmapData, new Rectangle(0, 0, rgbBitmapData.width, rgbBitmapData.height), new Point(), BitmapDataChannel.ALPHA, BitmapDataChannel.ALPHA);
		
		rgb.bitmapData.dispose();
		alphaBitmap.bitmapData.dispose();
		trace(resultBitmapData.width);
		trace(resultBitmapData.height);
		
		
		
		return resultBitmapData;
	}
	public static var tempTexture : Texture;
	
}