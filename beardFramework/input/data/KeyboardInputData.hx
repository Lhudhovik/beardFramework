package beardFramework.input.data;
import lime.ui.KeyCode;
import lime.ui.KeyModifier;

/**
 * @author 
 */
typedef KeyboardInputData =
{
	>InputData,	
	var keyCode:KeyCode;
	var modifier:KeyModifier;
	
}

//@:forward
//abstract KeyboardInputData(StructKeyboardInputData) from StructKeyboardInputData to StructKeyboardInputData {
  //inline public function new(data:StructKeyboardInputData) {
    //this = data;
  //}
//}