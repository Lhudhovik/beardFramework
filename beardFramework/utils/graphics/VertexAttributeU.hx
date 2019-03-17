package beardFramework.utils.graphics;
import beardFramework.graphics.core.BatchedVisual;
import beardFramework.resources.assets.AssetManager;
import beardFramework.resources.assets.Atlas.SubTextureData;
import lime.utils.Float32Array;

/**
 * ...
 * @author 
 */
class VertexAttributeU 
{

	public static function GenerateVertexAttributesFromVisual(visual:BatchedVisual):Float32Array
	{
		
		var textureData:SubTextureData = AssetManager.Get().GetSubTextureData(visual.texture, visual.atlas);
		trace(textureData.uvX);
		trace(textureData.uvY);
		trace(textureData.uvW);
		trace(textureData.uvH);
		
		return 	new Float32Array(null,[
		visual.x, 
		visual.y,  
		//((visual.color >> 16) & 0xff) / 255.0, 
		0.2, 
		//((visual.color >>  8) & 0xff) / 255.0,
		0.5,
		//( visual.color & 0xff) / 255.0, 
		0.2, 
		visual.alpha,
		textureData.uvX,
		textureData.uvY,
		textureData.uvW,
		textureData.uvH]);
		
	}
	
}