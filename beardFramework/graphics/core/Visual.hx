package beardFramework.graphics.core;

import beardFramework.graphics.rendering.Renderer;
import beardFramework.resources.assets.AssetManager;
import beardFramework.resources.assets.Atlas.SubTextureData;
import haxe.ds.Vector;
import openfl.geom.Matrix;

/**
 * ...
 * @author 
 */
class Visual extends RenderedObject
{
	private static var instanceCount:Int = 0;
	
@:isVar	public var atlas(default, set):String;
@:isVar	public var texture(default, set):String;

	public function new(texture:String, atlas:String , name:String = "") 
	{
		super();
		
		
		if (name == "") this.name = "Visual_" + instanceCount;
		else this.name = name;
		instanceCount++;
	
		this.texture = texture;
		this.atlas = atlas;
				
		var texture:SubTextureData = AssetManager.Get().GetSubTextureData(texture, atlas);
		
		SetBaseWidth(texture.imageArea.width);
		SetBaseHeight(texture.imageArea.height);
			
		
		renderer = Renderer.Get();
		
		
	}
	
	public inline function GetTextureData():SubTextureData
	{
		return AssetManager.Get().GetSubTextureData(texture, atlas);
	}
	
	function set_texture(value:String):String 
	{
		if (value != texture){
			texture = value;
			
			Reinit();
			isDirty = true;
		}
		return texture;
	}
	
	function set_atlas(value:String):String 
	{
		if (value != atlas){
			atlas = value;
			Reinit();
			isDirty = true;
		}
		return atlas;
	}
	
	private function Reinit():Void
	{
		if (texture != null && atlas != null)
		{
			
			var texture:SubTextureData = AssetManager.Get().GetSubTextureData(texture, atlas);
			SetBaseWidth(texture.imageArea.width);
			SetBaseHeight(texture.imageArea.height);
			
		}
		
			
		
		
	}
	
	

}

