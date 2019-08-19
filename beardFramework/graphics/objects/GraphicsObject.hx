package beardFramework.graphics.objects;
import beardFramework.interfaces.ISpatialized;
import beardFramework.utils.graphics.Color;

/**
 * ...
 * @author 
 */
class GraphicsObject implements ISpatialized
{
	public var alpha(get, set):Float;
	public var color(get, set):Color;

	public function new() 
	{
		
	}
	
	
	/* INTERFACE beardFramework.interfaces.ISpatialized */
	
	@:isVar public var width(get, set):Float;
	
	function get_width():Float 
	{
		return width;
	}
	
	function set_width(value:Float):Float 
	{
		return width = value;
	}
	
	@:isVar public var height(get, set):Float;
	
	function get_height():Float 
	{
		return height;
	}
	
	function set_height(value:Float):Float 
	{
		return height = value;
	}
	
	@:isVar public var scaleX(get, set):Float;
	
	function get_scaleX():Float 
	{
		return scaleX;
	}
	
	function set_scaleX(value:Float):Float 
	{
		return scaleX = value;
	}
	
	@:isVar public var scaleY(get, set):Float;
	
	function get_scaleY():Float 
	{
		return scaleY;
	}
	
	function set_scaleY(value:Float):Float 
	{
		return scaleY = value;
	}
	
	@:isVar public var rotation(get, set):Float;
	
	function get_rotation():Float 
	{
		return rotation;
	}
	
	function set_rotation(value:Float):Float 
	{
		return rotation = value;
	}
	
	@:isVar public var x(get, set):Float;
	
	function get_x():Float 
	{
		return x;
	}
	
	function set_x(value:Float):Float 
	{
		return x = value;
	}
	
	@:isVar public var y(get, set):Float;
	
	function get_y():Float 
	{
		return y;
	}
	
	function set_y(value:Float):Float 
	{
		return y = value;
	}
	
	@:isVar public var z(get, set):Float;
	
	function get_z():Float 
	{
		return z;
	}
	
	function set_z(value:Float):Float 
	{
		return z = value;
	}
	
	@:isVar public var name(get, set):String;
	
	function get_name():String 
	{
		return name;
	}
	
	function set_name(value:String):String 
	{
		return name = value;
	}
	
	function get_alpha():Float 
	{
		return 0;
	}
	
	function set_alpha(value:Float):Float 
	{
		return 0;
	}
	
	function get_color():Color 
	{
		return Color.WHITE;
	}
	
	function set_color(value:Color):Color 
	{
		return  Color.WHITE;
	}
	
}