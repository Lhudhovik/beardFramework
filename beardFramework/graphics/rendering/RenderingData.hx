package beardFramework.graphics.rendering;
import beardFramework.graphics.rendering.shaders.Shader;
import beardFramework.graphics.rendering.shaders.Shader.NativeShader;
import beardFramework.graphics.rendering.shaders.VertexAttribute;

/**
 * @author 
 */
typedef RenderingData =
{
	var shaders:Array<NativeShader>;
	var indices:Array<Int>;
	var vertices:Array<Float>;
	var vertexAttributes:Array<VertexAttribute>;
	var drawMode:Int;
	var name:String;
	var vertexStride:Int;
	var lightGroup:String;
		
}