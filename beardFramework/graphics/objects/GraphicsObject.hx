package beardFramework.graphics.objects;

import beardFramework.graphics.screens.BeardLayer;
import beardFramework.interfaces.ISpatialized;

/**
 * ...
 * @author Ludovic
 */
class GraphicsObject implements ISpatialized 
{

	
	@:isVar public var scaleX(get, set):Float;
	@:isVar public var scaleY(get, set):Float;
	@:isVar public var rotation(get, set):Float;
	@:isVar public var x(get, set):Float;
	@:isVar public var y(get, set):Float;
	@:isVar public var z(get, set):Float;
	@:isVar public var name(get, set):String;
	@:isVar public var group(get, set):String;
	@:isVar public var isDirty(get, set):Bool = false;
	
	public var isActivated(default, null):Bool;
	public var width(get, set):Float;
	public var height(get, set):Float;
	public var onAABBTree(default, set):Bool;
	public var layer:BeardLayer;
	
	private var cachedWidth:Float;
	private var cachedHeight:Float;
	
	public function new() 
	{
		scaleX = scaleY = 1;
		onAABBTree = false;
	}
	
	public function get_x():Float 
	{
		return x;
	}
	
	public function set_x(value:Float):Float 
	{
		if (value != x){
			isDirty = true;
			if (onAABBTree){
				layer.aabbs[this.name].topLeft.x = value;
				layer.aabbs[this.name].bottomRight.x = value+width;
				layer.aabbs[this.name].needUpdate = true;
			}
		}
		return x = value;
	}
	
	public function get_y():Float 
	{
		return y;
	}
	
	public function set_y(value:Float):Float 
	{
		if (value != y){
			isDirty = true;
			if (onAABBTree){
				layer.aabbs[this.name].topLeft.y = value;
				layer.aabbs[this.name].bottomRight.y = value+height;
				layer.aabbs[this.name].needUpdate = true;
			}
		}
		return y = value;
	}
	
	public function get_width():Float 
	{
		return cachedWidth;
	}
	
	public function set_width(value:Float):Float 
	{
		trace("width set to : " + value);
		if (value != cachedWidth)
		{
			scaleX = (value *scaleX) / cachedWidth;
			isDirty = true;
		}
		
		return value;
	}
	
	public function get_height():Float 
	{
		return cachedHeight;
	}
	
	public function set_height(value:Float):Float 
	{
		if (value != cachedHeight)			
		{ 
			scaleY = (value*scaleY) / cachedHeight;
			isDirty = true;
		}
		
		return value;
	}
	
	public function get_scaleX ():Float 
	{
		
		return scaleX;
		
	}
	
	public function set_scaleX (value:Float):Float 
	{
		trace("scale X set to " + value);
		if (value != scaleX)
		{
			
			cachedWidth = (cachedWidth/scaleX) * value;	
			scaleX = value;
			isDirty = true;
			
			if (onAABBTree)	{
				layer.aabbs[this.name].bottomRight.x = this.x + this.width;
				layer.aabbs[this.name].needUpdate = true;
			}
			
			
		}
		
		return value;
		
	}
	
	public function get_scaleY ():Float 
	{
		
		return scaleY;
		
	}
	
	public function set_scaleY (value:Float):Float 
	{
		if (value != scaleY)
		{
			
			cachedHeight = (cachedHeight/scaleY) * value;	
			scaleY = value;
			isDirty = true;
			if (onAABBTree){
				layer.aabbs[this.name].bottomRight.y = this.y + this.height;
				layer.aabbs[this.name].needUpdate = true;
			}
		}
		return value;
		
	}
	
	public function SetBaseWidth(value:Float):Void
	{
		trace("base width set to " + value);
		trace("base scale x is " + scaleX);
		var currentScale:Float = scaleX;
		scaleX = 1;
		cachedWidth = value;
		scaleX = currentScale;
		isDirty = true;
		
	}
	
	public function SetBaseHeight(value:Float):Void
	{
		//trace("base height set to " + value);
		var currentScale:Float = scaleY;
		scaleY = 1;
		cachedHeight = value;
		scaleY = currentScale;
		isDirty = true;
		
	}
	
	public function get_rotation ():Float 
	{
		
		return rotation;
		
	}
	
	public function set_rotation (value:Float):Float 
	{
		
		if (value != rotation) {
			
			rotation = value;
			var radians = value * (Math.PI / 180);
			rotationSine = Math.sin (radians);
			rotationCosine = Math.cos (radians);
			isDirty = true;
		}
		
		
		return value;
		
	}
			
	function get_z():Float 
	{
		return z;
	}
	
	function set_z(value:Float):Float 
	{
		return z = value;
	}
	
	function get_name():String 
	{
		return name;
	}
	
	function set_name(value:String):String 
	{
		return name = value;
	}
		
	function get_isDirty():Bool 
	{
		return isDirty;
	}
	
	function  set_isDirty(value:Bool):Bool 
	{
		return isDirty = value;
	}
	
	function get_group():String 
	{
		return group;
	}
	
	function set_group(value:String):String 
	{
		return group = value;
	}
	
	public function Activate():Void 
	{
		
	}
	
	public function DeActivate():Void 
	{
		isActivated = false;
	}
	
	public function Destroy():Void 
	{
		isActivated = true;
	}
	
}