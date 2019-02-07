package beardFramework.systems.aabb;
import lime.math.Vector2;

/**
 * @author 
 */
class Ray
{
	public var start:Vector2;
	public var dir:Vector2;
	public var length:Float;
	public var dir_inv:Vector2;
	public var callback:RayCastResult->Void;
	public function new(origin:Vector2, direction:Vector2, length:Float = 1, callback:RayCastResult->Void = null)
	{
		start = origin;
		dir = direction;
		dir.normalize(1);
		this.length = length;
		this.callback = callback;
		dir_inv = new Vector2(dir.x * -1, dir.y *-1) ;
		
	}
}