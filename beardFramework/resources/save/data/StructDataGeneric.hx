package beardFramework.resources.save.data;

/**
 * @author Ludo
 */
typedef StructDataGeneric =
{
	>StructAbstractData,
	var type:String;	
	
	
}
@:forward
abstract DataGeneric(StructDataGeneric) from StructDataGeneric to StructDataGeneric {
  inline public function new(data:StructDataGeneric) {
    this = data;
  }
}