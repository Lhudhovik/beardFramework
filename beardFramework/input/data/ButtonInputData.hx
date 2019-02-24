package beardFramework.input.data;
import lime.ui.GamepadButton;

/**
 * @author 
 */
typedef ButtonInputData =
{
	>AbstractGamepadInputData,
	var button:GamepadButton;
	
}

//@:forward
//abstract ButtonInputData(StructButtonInputData) from StructButtonInputData to StructButtonInputData {
  //inline public function new(data:StructButtonInputData) {
    //this = data;
  //}
//}