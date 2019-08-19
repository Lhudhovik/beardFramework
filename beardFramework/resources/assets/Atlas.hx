package beardFramework.resources.assets;
import beardFramework.core.BeardGame;
import beardFramework.graphics.core.Renderer;
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
	
	private var defaultRect:Rectangle;
	public var subAreas:Map<String, SubTextureData>;
	
	public var index(default, null):Int;
	public var samplerIndex(default, null):Int = -1;
	
	
	public function new(name:String, bitmapData:BitmapData, xml:Xml) 
	{
		this.name = name;
		index = atlasCount++;
		subAreas = new Map<String, SubTextureData>();
		samplerIndex = AssetManager.Get().AllocateFreeTextureIndex();
		
		subAreas.set(name, {
				imageArea:	new Rectangle(),
				frame:		null,
				rotated : 	false,
				uvX: 		0,
				uvY: 		0,
				uvW:		1,
				uvH:		1,
				atlasIndex: this.index,
				samplerIndex: 0
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
				atlasIndex: this.index,
				samplerIndex: samplerIndex
			}
        }
				
		subAreas[name].imageArea.width = textureImage.width;
		subAreas[name].imageArea.height = textureImage.height;
		
		
		
		trace(name + " " + samplerIndex);
		GL.activeTexture(GL.TEXTURE0 + samplerIndex);
		GL.bindTexture(GL.TEXTURE_2D, AssetManager.Get().AddTextureFromImage(this.name,textureImage, samplerIndex ).glTexture);
		Renderer.Get().UpdateAtlasTextureUnits( samplerIndex);
	
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
	public var samplerIndex:Int;
	
	
}