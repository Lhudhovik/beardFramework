package beardFramework.graphics.core;
import beardFramework.graphics.shaders.Shader;
import beardFramework.graphics.shaders.Shader.NativeShader;
import beardFramework.graphics.shaders.VertexAttribute;

/**
 * @author 
 */
typedef RenderingData =
{
	var shader:String;
	var indices:Array<Int>;
	var vertices:Array<Float>;
	var vertexAttributes:Array<VertexAttribute>;
	var drawMode:Int;
	var name:String;
	var vertexStride:Int;
	var lightGroup:String;
		
}