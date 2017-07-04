package beardFramework.display.core;

import openfl.display.Tile;
import openfl.display.Tilemap;
import openfl.display.Tileset;

/**
 * ...
 * @author Ludo
 */
class BeardTileMap extends Tilemap
{
	private var widthChanged:Bool;
	private var heightChanged:Bool;
	private var cachedWidth:Float;
	private var cachedHeight:Float;
	public var restrictedCameras(default, null):Array<String>;
	
	public function new(width:Int, height:Int, tileset:Tileset=null, smoothing:Bool=true) 
	{
		super(width, height, tileset, smoothing);
		widthChanged = heightChanged = true;
		
	}
	
	
	//HERITAGE
	override public function addTile(tile:Tile):Tile 
	{
		widthChanged = heightChanged = true;
		return super.addTile(tile);
	}
	
	override public function addTiles(tiles:Array<Tile>):Array<Tile> 
	{
		widthChanged = heightChanged = true;
		return super.addTiles(tiles);
	}
	
	override public function addTileAt(tile:Tile, index:Int):Tile 
	{
		widthChanged = heightChanged = true;
		return super.addTileAt(tile, index);
	}
	
	override public function removeTile(tile:Tile):Tile 
	{
		widthChanged = heightChanged = true;
		return super.removeTile(tile);
	}
	
	override public function removeTileAt(index:Int):Tile 
	{
		widthChanged = heightChanged = true;
		return super.removeTileAt(index);
	}
	
	override public function removeTiles(beginIndex:Int = 0, endIndex:Int = 0x7fffffff):Void 
	{
		widthChanged = heightChanged = true;
		super.removeTiles(beginIndex, endIndex);
	}
	
	
	
	override function get_width():Float 
	{
		if (widthChanged){
			cachedWidth = super.get_width();
			widthChanged = false;
		}
		return cachedWidth;
	}
	
	override function get_height():Float 
	{
		if (heightChanged){
			cachedHeight = super.get_height();
			heightChanged = false;
		}
		return cachedHeight;
	}
	//override function set_height(value:Float):Float 
	//{
		//heightChanged = true;
		//return super.set_height(value);
	//}
	override function set_scaleX(value:Float):Float 
	{
		widthChanged = true;
		return super.set_scaleX(value);
	}
	
	override function set_scaleY(value:Float):Float 
	{
		heightChanged = true;
		return super.set_scaleY(value);
	}
	
}