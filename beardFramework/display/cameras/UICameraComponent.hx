package beardFramework.display.cameras;
import beardFramework.interfaces.IUIComponent;

/**
 * ...
 * @author Ludo
 */
class UICameraComponent extends Camera implements IUIComponent
{

	public function new(id:String, width:Float=100, height:Float=57, buffer:Float=100) 
	{
		super(id, width, height, buffer);
		keepRatio = false;
	}
	
	
	/* INTERFACE beardFramework.interfaces.IUIComponent */
	
	@:isVar public var x(get, set):Float;
	
	function get_x():Float 
	{
		return viewportX;
	}
	
	function set_x(value:Float):Float 
	{
		return viewportX= value;
	}
	
	@:isVar public var y(get, set):Float;
	
	function get_y():Float 
	{
		return viewportY;
	}
	
	function set_y(value:Float):Float 
	{
		return viewportY = value;
	}
	
	public var width(get, set):Float;
	
	function get_width():Float 
	{
		return viewportWidth;
	}
	
	function set_width(value:Float):Float 
	{
		return viewportWidth = value;
	}
	
	public var height(get, set):Float;
	
	function get_height():Float 
	{
		return viewportHeight;
	}
	
	function set_height(value:Float):Float 
	{
		return viewportHeight = value;
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
	
	public var vAlign:UInt;
	
	public var hAlign:UInt;
	
	public var fillPart:Float;
	
	public var keepRatio:Bool;
	
	public function UpdateVisual():Void 
	{
		
	}
	
	
	/* INTERFACE beardFramework.interfaces.IUIComponent */
	
	
	
	public function Clear():Void 
	{
		
	}
	
	
	/* INTERFACE beardFramework.interfaces.IUIComponent */
	
	@:isVar public var preserved(get, set):Bool;
	
	function get_preserved():Bool 
	{
		return preserved;
	}
	
	function set_preserved(value:Bool):Bool 
	{
		return preserved = value;
	}
	
	@:isVar public var container(get, set):String;
	
	function get_container():String 
	{
		return container;
	}
	
	function set_container(value:String):String 
	{
		return container = value;
	}
	
	@:isVar public var visible(get, set):Bool;
	
	function get_visible():Bool 
	{
		return visible;
	}
	
	function set_visible(value:Bool):Bool 
	{
		return visible = value;
	}
	
	@:isVar public var group(get, set):String;
	
	function get_group():String 
	{
		return group;
	}
	
	function set_group(value:String):String 
	{
		return group = value;
	}
	
}