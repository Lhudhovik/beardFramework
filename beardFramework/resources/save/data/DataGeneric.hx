package beardFramework.resources.save.data;

/**
 * @author Ludo
 */
typedef DataGeneric =
{
	>AbstractData,
	var type:String;	
	
	
}
@:forward
abstract AbstractDataGeneric(DataGeneric) from DataGeneric to DataGeneric {
  inline public function new(data:DataGeneric) {
    this = data;
  }
}