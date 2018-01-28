package beardFramework.input;
import lime.ui.Gamepad;
import lime.ui.GamepadAxis;
import lime.ui.GamepadButton;

/**
 * ...
 * @author Ludo
 */
class GamepadHandler 
{
	
	public static function AxisMove(gamepad:Gamepad, axis:GamepadAxis, value:Float):Void
	{
		
		InputManager.Get().OnGamepadAxisMove(gamepad.id, axis, value);
		
	}
	
	public static function ButtonDown(gamepad:Gamepad, button:GamepadButton):Void
	{
		
		InputManager.Get().OnGamepadButtonDown(gamepad.id,button);
		
	}
	
	public static function ButtonUp(gamepad:Gamepad,  button:GamepadButton):Void
	{
		
		InputManager.Get().OnGamepadButtonUp(gamepad.id, button);
		
	}
	
	public static function Disconnect(gamepad:Gamepad):Void
	{
		
		InputManager.Get().OnGamepadDisconnect(gamepad);
		
	}
}