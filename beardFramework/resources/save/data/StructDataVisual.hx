package beardFramework.resources.save.data;

/**
 * @author Ludo
 */
typedef StructDataVisual =
{
	>StructDataGeneric,
	var x:Float;
	var y:Float;
	var z:Float;
	var shader:String;
	var material:StructDataMaterial;
	var drawMode:Int;
	var lightGroup:String;
	var cameras:List<String>;
	
	
}
@:forward
abstract DataVisual(StructDataVisual) from StructDataVisual to StructDataVisual {
  inline public function new(data:StructDataVisual) {
    this = data;
  }
}