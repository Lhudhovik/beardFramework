package beardFramework.resources.assets;
import beardFramework.display.rendering.VisualRenderer;
import beardFramework.utils.DataUtils;
import beardFramework.utils.TextureUtils;
import beardFramework.utils.XMLUtils;
import lime.graphics.opengl.GL;
import lime.graphics.opengl.GLES3Context;
import lime.graphics.opengl.GLTexture;
import openfl.display.BitmapData;
import openfl.geom.Rectangle;


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
		subAreas = new Map<String, SubTextureData>();
		atlasBitmapData = bitmapData.clone();
		bitmapData.dispose();
		index = atlasCount++;
		
		parseXml(xml);
		
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
		
		
		
		texture = atlasBitmapData.getTexture(VisualRenderer.Get().context);
		
		if (index == 0)
		{
			//
			//VisualRenderer.Get().context.activeTexture(GL.TEXTURE0);
			//var text:GLTexture = VisualRenderer.Get().context.genTextures(3)[0];
					//
			//VisualRenderer.Get().context.bindTexture(GL.TEXTURE_2D_ARRAY, text);
						//
			//VisualRenderer.Get().context.texStorage3D(VisualRenderer.Get().context.TEXTURE_2D_ARRAY,0, GL.RGBA8, 2048, 2048, 3);
			////VisualRenderer.Get().context.texStorage3D(VisualRenderer.Get().context.TEXTURE_2D_ARRAY, 1, BitmapData.__textureInternalFormat, atlasBitmapData.image.buffer.width, atlasBitmapData.image.buffer.height, 10);
			//VisualRenderer.Get().context.texParameteri(GL.TEXTURE_2D_ARRAY,GL.TEXTURE_MIN_FILTER,GL.LINEAR);
			//VisualRenderer.Get().context.texParameteri(GL.TEXTURE_2D_ARRAY,GL.TEXTURE_MAG_FILTER,GL.LINEAR);
			//VisualRenderer.Get().context.texParameteri(GL.TEXTURE_2D_ARRAY,GL.TEXTURE_WRAP_S,GL.CLAMP_TO_EDGE);
			//VisualRenderer.Get().context.texParameteri(GL.TEXTURE_2D_ARRAY,GL.TEXTURE_WRAP_T,GL.CLAMP_TO_EDGE);	
			//
			//var error:Int = VisualRenderer.Get().context.getError();
				//if (error != 0)
					//trace(error);			
			//VisualRenderer.Get().ActivateTexture();
					VisualRenderer.Get().context.activeTexture(VisualRenderer.Get().context.TEXTURE0 + index);		
		VisualRenderer.Get().context.bindTexture(VisualRenderer.Get().context.TEXTURE_2D, texture);
		//
		}
		//
		//
		//VisualRenderer.Get().context.texSubImage3D(VisualRenderer.Get().context.TEXTURE_2D_ARRAY, 0, 0, 0, index,2048, 2048,1,GL.RGBA, VisualRenderer.Get().context.UNSIGNED_BYTE, atlasBitmapData.image.data);
			//var error:Int = VisualRenderer.Get().context.getError();
				//if (error != 0)
					//trace(error);
		
		//VisualRenderer.Get().context.activeTexture(VisualRenderer.Get().context.TEXTURE0 + index);		
		//VisualRenderer.Get().context.bindTexture(VisualRenderer.Get().context.TEXTURE_2D, texture);
		VisualRenderer.Get().ActivateTexture();
		
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