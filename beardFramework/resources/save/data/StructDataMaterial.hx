package beardFramework.resources.save.data;
import haxe.ds.Vector;

/**
 * @author Ludo
 */
typedef StructDataMaterial =
{
	>StructDataGeneric,
	var components:Array<StructDataMaterialComponent>;
	var shininess:Float;
	var transparency:Float;
		
	
	
}
@:forward
abstract DataMaterial(StructDataMaterial) from StructDataMaterial to StructDataMaterial {
  inline public function new(data:StructDataMaterial) {
    this = data;
  }
}