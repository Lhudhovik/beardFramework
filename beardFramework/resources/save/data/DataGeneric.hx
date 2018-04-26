package beardFramework.resources.save.data;

/**
 * @author Ludo
 */
typedef DataGeneric =
{
	var name:String;
	var type:String;	
	
	
}
@:forward
abstract AbstractDataGeneric(DataGeneric) from DataGeneric to DataGeneric {
  inline public function new(data:DataGeneric) {
    this = data;
  }
}