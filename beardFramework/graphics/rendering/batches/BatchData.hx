package beardFramework.graphics.rendering.batches;
import beardFramework.graphics.rendering.Shaders.Shader;
import beardFramework.graphics.rendering.vertexData.VertexAttribute;

/**
 * @author 
 */
typedef BatchData =
{
	var shaders:Array<Shader>;
	var indices:Array<Int>;
	var vertices:Array<Float>;
	var vertexAttributes:Array<VertexAttribute>;
	var drawMode:Int;
	var needOrdering:Bool;
	var name:String;
	var type:String;
	var vertexStride:Int;
	var vertexPerObject:Int; 
}