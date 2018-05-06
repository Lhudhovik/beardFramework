package beardFramework.resources.save.data;

/**
 * @author Ludo
 */
typedef DataCamera =
{
	>DataGeneric,
	
	var zoom:Float;
	var viewportWidth:Float;
	var viewportHeight:Float;
	var centerX:Float;
	var centerY:Float;
	var viewportX:Float;
	var viewportY:Float;
	var buffer:Float;
}
@:forward
abstract AbstractDataCamera(DataCamera) from DataCamera to DataCamera{
  inline public function new(data:DataCamera) {
    this = data;
  }
}