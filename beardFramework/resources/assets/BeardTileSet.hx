package resources.assets;
import openfl.display.BitmapData;
import openfl.display.Tileset;
import openfl.geom.Rectangle;

/**
 * ...
 * @author Ludo
 */
class BeardTileSet extends Tileset
{
	private var types:Map<String, Int>;
	public function new(bitmapData:BitmapData, ?rects:Array<Rectangle>) 
	{
		super(bitmapData, rects);
		types = new Map<String, Int>();
	}
	
	public function addTileType(name:String, rect:Rectangle):Int 
	{
		var index : Int = addRect(rect);
		types[name] = index;
		
		return index;
	}
	
	public function GetType(name:String):Int
	{
		return types[name] != null ? types[name] : -1;
	}
	
}