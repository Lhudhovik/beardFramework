package beardFramework.graphics.ui.components;

import beardFramework.input.InputManager;
import beardFramework.interfaces.IButton;
import beardFramework.utils.StringLibrary;
import openfl.display.BitmapData;
import openfl.display.PixelSnapping;

/**
 * ...
 * @author Ludo
 */
class UIBitmapButton extends UIBeardVisual implements IButton
{

	public function new(texture:String = "", atlas:String  = "", pixelSnapping:PixelSnapping=null, smoothing:Bool=false) 
	{
		super(texture,atlas);
				
		this.name = "Bitmap button " + name;
		
		InputManager.Get().BindToAction(StringLibrary.MOUSE_OVER, OnOver, this.name);
		InputManager.Get().BindToAction(StringLibrary.MOUSE_OUT, OnOut, this.name);
		//InputManager.get_instance().RegisterActionCallback(StringLibrary.MOUSE_MOVE, OnMove);
		InputManager.Get().BindToAction(StringLibrary.MOUSE_WHEEL, OnWheel, this.name);
		
		
		
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
	//override function set_name(value:String):String 
	//{
		//
		//InputManager.Get().UnbindFromAction(StringLibrary.MOUSE_OVER, OnOver, this.name);
		//InputManager.Get().UnbindFromAction(StringLibrary.MOUSE_OUT, OnOut, this.name);
		////InputManager.get_instance().UnregisterActionCallback(StringLibrary.MOUSE_MOVE, OnMove);
		//InputManager.Get().UnbindFromAction(StringLibrary.MOUSE_WHEEL, OnWheel, this.name);
		//
		//super.set_name("Bitmap button" + value);
		//
		//InputManager.Get().BindToAction(StringLibrary.MOUSE_OVER, OnOver, this.name);
		//InputManager.Get().BindToAction(StringLibrary.MOUSE_OUT, OnOut, this.name);
		////InputManager.get_instance().RegisterActionCallback(StringLibrary.MOUSE_MOVE, OnMove);
		//InputManager.Get().BindToAction(StringLibrary.MOUSE_WHEEL, OnWheel, this.name);
		//return this.name;
	//}
	//
	override public function Clear():Void 
	{
		InputManager.Get().UnbindFromAction(StringLibrary.MOUSE_OVER, OnOver, this.name);
		InputManager.Get().UnbindFromAction(StringLibrary.MOUSE_OUT, OnOut, this.name);
		//InputManager.get_instance().UnregisterActionCallback(StringLibrary.MOUSE_MOVE, OnMove);
		InputManager.Get().UnbindFromAction(StringLibrary.MOUSE_WHEEL, OnWheel, this.name);
	}
}