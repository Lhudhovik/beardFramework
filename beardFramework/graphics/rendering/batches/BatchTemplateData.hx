package beardFramework.graphics.rendering.batches;
import beardFramework.graphics.rendering.Shaders.Shader;
import beardFramework.graphics.rendering.vertexData.VertexAttribute;

/**
 * @author 
 */
typedef BatchTemplateData =
{
	var shaders:Array<Shader>;
	var indices:Array<Int>;
	var vertices:Array<Float>;
	var vertexAttributes:Array<VertexAttribute>;
	var drawMode:Int;
	var name:String;
	var type:String;
	var vertexStride:Int;
	var vertexPerObject:Int; 
}