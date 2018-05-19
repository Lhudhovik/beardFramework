package beardFramework.resources.assets;
import beardFramework.display.heritage.BeardTileset;
import beardFramework.display.rendering.VisualRenderer;
import beardFramework.utils.TextureUtils;
import lime.graphics.opengl.GL;
import lime.graphics.opengl.GLTexture;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Tileset;
import openfl.geom.Point;
import openfl.geom.Rectangle;


/**
 * ...
 * @author Ludo
 */
class Atlas 
{
	private static var atlasCount:Int = 1;
	public var atlasBitmapData:BitmapData;
	private var subAreas:Map<String, SubTextureData>;
	private var usedBitmapData:Map<String,UsedBitmapData>;
	private var usedTileRect:Map<String,Int>;
	public var texture:GLTexture;
	//public var name:String;
	public function new(name:String, bitmapData:BitmapData, xml:Xml) 
	{
		
		usedBitmapData = new Map<String, UsedBitmapData>();
		usedTileRect = new Map<String, Int>();
		subAreas = new Map<String, SubTextureData>();
		atlasBitmapData = bitmapData.clone();
		tileSet = new BeardTileset(name, atlasBitmapData);
		bitmapData.dispose();
		
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
            var name:String        = subTexture.get("name");
            var x:Float            = getXmlFloat(subTexture, "x");
            var y:Float            = getXmlFloat(subTexture, "y");
            var width:Float        = getXmlFloat(subTexture, "width");
            var height:Float       = getXmlFloat(subTexture, "height");
            var frameX:Float       = getXmlFloat(subTexture, "frameX");
            var frameY:Float       = getXmlFloat(subTexture, "frameY");
            var frameWidth:Float   = getXmlFloat(subTexture, "frameWidth");
            var frameHeight:Float  = getXmlFloat(subTexture, "frameHeight");
            var rotated:Bool       = parseBool(subTexture.get("rotated"));
			
			//trace(name);
		
            imageArea.setTo(x, y, width, height);
            frame.setTo(frameX, frameY, frameWidth, frameHeight);
			subAreas[name] = new SubTextureData(imageArea.clone(),((frameWidth > 0 && frameHeight > 0) ? frame.clone() : null) , rotated, x/atlasBitmapData.width, y/atlasBitmapData.height, width/atlasBitmapData.width, height/atlasBitmapData.height );
			subAreas[name].ID = tileSet.addRect(imageArea.clone());
            
        }
		
		
		//texture = GL.createTexture();
		//GL.bindTexture(GL.TEXTURE_2D, texture);
		//GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.REPEAT);	
		//GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.REPEAT);
		//GL.texParameteri (GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.LINEAR);
		//GL.texParameteri (GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.LINEAR);
		//
		//GL.texImage2D(GL.TEXTURE_2D, 0, GL.RGB, atlasBitmapData.width, atlasBitmapData.height, 0, GL.RGB, GL.UNSIGNED_BYTE, atlasBitmapData);
		//GL.activeTexture(GL.TEXTURE0 + 3 );
		//GL.bindTexture(GL.TEXTURE_2D, texture);
		
		texture = atlasBitmapData.getTexture(GL.context);
		GL.activeTexture(GL.TEXTURE0);		
		GL.bindTexture(GL.TEXTURE_2D, texture);
		VisualRenderer.Get().ActivateTexture();
    }
      private function getXmlFloat(xml:Xml, attributeName:String):Float
    {
        var value:String = xml.get (attributeName);
        if (value != null)
            return Std.parseFloat(value);
        else
            return 0;
    }
     private function parseBool(value:String):Bool
    {
        return value != null ? value.toLowerCase() == "true" : false;
    }
	public function GetBitmapData(name:String):BitmapData
	{	
		if (subAreas[name] == null) return null;
		
		//trace(subAreas[name].imageArea.x);
		
		if (!usedBitmapData.exists(name)) 
		{
			var source:Rectangle = TextureUtils.GetRectangle();
			source.width = subAreas[name].imageArea.width >= subAreas[name].frame.width? subAreas[name].imageArea.width : subAreas[name].frame.width;
			source.height = subAreas[name].imageArea.height >= subAreas[name].frame.height? subAreas[name].imageArea.height : subAreas[name].frame.height;
			source.x = -subAreas[name].frame.x;
			source.y = -subAreas[name].frame.y;
			
			var bitmapData:BitmapData = new BitmapData(Math.ceil(source.width), Math.ceil(source.height), true, 0x00ffffff);
			bitmapData.copyPixels(atlasBitmapData, subAreas[name].imageArea, new Point(source.x, source.y));
			//trace("bitmapdData added");
			usedBitmapData[name] = 
			{
				bitmapData:bitmapData,
				count:0
			}
		}
		
		usedBitmapData[name].count++;
		//trace(usedBitmapData[name].count);
		
		return usedBitmapData[name].bitmapData;
		
	}
	
	public inline function GetTileID(name:String):Int
	{
		if (subAreas[name] == null) return -1;
		
		//trace(subAreas[name].imageArea.x)
		
		//if (!usedTileRect.exists(name)) 
		//{
			//var source:Rectangle = TextureUtils.GetRectangle();
			//source.width = subAreas[name].imageArea.width >= subAreas[name].frame.width? subAreas[name].imageArea.width : subAreas[name].frame.width;
			//source.height = subAreas[name].imageArea.height >= subAreas[name].frame.height? subAreas[name].imageArea.height : subAreas[name].frame.height;
			//source.x = -subAreas[name].frame.x;
			//source.y = -subAreas[name].frame.y;
			//
			//usedTileRect[name] = tileSet.addRect(source);
			//
		//}
				//
		return subAreas[name].ID;
		
	}
	
	public inline function GetTextureDimensions(name:String):Rectangle
	{
		if (subAreas[name] == null){
			
				//pool
			return new Rectangle();
		}
		
		return subAreas[name].imageArea;
		
		
	}
	
	public inline function GetSubTextureData(textureName:String):SubTextureData
	{
		trace(subAreas);
		trace(subAreas[textureName]);
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
	
	public function DisposeBitmapData(name:String):Void
	{
		if (usedBitmapData.exists(name))
		{
			
			if (--usedBitmapData[name].count <= 0){
				
				usedBitmapData[name].bitmapData.dispose();
				usedBitmapData[name].bitmapData = null;
				usedBitmapData[name] = null;
				usedBitmapData.remove(name);
				//trace("bitmap Removed");
			}
			
			
		}
		
		
	}
	
}

class SubTextureData
{
	public var imageArea:Rectangle;
	public var frame:Rectangle;
	public var rotated : Bool;
	public var ID:Int;
	public var uvX:Float;
	public var uvY:Float;
	public var uvW:Float;
	public var uvH:Float;
	public function new(imageArea:Rectangle, frame:Rectangle, rotated:Bool, uvX:Float, uvY:Float,  uvW:Float, uvH:Float)
	{
		
		this.imageArea = imageArea;
		this.frame = frame != null? frame : new Rectangle();
		this.rotated = rotated;
		this.uvX = uvX;
		this.uvY = uvY;
		this.uvW = uvW;
		this.uvH = uvH;
		
		
	}
	
}

typedef UsedBitmapData = 
{
	var bitmapData:BitmapData;
	var count:Int;
}