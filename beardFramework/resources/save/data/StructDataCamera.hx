package beardFramework.resources.save.data;

/**
 * @author Ludo
 */
typedef StructDataCamera =
{
	>StructDataGeneric,
	
	var zoom:Float;
	var viewportWidth:Float;
	var viewportHeight:Float;
	var centerX:Float;
	var centerY:Float;
	var viewportX:Float;
	var viewportY:Float;
	var buffer:Float;
	var keepRatio:Bool;
	var ratioX:Float;
	var ratioY:Float;
	var ratioWidth:Float;
	var ratioHeight:Float;
}
@:forward
abstract DataCamera(StructDataCamera) from StructDataCamera to StructDataCamera{
  inline public function new(data:StructDataCamera) {
    this = data;
  }
}