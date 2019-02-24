package beardFramework.input.data;
import lime.ui.GamepadAxis;

/**
 * @author 
 */
typedef AxisInputData =
{
	>AbstractGamepadInputData,
	var axis:GamepadAxis;
	var value:Float;
}

