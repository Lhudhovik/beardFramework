package beardFramework.graphics.rendering;

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
		
}