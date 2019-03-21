package beardFramework.graphics.rendering;
import beardFramework.graphics.rendering.Shaders.Shader;
import beardFramework.graphics.rendering.vertexData.VertexAttribute;

/**
 * @author 
 */
typedef RenderingData =
{
	var shaders:Array<Shader>;
	var indices:Array<Int>;
	var vertices:Array<Float>;
	var vertexAttributes:Array<VertexAttribute>;
	var drawMode:Int;
	var name:String;
	var vertexStride:Int;
	var lightGroup:String;
		
}