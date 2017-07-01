package beardFramework.displaySystem;

import openfl.display.Sprite;

/**
 * ...
 * @author Ludo
 */
class BeardSprite extends Sprite
{
	private var widthChanged:Bool;
	private var heightChanged:Bool;
	private var cachedWidth:Float;
	private var cachedHeight:Float;
	public function new() 
	{
		super();
		
	}
	override function set_width(value:Float):Float 
	{
		widthChanged = true;
		return super.set_width(value);
	}
	
	override function get_width():Float 
	{
		if (widthChanged){
			cachedWidth = super.get_width();
			widthChanged = false;
		}
		return cachedWidth;
	}
	
	override function get_height():Float 
	{
		if (heightChanged){
			cachedHeight = super.get_height();
			heightChanged = false;
		}
		return cachedHeight;
	}
	override function set_height(value:Float):Float 
	{
		heightChanged = true;
		return super.set_height(value);
	}
	override function set_scaleX(value:Float):Float 
	{
		widthChanged = true;
		return super.set_scaleX(value);
	}
	
	override function set_scaleY(value:Float):Float 
	{
		heightChanged = true;
		return super.set_scaleY(value);
	}
	
	
}