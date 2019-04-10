package beardFramework.resources.save.data;
import haxe.ds.Vector;

/**
 * @author Ludo
 */
typedef StructDataSave =
{
	>StructAbstractData,
	var playersData:Array<StructDataPlayer>;
	var gameData:Array<StructDataGeneric>;
	
	
}
@:forward
abstract DataSave(StructDataSave) from StructDataSave to StructDataSave {
  inline public function new(data:StructDataSave) {
    this = data;
  }
}