package beardFramework.resources.assets;
import beardFramework.core.BeardGame;
import beardFramework.display.rendering.VisualRenderer;
import beardFramework.utils.DataUtils;
import beardFramework.utils.TextureUtils;
import beardFramework.utils.XMLUtils;
import lime.app.Application;
import lime.graphics.Image;
import lime.graphics.WebGLRenderContext;
import lime.graphics.opengl.GL;
import lime.graphics.opengl.GLTexture;
import openfl.display.BitmapData;
import lime.math.Rectangle;
import lime._internal.graphics.ImageCanvasUtil; // TODO

@:access(openfl.display.BitmapData)
/**
 * ...
 * @author Ludo
 */
class Atlas 
{
	private static var atlasCount:Int = 0;
	
	public var atlasBitmapData:BitmapData;
	public var name:String;
	public var texture:GLTexture;

	private var defaultRect:Rectangle;
	private var subAreas:Map<String, SubTextureData>;
	
	public var index(default, null):Int;
	
	
	public function new(name:String, bitmapData:BitmapData, xml:Xml) 
	{
		this.name = name;
		index = atlasCount++;
		subAreas = new Map<String, SubTextureData>();
		
		if (bitmapData != null) {
			atlasBitmapData = bitmapData.clone();
			bitmapData.dispose();
		}
		else
			atlasBitmapData = new BitmapData(0,0);
		
		if(xml != null)	parseXml(xml);
		
	}
	
	private function parseXml(xml:Xml):Void
    {
        var imageArea:Rectangle = new Rectangle();
        var frame:Rectangle  = new Rectangle();
      	
		if (xml.firstElement().nodeName == "TextureAtlas") {
			xml = xml.firstElement();
		}
				
        for (subTexture in xml.elementsNamed("SubTexture"))
        {
			
			
			imageArea.setTo(XMLUtils.GetXmlFloat(subTexture, "x"), XMLUtils.GetXmlFloat(subTexture, "y"), XMLUtils.GetXmlFloat(subTexture, "width"), XMLUtils.GetXmlFloat(subTexture, "height"));
            frame.setTo(XMLUtils.GetXmlFloat(subTexture, "frameX"), XMLUtils.GetXmlFloat(subTexture, "frameY"), XMLUtils.GetXmlFloat(subTexture, "frameWidth"), XMLUtils.GetXmlFloat(subTexture, "frameHeight"));
			
			
			subAreas[subTexture.get("name")] = {
				imageArea:	imageArea.clone(),
				frame:		((frame.width > 0 && frame.height > 0) ? frame.clone() : null),
				rotated : 	DataUtils.FromStringToBool(subTexture.get("rotated")),
				uvX: 		imageArea.x/atlasBitmapData.width,
				uvY: 		imageArea.y/atlasBitmapData.height,
				uvW:		imageArea.width/atlasBitmapData.width,
				uvH:		imageArea.height/atlasBitmapData.height,
				atlasIndex: this.index
			}
        }
		
		
		GL.activeTexture(GL.TEXTURE0 + VisualRenderer.Get().GetFreeTextureIndex());
		
		texture = GetTexture(atlasBitmapData.image);
		
		GL.bindTexture(GL.TEXTURE_2D, texture);
		VisualRenderer.Get().ActivateTexture(VisualRenderer.Get().GetFreeTextureIndex());

    }
	
	private function GetTexture(image:Image):GLTexture
	{
		var __texture:GLTexture = GL.createTexture ();
		var __textureInternalFormat:Int = 0;
		var __textureFormat:Int = 0;
	
	
		GL.bindTexture (GL.TEXTURE_2D, __texture);
		GL.texParameteri (GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.CLAMP_TO_EDGE);
		GL.texParameteri (GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.CLAMP_TO_EDGE);
		GL.texParameteri (GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.NEAREST);
		GL.texParameteri (GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.NEAREST);
				
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
	
	
   	
	public inline function GetTextureDimensions(name:String):Rectangle
	{
		if (subAreas[name] == null){
			if (defaultRect == null) defaultRect = new Rectangle();
			return defaultRect;
		}
		
		return subAreas[name].imageArea;
	}
	
	public inline function GetSubTextureData(textureName:String):SubTextureData
	{
		return subAreas[textureName];
	}
	
	public function Dispose():Void
	{
		for (subArea in subAreas)
		{
			subArea = null;
		}
		
		subAreas = null;
		atlasBitmapData.dispose();
		atlasBitmapData = null;
	}
		
}

typedef SubTextureData =
{
	public var imageArea:Rectangle;
	public var frame:Rectangle;
	public var rotated : Bool;
	public var uvX:Float;
	public var uvY:Float;
	public var uvW:Float;
	public var uvH:Float;
	public var atlasIndex:Int;
	
	
}