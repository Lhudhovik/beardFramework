package beardFramework.resources.save.data;

/**
 * @author Ludo
 */
typedef StructDataCamera =
{
	>StructDataGeneric,
	
	var zoom:Float;
	var widthRatio:Float;
	var heightRatio:Float;
	var centerX:Float;
	var centerY:Float;
	var buffer:Float;
	
}
@:forward
abstract DataCamera(StructDataCamera) from StructDataCamera to StructDataCamera{
  inline public function new(data:StructDataCamera) {
    this = data;
  }
}