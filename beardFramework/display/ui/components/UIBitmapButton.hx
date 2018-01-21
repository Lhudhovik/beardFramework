package beardFramework.display.ui.components;

import beardFramework.display.ui.components.UIBitmapComponent;
import beardFramework.input.InputManager;
import beardFramework.interfaces.IButton;
import beardFramework.utils.StringLibrary;
import openfl.display.BitmapData;
import openfl.display.PixelSnapping;

/**
 * ...
 * @author Ludo
 */
class UIBitmapButton extends UIBitmapComponent implements IButton
{

	public function new(bitmapData:BitmapData=null, pixelSnapping:PixelSnapping=null, smoothing:Bool=false) 
	{
		super(bitmapData, pixelSnapping, smoothing);
				
		this.name = "Bitmap button " + name;
		mouseEnabled = true;
		
		InputManager.get_instance().BindAction(StringLibrary.MOUSE_OVER, OnOver, this.name);
		InputManager.get_instance().BindAction(StringLibrary.MOUSE_OUT, OnOut, this.name);
		//InputManager.get_instance().RegisterActionCallback(StringLibrary.MOUSE_MOVE, OnMove);
		InputManager.get_instance().BindAction(StringLibrary.MOUSE_WHEEL, OnWheel, this.name);
		
		
		
	}
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
		
		InputManager.get_instance().UnbindAction(StringLibrary.MOUSE_OVER, OnOver, this.name);
		InputManager.get_instance().UnbindAction(StringLibrary.MOUSE_OUT, OnOut, this.name);
		//InputManager.get_instance().UnregisterActionCallback(StringLibrary.MOUSE_MOVE, OnMove);
		InputManager.get_instance().UnbindAction(StringLibrary.MOUSE_WHEEL, OnWheel, this.name);
		
		super.set_name("Bitmap button" + value);
		
		InputManager.get_instance().BindAction(StringLibrary.MOUSE_OVER, OnOver, this.name);
		InputManager.get_instance().BindAction(StringLibrary.MOUSE_OUT, OnOut, this.name);
		//InputManager.get_instance().RegisterActionCallback(StringLibrary.MOUSE_MOVE, OnMove);
		InputManager.get_instance().BindAction(StringLibrary.MOUSE_WHEEL, OnWheel, this.name);
		return this.name;
	}
	
	override public function Clear():Void 
	{
		InputManager.get_instance().UnbindAction(StringLibrary.MOUSE_OVER, OnOver, this.name);
		InputManager.get_instance().UnbindAction(StringLibrary.MOUSE_OUT, OnOut, this.name);
		//InputManager.get_instance().UnregisterActionCallback(StringLibrary.MOUSE_MOVE, OnMove);
		InputManager.get_instance().UnbindAction(StringLibrary.MOUSE_WHEEL, OnWheel, this.name);
	}
}