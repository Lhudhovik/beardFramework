package beardFramework.input.data;
import lime.ui.Gamepad;

/**
 * @author 
 */
typedef GamepadInputData =
{
	>InputData,
	var gamepad:Gamepad;
}

//@:forward
//abstract GamepadInputData(StructGamepadInputData) from StructGamepadInputData to StructGamepadInputData {
  //inline public function new(data:StructGamepadInputData) {
    //this = data;
  //}
//}