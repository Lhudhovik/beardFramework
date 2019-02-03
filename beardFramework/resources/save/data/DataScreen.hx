package beardFramework.resources.save.data;
import beardFramework.graphics.cameras.Camera;

/**
 * @author Ludo
 */
typedef DataScreen =
{
  
	>DataGeneric,
	
	var cameras:Array<DataCamera>;
	var entitiesData:Array<DataEntity>;
	var UITemplates:Array<String>;
	var width:Int;
	var height:Int;
	
}

@:forward
abstract AbstractDataScreen(DataScreen) from DataScreen to DataScreen{
  inline public function new(data:DataScreen) {
    this = data;
  }
}