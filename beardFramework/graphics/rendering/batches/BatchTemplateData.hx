package beardFramework.graphics.rendering.batches;
import beardFramework.graphics.rendering.Shaders.Shader;
import beardFramework.graphics.rendering.vertexData.VertexAttribute;

/**
 * @author 
 */
typedef BatchTemplateData =
{
	>RenderingData,
	var type:String;
	var vertexPerObject:Int; 
	var z:Float; 
}