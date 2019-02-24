package beardFramework.resources.save.data;
import beardFramework.graphics.cameras.Camera;

/**
 * @author Ludo
 */
typedef StructDataScreen =
{
  
	>StructDataGeneric,
	
	var cameras:Array<StructDataCamera>;
	var entitiesData:Array<StructDataEntity>;
	var UITemplates:Array<String>;
	var width:Int;
	var height:Int;
	
}

@:forward
abstract DataScreen(StructDataScreen) from StructDataScreen to StructDataScreen{
  inline public function new(data:StructDataScreen) {
    this = data;
  }
}