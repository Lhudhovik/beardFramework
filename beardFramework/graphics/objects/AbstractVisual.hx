package beardFramework.graphics.objects;
import beardFramework.graphics.objects.RenderedObject;
import beardFramework.resources.assets.AssetManager;
import beardFramework.resources.assets.Atlas.SubTextureData;
import beardFramework.utils.libraries.StringLibrary;
import beardFramework.graphics.lights.Shadow;
/**
 * ...
 * @author 
 */
class AbstractVisual extends RenderedObject 
{
	private static var instanceCount:Int = 0;
	
	@:isVar	public var atlas(default, set):String;
	@:isVar	public var texture(get, set):String;

	private function new(texture:String="", atlas:String="" , name:String = "") 
	{
		super();
		if (name == "") this.name = "Visual_" + instanceCount;
		else this.name = name;
		instanceCount++;
	
		this.texture = texture;
		this.atlas = atlas;
		
	
		material.SetComponentTexture(StringLibrary.DIFFUSE,texture);
		
		
		if (atlas != "" && texture != "" )
		{
			var texture:SubTextureData = AssetManager.Get().GetSubTextureData(texture, atlas);
			SetBaseWidth(texture.imageArea.width);
			SetBaseHeight(texture.imageArea.height);
			
			material.SetComponentAtlas(StringLibrary.DIFFUSE,  atlas);
			material.SetComponentUVs(StringLibrary.DIFFUSE, texture.uvX, texture.uvY, texture.uvW, texture.uvH);
		}
		else 
		{
			
			if (texture == "" || AssetManager.Get().GetTexture(texture) == null)
			{
				texture = StringLibrary.DEFAULT;
			}
			SetBaseWidth(AssetManager.Get().GetTexture(texture).width);
			SetBaseHeight(AssetManager.Get().GetTexture(texture).height);
			material.SetComponentUVs(StringLibrary.DIFFUSE, 0, 0, 1, 1);
			
		}
		
	}
	public inline function GetTextureData():SubTextureData
	{
		return AssetManager.Get().GetSubTextureData(texture, atlas);
	}
	
	function set_texture(value:String):String 
	{
		if (value != texture){
			material.components[StringLibrary.DIFFUSE].texture = value;
			Reinit();
			isDirty = true;
		}
		return material.components[StringLibrary.DIFFUSE].texture;
	}
	
	function get_texture():String	return material.components[StringLibrary.DIFFUSE].texture;
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
			var subData:SubTextureData;
			
			if (atlas != "" && atlas != null && (subData = AssetManager.Get().GetSubTextureData(texture, atlas)) != null)
			{
				SetBaseWidth(subData.imageArea.width);
				SetBaseHeight(subData.imageArea.height);
				
				
			}
			else if (AssetManager.Get().GetTexture(texture) != null)
			{
				SetBaseWidth(AssetManager.Get().GetTexture(texture).width);
				SetBaseHeight(AssetManager.Get().GetTexture(texture).height);
			}
			
		}
		
			
		
		
	}
}