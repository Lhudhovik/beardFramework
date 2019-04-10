package beardFramework.resources.save.data;
import beardFramework.graphics.cameras.Camera;
import haxe.ds.Vector;

/**
 * @author Ludo
 */
typedef StructDataScreen =
{
  
	>StructDataGeneric,
	
	var cameras:Array<StructDataCamera>;
	var entitiesData:Array<StructDataEntity>;
	var visualsData:Array<StructDataVisual>;
	var soundsData:Array<StructDataVisual>;
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