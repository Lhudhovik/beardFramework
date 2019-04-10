package beardFramework.resources.save.data;
import beardFramework.utils.graphics.Color;
import beardFramework.utils.simpleDataStruct.SRect;

/**
 * @author Ludo
 */
typedef StructDataMaterialComponent =
{
	>StructDataGeneric,
	var color:Color;
	var texture:String;
	var atlas:String;
	var uvs:SRect;
	
	
	
}
@:forward
abstract DataMaterialComponent(StructDataMaterialComponent) from StructDataMaterialComponent to StructDataMaterialComponent {
  inline public function new(data:StructDataMaterialComponent) {
    this = data;
  }
}