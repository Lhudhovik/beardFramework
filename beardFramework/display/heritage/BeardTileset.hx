package beardFramework.display.heritage;

import beardFramework.resources.assets.AssetManager;
import beardFramework.resources.assets.Atlas;
import openfl.display.BitmapData;
import openfl.display.Tileset;
import openfl.geom.Rectangle;

/**
 * ...
 * @author Ludo
 */
class BeardTileset extends Tileset 
{

	public var atlas:String;
	public function new(atlas: String, data:BitmapData, rects:Array<Rectangle>=null) 
	{
		super(data, rects);
		this.atlas = atlas;
		
	}
	
}