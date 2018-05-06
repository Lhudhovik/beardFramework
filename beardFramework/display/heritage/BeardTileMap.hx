package beardFramework.display.heritage;

import beardFramework.display.cameras.Camera;
import beardFramework.display.core.BeardVisual;
import beardFramework.display.renderers.gl.BeardGLTilemap;
import beardFramework.interfaces.ICameraDependent;
import beardFramework.resources.assets.AssetManager;
import openfl.display.Tile;
import openfl.display.Tilemap;
import openfl.display.Tileset;
import openfl._internal.renderer.RenderSession;
/**
 * ...
 * @author Ludo
 */
class BeardTileMap extends Tilemap implements ICameraDependent
{
	private var tilesets:Array<Tileset>;
	
	public function new(width:Int, height:Int, tileset:Tileset=null, smoothing:Bool=true) 
	{
		super(width, height, tileset, smoothing);
		tilesets = new Array<Tileset>();
		if (tileset != null) tilesets.push(tileset);
		
	}
	
	public inline function AddTileSet(tileset:Tileset):Void
	{
		if(tilesets.indexOf(tileset) == -1)	tilesets.push(tileset);
	}
	
	public inline function RemoveTileSet(tileset:Tileset):Void
	{
		tilesets.remove(tileset);
	}
	
	/* INTERFACE beardFramework.interfaces.ICameraDependent */
	
	public var restrictedCameras(default, null):Array<String>;
	
	public var displayingCameras(default, null):List<String>;
	
	public function AuthorizeCamera(addedCameraID:String):Void 
	{
		
	}
	
	public function ForbidCamera(forbiddenCameraID:String):Void 
	{
		
	}
	
	public function RenderThroughCamera(camera:Camera, renderSession:RenderSession):Void 
	{
		for (atlasTileset in tilesets)
		{
			this.tileset = atlasTileset;
			BeardGLTilemap.renderThroughCamera (this, renderSession,camera);
		}
	}
	
	public inline function HasTileset(atlas:String):Bool
	{
		var has:Bool = false;
		for (atlasTileset in tilesets)
			if (cast(atlasTileset, BeardTileset).atlas == atlas)
				has = true;
		
		return has;
	}
	
	override public function addTile(tile:Tile):Tile 
	{
		super.addTile(tile);
		
		var hasAtlas:Bool = false;
		
		for (atlasTileset in tilesets)
			if (cast(atlasTileset, BeardTileset).atlas == cast (tile, BeardVisual).atlas){
				hasAtlas = true;
				break;
			}
		
			if (!hasAtlas)
				tilesets.push(AssetManager.Get().GetAtlas(cast (tile, BeardVisual).atlas).tileSet );
		
		
		return tile;
	}
	override public function addTileAt(tile:Tile, index:Int):Tile 
	{
		super.addTileAt(tile, index);
		 
		var hasAtlas:Bool = false;
		
		for (atlasTileset in tilesets)
			if (cast(atlasTileset, BeardTileset).atlas == cast (tile, BeardVisual).atlas){
				hasAtlas = true;
				break;
			}
		
			if (!hasAtlas)
				tilesets.push(AssetManager.Get().GetAtlas(cast (tile, BeardVisual).atlas).tileSet );
		
		
		return tile;
	}
	
	override public function addTiles(tiles:Array<Tile>):Array<Tile> 
	{
		 super.addTiles(tiles);
		
		var hasAtlas:Bool = false;
		
		for (atlasTileset in tilesets)
			if (cast(atlasTileset, BeardTileset).atlas == cast (tiles[0], BeardVisual).atlas){
				hasAtlas = true;
				break;
			}
		
			if (!hasAtlas)
				tilesets.push(AssetManager.Get().GetAtlas(cast (tiles[0], BeardVisual).atlas).tileSet );
		 
		 
		return tiles;
	}
	
	////HERITAGE
	//override public function addTile(tile:Tile):Tile 
	//{
		//widthChanged = heightChanged = true;
		//return super.addTile(tile);
	//}
	//
	//override public function addTiles(tiles:Array<Tile>):Array<Tile> 
	//{
		//widthChanged = heightChanged = true;
		//return super.addTiles(tiles);
	//}
	//
	//override public function addTileAt(tile:Tile, index:Int):Tile 
	//{
		//widthChanged = heightChanged = true;
		//return super.addTileAt(tile, index);
	//}
	//
	//override public function removeTile(tile:Tile):Tile 
	//{
		//widthChanged = heightChanged = true;
		//return super.removeTile(tile);
	//}
	//
	//override public function removeTileAt(index:Int):Tile 
	//{
		//widthChanged = heightChanged = true;
		//return super.removeTileAt(index);
	//}
	//
	//override public function removeTiles(beginIndex:Int = 0, endIndex:Int = 0x7fffffff):Void 
	//{
		//widthChanged = heightChanged = true;
		//super.removeTiles(beginIndex, endIndex);
	//}
	//
	//
	//
	//override function get_width():Float 
	//{
		//if (widthChanged){
			//cachedWidth = super.get_width();
			//widthChanged = false;
		//}
		//return cachedWidth;
	//}
	//
	//override function get_height():Float 
	//{
		//if (heightChanged){
			//cachedHeight = super.get_height();
			//heightChanged = false;
		//}
		//return cachedHeight;
	//}
	////override function set_height(value:Float):Float 
	////{
		////heightChanged = true;
		////return super.set_height(value);
	////}
	//override function set_scaleX(value:Float):Float 
	//{
		//widthChanged = true;
		//return super.set_scaleX(value);
	//}
	//
	//override function set_scaleY(value:Float):Float 
	//{
		//heightChanged = true;
		//return super.set_scaleY(value);
	//}
	
}