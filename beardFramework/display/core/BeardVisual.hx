package beardFramework.display.core;
import beardFramework.display.cameras.Camera;
import beardFramework.interfaces.ICameraDependent;
import beardFramework.resources.assets.AssetManager;
import openfl.display.Tile;
import openfl.geom.Matrix;
import openfl._internal.renderer.RenderSession;


using beardFramework.utils.SysPreciseTime;
/**
 * ...
 * @author Ludo
 */
class BeardVisual extends Tile implements ICameraDependent
{
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
			cachedHeight = textureHeight * __scaleY;
			cachedWidth = textureWidth * __scaleX;
		}
		
	}
	function get_name():String 
	{
		return name;
	}
	
	function set_name(value:String):String 
	{
		return name = value;
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