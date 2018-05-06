package beardFramework.resources.save.data;

/**
 * @author Ludo
 */
typedef DataSave =
{
	>AbstractData,
	var playersData:Array<DataPlayer>;
	var gameData:Array<DataGeneric>;
	
	
}
@:forward
abstract AbstractDataSave(DataSave) from DataSave to DataSave {
  inline public function new(data:DataSave) {
    this = data;
  }
}