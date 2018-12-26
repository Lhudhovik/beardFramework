package beardFramework.graphics.core;

import beardFramework.graphics.rendering.Renderer;
import beardFramework.graphics.rendering.VisualRenderer;
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
	
	public var atlas:String;
	public var texture:String;

	public function new(texture:String, atlas:String , name:String = "") 
	{
		super();
		
		
		if (name == "") name = "Visual_" + instanceCount;
		instanceCount++;
	
		this.texture = texture;
		this.atlas = atlas;
				
		var texture:SubTextureData = AssetManager.Get().GetSubTextureData(texture, atlas);
				
		SetBaseWidth(Math.round(texture.imageArea.width));
		SetBaseHeight(Math.round(texture.imageArea.height));
			
		
		renderer = Renderer.Get();
		
		
	}
	
	public inline function GetTextureData():SubTextureData
	{
		return AssetManager.Get().GetSubTextureData(texture, atlas);
	}
	
	

}

