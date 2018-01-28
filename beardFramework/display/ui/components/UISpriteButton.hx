package beardFramework.display.ui.components;

import beardFramework.display.ui.components.UISpriteComponent;
import beardFramework.input.InputManager;
import beardFramework.input.InputType;
import beardFramework.interfaces.IButton;
import beardFramework.resources.assets.AssetManager;
import beardFramework.utils.StringLibrary;
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
		
		InputManager.Get().BindAction(StringLibrary.MOUSE_OVER, OnOver, this.name);
		InputManager.Get().BindAction(StringLibrary.MOUSE_OUT, OnOut, this.name);
		//InputManager.get_instance().RegisterActionCallback(StringLibrary.MOUSE_MOVE, OnMove);
		InputManager.Get().BindAction(StringLibrary.MOUSE_WHEEL, OnWheel, this.name);
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
		
		InputManager.Get().UnbindAction(StringLibrary.MOUSE_OVER, OnOver, this.name);
		InputManager.Get().UnbindAction(StringLibrary.MOUSE_OUT, OnOut, this.name);
		//InputManager.get_instance().UnregisterActionCallback(StringLibrary.MOUSE_MOVE, OnMove);
		InputManager.Get().UnbindAction(StringLibrary.MOUSE_WHEEL, OnWheel, this.name);
		
		super.set_name("Sprite button" + value);
		
		InputManager.Get().BindAction(StringLibrary.MOUSE_OVER, OnOver, this.name);
		InputManager.Get().BindAction(StringLibrary.MOUSE_OUT, OnOut, this.name);
		//InputManager.get_instance().RegisterActionCallback(StringLibrary.MOUSE_MOVE, OnMove);
		InputManager.Get().BindAction(StringLibrary.MOUSE_WHEEL, OnWheel, this.name);
		return this.name;
	}
	override public function Clear():Void 
	{
		InputManager.Get().UnbindAction(StringLibrary.MOUSE_OVER, OnOver, this.name);
		InputManager.Get().UnbindAction(StringLibrary.MOUSE_OUT, OnOut, this.name);
		//InputManager.get_instance().UnregisterActionCallback(StringLibrary.MOUSE_MOVE, OnMove);
		InputManager.Get().UnbindAction(StringLibrary.MOUSE_WHEEL, OnWheel, this.name);
		
		
	}
}