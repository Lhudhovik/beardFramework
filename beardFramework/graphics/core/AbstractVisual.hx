package beardFramework.graphics.core;
import beardFramework.resources.assets.AssetManager;
import beardFramework.resources.assets.Atlas.SubTextureData;

/**
 * ...
 * @author 
 */
class AbstractVisual extends RenderedObject 
{
	private static var instanceCount:Int = 0;
	
	@:isVar	public var atlas(default, set):String;
	@:isVar	public var texture(default, set):String;
	
	private function new(texture:String, atlas:String , name:String = "") 
	{
		super();
		if (name == "") this.name = "Visual_" + instanceCount;
		else this.name = name;
		instanceCount++;
	
		this.texture = texture;
		this.atlas = atlas;
		
	
		material.SetComponentTexture("diffuse",texture);
		
		
		if (atlas != "")
		{
			var texture:SubTextureData = AssetManager.Get().GetSubTextureData(texture, atlas);
			SetBaseWidth(texture.imageArea.width);
			SetBaseHeight(texture.imageArea.height);
			
			material.SetComponentAtlas("diffuse",  atlas);
			material.SetComponentUVs("diffuse", texture.uvX, texture.uvY, texture.uvW, texture.uvH);
		}
		else if (AssetManager.Get().GetTexture(texture) != null)
		{
			SetBaseWidth(AssetManager.Get().GetTexture(texture).width);
			SetBaseHeight(AssetManager.Get().GetTexture(texture).height);
			material.SetComponentUVs("diffuse", 0, 0, 1, 1);
			
		}
		
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
		if (texture != null && texture != "")
		{
			
			if (atlas != "" && atlas != null)
			{
				var texture:SubTextureData = AssetManager.Get().GetSubTextureData(texture, atlas);
				SetBaseWidth(texture.imageArea.width);
				SetBaseHeight(texture.imageArea.height);
			}
			else if (AssetManager.Get().GetTexture(texture) != null)
			{
				SetBaseWidth(AssetManager.Get().GetTexture(texture).width);
				SetBaseHeight(AssetManager.Get().GetTexture(texture).height);
			}
			
		}
		
			
		
		
	}
}