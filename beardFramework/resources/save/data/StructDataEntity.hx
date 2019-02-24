package beardFramework.resources.save.data;

/**
 * @author Ludo
 */
typedef StructDataEntity =
{
	>StructDataGeneric,
	
	var x:Float;
	var y:Float;
	var components:Array<StructDataComponent>;
	var additionalData:String;
}

@:forward
abstract DataEntity(StructDataEntity) from StructDataEntity to StructDataEntity {
  inline public function new(data:StructDataEntity) {
    this = data;
  }
}