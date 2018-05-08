package beardFramework.display.heritage;

import beardFramework.display.cameras.Camera;
import beardFramework.display.core.BeardVisual;
import beardFramework.display.renderers.gl.BeardGLTilemap;
import beardFramework.interfaces.ICameraDependent;
import beardFramework.resources.assets.AssetManager;
import openfl.display.Tile;
import openfl.display.TileArray;
import openfl.display.Tilemap;
import openfl.display.Tileset;
import openfl._internal.renderer.RenderSession;


@:access(openfl.display.Tilemap)
@:access(openfl.display.TileArray)
@:access(openfl.display.Tile)
@:access(beardFramework.display.core.BeardVisual)
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
	
	private function __updateTileArrayThroughCamera (camera:Camera):Void {
		
		if (__tiles.length > 0) {
			
			if (__tileArray == null) {
				__tileArray = new BeardTileArray ();
			}
			
			/*if (__tileArray.length < numTiles) {*/
				__tileArray.length = numTiles;
			/*//}*/
			
			var tile:Tile;
			
			for (i in 0...__tiles.length) {
				
				tile = __tiles[i];
				if (tile != null) {
					cast(tile, BeardVisual).__updateTileArrayThroughCamera(i,cast(__tileArray, BeardTileArray), __tileArrayDirty,camera);
				}
				
			}
			
		}
		
		__tileArrayDirty = false;
		
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
	
	@:beta override public function getTiles ():TileArray {
		
		__updateTileArray ();
		
		if (__tileArray == null) {
			__tileArray = new BeardTileArray ();
		}
		
		return __tileArray;
		
	}
	
	override private function __updateTileArray ():Void {
		
		if (__tiles.length > 0) {
			
			if (__tileArray == null) {
				__tileArray = new BeardTileArray ();
			}
			
			//if (__tileArray.length < numTiles) {
				__tileArray.length = numTiles;
			//}
			
			var tile:Tile;
			
			for (i in 0...__tiles.length) {
				
				tile = __tiles[i];
				if (tile != null) {
					tile.__updateTileArray (i, __tileArray, __tileArrayDirty);
				}
				
			}
			
		}
		
		__tileArrayDirty = false;
		
	}
	
	@:beta override  public function setTiles (tileArray:TileArray):Void {
		
		__tileArray = BeardTileArray.FromTileArray(tileArray);
		numTiles = __tileArray.length;
		__tileArray.__bufferDirty = true;
		__tileArrayDirty = false;
		__tiles.length = 0;
		#if !flash
		__setRenderDirty ();
		#end
		
	}
	
	/* INTERFACE beardFramework.interfaces.ICameraDependent */
	
	public function RenderMaskThroughCamera(camera:Camera, renderSession:RenderSession):Void 
	{
		
		for (atlasTileset in tilesets)
		{
			this.tileset = atlasTileset;
			BeardGLTilemap.renderMaskThroughCamera (this, renderSession,camera);
		}
		
	}
	
	
}