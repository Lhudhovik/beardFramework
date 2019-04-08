package beardFramework.graphics.rendering.batches;
import beardFramework.graphics.rendering.shaders.Shader;
import beardFramework.graphics.rendering.shaders.Shader.NativeShader;
import beardFramework.graphics.rendering.shaders.VertexAttribute;

/**
 * @author 
 */
typedef BatchRenderingData =
{
	>RenderingData,
	var type:String;
	var vertexPerObject:Int; 
	var z:Float; 
}