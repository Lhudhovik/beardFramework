package beardFramework.resources.save.data;
import haxe.ds.Vector;

/**
 * @author Ludo
 */
typedef StructDataEntity =
{
	>StructDataGeneric,
	
	var x:Float;
	var y:Float;
	var z:Float;
	var components:Array<StructDataComponent>;
	
	
}

@:forward
abstract DataEntity(StructDataEntity) from StructDataEntity to StructDataEntity {
  inline public function new(data:StructDataEntity) {
    this = data;
  }
}