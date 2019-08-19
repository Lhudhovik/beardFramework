package beardFramework.graphics.batches;
import beardFramework.graphics.shaders.Shader;
import beardFramework.graphics.shaders.Shader.NativeShader;
import beardFramework.graphics.shaders.VertexAttribute;

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