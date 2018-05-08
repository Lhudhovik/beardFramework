package beardFramework.display.core;
import beardFramework.display.cameras.Camera;
import beardFramework.display.heritage.BeardTileArray;
import beardFramework.display.heritage.BeardTileMap;
import beardFramework.interfaces.ICameraDependent;
import beardFramework.resources.assets.AssetManager;
import openfl.display.Tile;
import openfl.geom.Matrix;
import openfl._internal.renderer.RenderSession;

using beardFramework.utils.SysPreciseTime;


@:access(beardFramework.display.heritage.BeardTileArray)
@:access(beardFramework.display.heritage.BeardTileMap)
@:access(openfl.geom.ColorTransform)
@:access(openfl.geom.Matrix)


/**
 * ...
 * @author Ludo
 */
class BeardVisual extends Tile implements ICameraDependent
{
	
	//private static var _adjustedMatrix:Matrix = new Matrix();
	
	public var atlas(default, null):String="";
	public var texture(default, null):String="";
	@:isVar public var name(get, set):String;
	public var width(get, set):Float;
	public var height(get, set):Float;
	
	private var cachedWidth:Float;
	private var cachedHeight:Float;
	public var textureWidth(default, null):Int;
	public var textureHeight(default, null):Int;
	
	public function new(texture:String="", atlas:String="") 
	{
		super(((texture != "" && atlas !="") ? AssetManager.Get().GetTileID(texture, atlas):-1));
		this.texture = texture;
		this.atlas = atlas;
		this.name = name;
		if (this.name == "") this.name = "BeardVisual" + Sys.preciseTime();
	
		UpdateDimensions();
		
		displayingCameras = new List<String>();
	}
	
	/* INTERFACE beardFramework.interfaces.ICameraDependent */
	
	public var restrictedCameras(default, null):Array<String>;
	
	public var displayingCameras(default, null):List<String>;
	
	public function AuthorizeCamera(addedCameraID:String):Void 
	{
		if (restrictedCameras == null) restrictedCameras = new Array<String>();
		
		if (restrictedCameras.indexOf(addedCameraID) == -1) restrictedCameras.push(addedCameraID);
	}
	
	public function ForbidCamera(forbiddenCameraID:String):Void 
	{
		if (restrictedCameras != null) restrictedCameras.remove(forbiddenCameraID);
	}
	
	public function RenderThroughCamera(camera:Camera, renderSession:RenderSession):Void 
	{
		//BeardGLBitmap.renderThroughCamera(this, renderSession, camera);
	}
	
	public function ChangeVisual(texture:String, atlas:String):Void
	{
		this.texture = texture;
		this.atlas = atlas;
		if ( this.atlas != "" && this.texture != ""){
			this.id = AssetManager.Get().GetTileID(texture, atlas);
			
			UpdateDimensions();
		}
		
	}
	
	public inline function UpdateDimensions():Void
	{
		if ( this.atlas != "" && this.texture != ""){
			textureWidth = Math.round(AssetManager.Get().GetAtlas(this.atlas).GetTextureDimensions(this.texture).width);
			textureHeight = Math.round(AssetManager.Get().GetAtlas(this.atlas).GetTextureDimensions(this.texture).height);
			cachedHeight = textureHeight * scaleY;
			cachedWidth = textureWidth * scaleX;
		}
		
	}
	
	
	/* INTERFACE beardFramework.interfaces.ICameraDependent */
	
	public function RenderMaskThroughCamera(camera:Camera, renderSession:RenderSession):Void 
	{
		
	}
	function get_name():String 
	{
		return name;
	}
	
	function set_name(value:String):String 
	{
		return name = value;
	}
	
	private function __updateTileArrayThroughCamera (position:Int, tileArray:BeardTileArray, forceUpdate:Bool, camera:Camera):Void {
		
		var cachePosition = tileArray.position;
		tileArray.position = position;
		
		if (__shaderDirty || forceUpdate) {
			
			tileArray.shader = __shader;
			__shaderDirty = false;
			
		}
		
		if (__colorTransformDirty || forceUpdate) {
			
			tileArray.colorTransform = __colorTransform;
			__colorTransformDirty = false;
			
		}
		
		if (__visibleDirty || forceUpdate) {
			
			tileArray.visible = __visible;
			tileArray.__bufferDirty = true;
			__visibleDirty = false;
			
		}
		
		if (__alphaDirty || forceUpdate) {
			
			tileArray.alpha = __alpha;
			tileArray.__bufferDirty = true;
			__alphaDirty = false;
			
		}
		
		if (__sourceDirty || forceUpdate) {
			
			if (__rect == null) {
				
				tileArray.id = __id;
				
			} else {
				
				tileArray.rect = rect;
				
			}
			
			tileArray.tileset = __tileset;
			tileArray.__bufferDirty = true;
			__sourceDirty = true;
			
		}
		
		tileArray.onCamera = camera.Contains(this);
		
		if (camera.needRenderUpdate || __transformDirty || forceUpdate) {
			
			if (__originX != 0 || __originY != 0) {
				
						
				Tile.__tempMatrix.a = 1 + __matrix.a * camera.zoom;
				Tile.__tempMatrix.b = 0 + __matrix.b * camera.transform.d;
				Tile.__tempMatrix.c = 0 + __matrix.c * camera.zoom;
				Tile.__tempMatrix.d = 1 + __matrix.d * camera.transform.d;
				Tile.__tempMatrix.tx = -__originX + camera.transform.tx + camera.viewportWidth*0.5 +  (__matrix.tx - camera.centerX) *camera.zoom  ;
				Tile.__tempMatrix.ty = -__originY + camera.transform.ty + camera.viewportHeight *0.5 + (__matrix.ty - camera.centerY) *camera.zoom;
				
				tileArray.matrix = Tile.__tempMatrix;
				
			} else {
				
				
				Tile.__tempMatrix.a = __matrix.a * camera.zoom;
				Tile.__tempMatrix.b = __matrix.b * camera.transform.d;
				Tile.__tempMatrix.c = __matrix.c * camera.zoom;
				Tile.__tempMatrix.d = __matrix.d * camera.transform.d;
				Tile.__tempMatrix.tx = camera.transform.tx + camera.viewportWidth*0.5 +  (__matrix.tx - camera.centerX) *camera.zoom;
				Tile.__tempMatrix.ty = camera.transform.ty + camera.viewportHeight *0.5 + (__matrix.ty - camera.centerY) *camera.zoom;
				
				tileArray.matrix = Tile.__tempMatrix;
				
			}
			
			tileArray.__bufferDirty = true;
			__transformDirty = false;
			
		}
		
		tileArray.position = cachePosition;
		
	}
	
	
	override function set_scaleX(value:Float):Float 
	{
		super.set_scaleX(value);
		
		cachedWidth = textureWidth * value;
		
		return value;
	}
	
	override function set_scaleY(value:Float):Float 
	{
		super.set_scaleY(value);
		
		cachedHeight = textureHeight * value;
		
		return value;
	}
	function set_width(value:Float):Float 
	{
	
		if (value != textureWidth)			
			scaleX = value / textureWidth;
			
		else 		
			scaleX = 1;
				
		return value;
	}
	
	inline function get_width():Float 
	{		
		return cachedWidth ;
	}
	
	inline function get_height():Float 
	{
		return cachedHeight;
	}
	
	function set_height(value:Float):Float 
	{
		if (value != textureHeight)			
			scaleX = value / textureHeight;
			
		else 		
			scaleX = 1;
				
		return value;
	}
	
	override inline private function get_x ():Float {
		
		return matrix.tx;
		
	}
	
	
	override inline private function get_y ():Float {
		
		return matrix.ty;
		
	}
	
}