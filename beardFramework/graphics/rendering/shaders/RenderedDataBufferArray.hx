package beardFramework.graphics.rendering.shaders;
import lime.utils.Float32Array;

/**
 * ...
 * @author 
 */
class RenderedDataBufferArray 
{

	public var activeDataCount:Int=0;
	public var size:Int = 0;
	public var objectStride:Int = 0;
	public var vertexPerObject:Int = 0;
	public var vertexStride:Int = 0;
	
	@:isVar public var data(get, set):Float32Array;
	
	
	public function new(vertexStride:Int = 0, vertexPerObject:Int = 0 ) 
	{
		data = new Float32Array(0);
		this.vertexStride = vertexStride;
		this.vertexPerObject = vertexPerObject;
		objectStride = vertexStride * vertexPerObject;
	}
	
	function get_data():Float32Array 
	{
		return data;
	}
	
	function set_data(value:Float32Array):Float32Array 
	{
		if(value != null)
			size = Math.round(value.length / objectStride)  ;
		else{
			size = 0;
			activeDataCount = 0;
		}
		return data = value;
	}
	
	
	
	
}