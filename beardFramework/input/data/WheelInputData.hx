package beardFramework.input.data;
import lime.ui.MouseWheelMode;

/**
 * @author 
 */
typedef WheelInputData =
{
	>InputData,	
	var value:Float;
	var axisDirection:Float;
	var wheelMode:MouseWheelMode;
}

//@:forward
//abstract WheelInputData(StructWheelInputData) from StructWheelInputData to StructWheelInputData {
  //inline public function new(data:StructWheelInputData) {
    //this = data;
  //}
//}