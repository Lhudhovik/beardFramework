package beardFramework.display.ui.components;

import beardFramework.display.ui.components.UISpriteComponent;
import beardFramework.events.input.InputManager;
import beardFramework.events.input.InputType;
import beardFramework.resources.assets.AssetManager;
import openfl.display.BitmapData;
import openfl.display.DisplayObject;
import openfl.display.PixelSnapping;
import openfl.display.Shape;
import openfl.display.Sprite;

/**
 * ...
 * @author Ludo
 */
class UISpriteButton extends UISpriteComponent 
{

	
	public function new() 
	{
		super();
		
		InputManager.get_instance().RegisterActionCallback(InputManager.MOUSE_OVER, OnOver, this.name);
		InputManager.get_instance().RegisterActionCallback(InputManager.MOUSE_OUT, OnOut, this.name);
		InputManager.get_instance().RegisterActionCallback(InputManager.MOUSE_MOVE, OnMove);
		InputManager.get_instance().RegisterActionCallback(InputManager.MOUSE_WHEEL, OnWheel, this.name);
		//this.mouseChildren = false;
	}
	
	
	//used for visual feedback such as scale modification...
	private function OnOver(value:Float):Void{
		
	}
	private function OnOut(value:Float):Void{
		
	}
	private function OnClick(value:Float):Void
	{
		
	}
	private function OnDown(value:Float):Void
	{
		
	}
	private function OnUp(value:Float):Void
	{
		
	}
	private function OnMove(value:Float):Void
	{
		
	}
	private function OnWheel(value:Float):Void
	{
		
	}
	override function set_name(value:String):String 
	{
		
		InputManager.get_instance().UnregisterActionCallback(InputManager.MOUSE_OVER, OnOver, this.name);
		InputManager.get_instance().UnregisterActionCallback(InputManager.MOUSE_OUT, OnOut, this.name);
		InputManager.get_instance().UnregisterActionCallback(InputManager.MOUSE_MOVE, OnMove);
		InputManager.get_instance().UnregisterActionCallback(InputManager.MOUSE_WHEEL, OnWheel, this.name);
		
		super.set_name(value);
		
		InputManager.get_instance().RegisterActionCallback(InputManager.MOUSE_OVER, OnOver, this.name);
		InputManager.get_instance().RegisterActionCallback(InputManager.MOUSE_OUT, OnOut, this.name);
		InputManager.get_instance().RegisterActionCallback(InputManager.MOUSE_MOVE, OnMove);
		InputManager.get_instance().RegisterActionCallback(InputManager.MOUSE_WHEEL, OnWheel, this.name);
		return this.name;
	}
	
}