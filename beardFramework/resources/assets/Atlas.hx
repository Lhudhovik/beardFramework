package beardFramework.resources.assets;
import beardFramework.core.BeardGame;
import beardFramework.graphics.rendering.Renderer;
import beardFramework.utils.data.DataU;
import beardFramework.utils.graphics.TextureU;
import beardFramework.utils.data.XMLU;
import haxe.Utf8;
import lime.app.Application;
import lime.graphics.Image;
import lime.graphics.WebGLRenderContext;
import lime.graphics.opengl.GL;
import lime.graphics.opengl.GLTexture;
import openfl.display.BitmapData;
import lime.math.Rectangle;


@:access(openfl.display.BitmapData)
/**
 * ...
 * @author Ludo
 */
class Atlas 
{
	private static var atlasCount:Int = 0;
	
	//public var atlasBitmapData:BitmapData;
	public var textureImage:Image;
	public var name:String;
	public var texture:GLTexture;

	private var defaultRect:Rectangle;
	public var subAreas:Map<String, SubTextureData>;
	
	public var index(default, null):Int;
	public var textureIndex(default, null):Int = -1;
	
	
	public function new(name:String, bitmapData:BitmapData, xml:Xml) 
	{
		this.name = name;
		index = atlasCount++;
		subAreas = new Map<String, SubTextureData>();
		
		
		subAreas.set(name, {
				imageArea:	new Rectangle(),
				frame:		null,
				rotated : 	false,
				uvX: 		0,
				uvY: 		0,
				uvW:		1,
				uvH:		1,
				atlasIndex: this.index
		});
		
		if (bitmapData != null) {
			textureImage = bitmapData.image.clone();
			bitmapData.dispose();
		}
		else
			textureImage = new Image();
		
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
			
			
			imageArea.setTo(XMLU.GetXmlFloat(subTexture, "x"), XMLU.GetXmlFloat(subTexture, "y"), XMLU.GetXmlFloat(subTexture, "width"), XMLU.GetXmlFloat(subTexture, "height"));
            frame.setTo(XMLU.GetXmlFloat(subTexture, "frameX"), XMLU.GetXmlFloat(subTexture, "frameY"), XMLU.GetXmlFloat(subTexture, "frameWidth"), XMLU.GetXmlFloat(subTexture, "frameHeight"));
			
			
			subAreas[subTexture.get("name")] = {
				imageArea:	imageArea.clone(),
				frame:		((frame.width > 0 && frame.height > 0) ? frame.clone() : null),
				rotated : 	DataU.FromStringToBool(subTexture.get("rotated")),
				uvX: 		imageArea.x/textureImage.width,
				uvY: 		imageArea.y/textureImage.height,
				uvW:		imageArea.width/textureImage.width,
				uvH:		imageArea.height/textureImage.height,
				atlasIndex: this.index
			}
        }
				
		subAreas[name].imageArea.width = textureImage.width;
		subAreas[name].imageArea.height = textureImage.height;
		
		textureIndex = Renderer.Get().AllocateFreeTextureIndex();
		GL.activeTexture(GL.TEXTURE0 + textureIndex);
		texture = GetTexture(textureImage);
		GL.bindTexture(GL.TEXTURE_2D, texture);
		Renderer.Get().UpdateTextureUnits(this.name, textureIndex);
	
    }
	
	private function GetTexture(image:Image):GLTexture
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
		textureImage = null;
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