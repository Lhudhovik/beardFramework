package beardFramework.resources.save.data;

/**
 * @author Ludo
 */
typedef DataEntity =
{
	>DataGeneric,
	
	var x:Float;
	var y:Float;
	var components:Array<DataComponent>;
	var additionalData:String;
}

@:forward
abstract AbstractDataEntity(DataEntity) from DataEntity to DataEntity {
  inline public function new(data:DataEntity) {
    this = data;
  }
}