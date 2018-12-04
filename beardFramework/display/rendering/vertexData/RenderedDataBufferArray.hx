package beardFramework.display.rendering.vertexData;
import lime.utils.Float32Array;

/**
 * ...
 * @author 
 */
class RenderedDataBufferArray 
{

	public var visualsCount:Int=0;
	@:isVar public var data(get, set):Float32Array;
	
	
	public function new() 
	{
		data = new Float32Array(0);
	}
	
	function get_data():Float32Array 
	{
		return data;
	}
	
	function set_data(value:Float32Array):Float32Array 
	{
		if(value != null)
			visualsCount = Math.round(value.length / 40)  ;
		else	visualsCount = 0;
		return data = value;
	}
	
	
	
	
}