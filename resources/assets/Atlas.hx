package beardFramework.resources.assets;
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
	public var atlasBitmapData:BitmapData;
	private var subAreas:Map<String, SubArea>;
	public function new(bitmapData:BitmapData, xml:Xml) 
	{
		
		
		subAreas = new Map<String, SubArea>();
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

            imageArea.setTo(x, y, width, height);
            frame.setTo(frameX, frameY, frameWidth, frameHeight);
            subAreas[name] = new SubArea(imageArea, frameWidth > 0 && frameHeight > 0 ? frame : null ,rotated);
            
        }
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
		var source:Rectangle = new Rectangle();
		source.width = subAreas[name].imageArea.width >= subAreas[name].frame.width? subAreas[name].imageArea.width : subAreas[name].frame.width;
		source.height = subAreas[name].imageArea.height >= subAreas[name].frame.height? subAreas[name].imageArea.height : subAreas[name].frame.height;
		source.x = -subAreas[name].frame.x;
		source.y = -subAreas[name].frame.y;
		var bitmapData:BitmapData = new BitmapData(Math.ceil(source.width), Math.ceil(source.height));
		bitmapData.copyPixels(atlasBitmapData, subAreas[name].imageArea, new Point(source.x, source.y));
		return bitmapData;
		
	}
	public function ToBeardTileSet():Tileset{
		
		var tileSet : Tileset= new Tileset(atlasBitmapData);
		
		return tileSet;
		
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

private class SubArea
{
	public var imageArea:Rectangle;
	public var frame:Rectangle;
	public var rotated : Bool;
	public function new(imageArea:Rectangle, frame:Rectangle, rotated:Bool)
	{
		
		this.imageArea = imageArea;
		this.frame = frame != null? frame : new Rectangle();
		this.rotated = rotated;
		
	}
	
}