package beardFramework.input.data;

/**
 * @author 
 */
typedef MouseInputData =
{
	>InputData,	
	var buttonID:Int;

}

//@:forward
//abstract MouseInputData(StructMouseInputData) from StructMouseInputData to StructMouseInputData {
  //inline public function new(data:StructMouseInputData) {
    //this = data;
  //}
//}