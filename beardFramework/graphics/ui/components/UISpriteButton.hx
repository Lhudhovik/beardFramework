package beardFramework.graphics.ui.components;

import beardFramework.graphics.ui.components.UISpriteComponent;
import beardFramework.input.InputManager;
import beardFramework.input.InputType;
import beardFramework.interfaces.IButton;
import beardFramework.resources.assets.AssetManager;
import beardFramework.utils.libraries.StringLibrary;
import openfl.display.BitmapData;
import openfl.display.DisplayObject;
import openfl.display.PixelSnapping;
import openfl.display.Shape;
import openfl.display.Sprite;

/**
 * ...
 * @author Ludo
 */
class UISpriteButton extends UISpriteComponent implements IButton
{

	
	public function new() 
	{
		super();
		
		InputManager.Get().BindToAction(StringLibrary.MOUSE_OVER, OnOver, this.name);
		InputManager.Get().BindToAction(StringLibrary.MOUSE_OUT, OnOut, this.name);
		//InputManager.get_instance().RegisterActionCallback(StringLibrary.MOUSE_MOVE, OnMove);
		InputManager.Get().BindToAction(StringLibrary.MOUSE_WHEEL, OnWheel, this.name);
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
		
		InputManager.Get().UnbindFromAction(StringLibrary.MOUSE_OVER, OnOver, this.name);
		InputManager.Get().UnbindFromAction(StringLibrary.MOUSE_OUT, OnOut, this.name);
		//InputManager.get_instance().UnregisterActionCallback(StringLibrary.MOUSE_MOVE, OnMove);
		InputManager.Get().UnbindFromAction(StringLibrary.MOUSE_WHEEL, OnWheel, this.name);
		
		super.set_name("Sprite button" + value);
		
		InputManager.Get().BindToAction(StringLibrary.MOUSE_OVER, OnOver, this.name);
		InputManager.Get().BindToAction(StringLibrary.MOUSE_OUT, OnOut, this.name);
		//InputManager.get_instance().RegisterActionCallback(StringLibrary.MOUSE_MOVE, OnMove);
		InputManager.Get().BindToAction(StringLibrary.MOUSE_WHEEL, OnWheel, this.name);
		return this.name;
	}
	override public function Destroy():Void 
	{
		InputManager.Get().UnbindFromAction(StringLibrary.MOUSE_OVER, OnOver, this.name);
		InputManager.Get().UnbindFromAction(StringLibrary.MOUSE_OUT, OnOut, this.name);
		//InputManager.get_instance().UnregisterActionCallback(StringLibrary.MOUSE_MOVE, OnMove);
		InputManager.Get().UnbindFromAction(StringLibrary.MOUSE_WHEEL, OnWheel, this.name);
		
		
	}
}