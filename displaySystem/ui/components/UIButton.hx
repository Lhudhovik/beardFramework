package beardFramework.displaySystem.ui.components;

import beardFramework.displaySystem.ui.components.UIBitmapComponent;
import beardFramework.events.input.InputManager;
import beardFramework.events.input.InputType;
import openfl.display.BitmapData;
import openfl.display.PixelSnapping;

/**
 * ...
 * @author Ludo
 */
class UIButton extends UIBitmapComponent 
{

	
	public function new(bitmapData:BitmapData=null, pixelSnapping:PixelSnapping=null, smoothing:Bool=false) 
	{
		super(bitmapData, pixelSnapping, smoothing);
		//InputManager.get_instance().LinkActionToInput("onOver", "Mouse", InputType.MOUSE_OVER);
		//InputManager.get_instance().LinkActionToInput("onOver", "Mouse", InputType.MOUSE_OVER);
		//InputManager.get_instance().LinkActionToInput("onOver", "Mouse", InputType.MOUSE_OVER);
		//InputManager.get_instance().LinkActionToInput("onOver", "Mouse", InputType.MOUSE_OVER);
		//InputManager.get_instance().LinkActionToInput("onOver", "Mouse", InputType.MOUSE_OVER);
		//InputManager.get_instance().LinkActionToInput("onOver", "Mouse", InputType.MOUSE_OVER);
		//InputManager.get_instance().LinkActionToInput("onOver", "Mouse", InputType.MOUSE_OVER);
		//InputManager.get_instance().RegisterActionCallback("onOver", OnOver, this.name);
	}
	
	public function OnOver():Void{
		
	}
	public function OnOut():Void{
		
	}
	public function OnClick():Void
	{
		
	}
	public function OnPress():Void
	{
		
	}
	public function OnRelease():Void
	{
		
	}
}