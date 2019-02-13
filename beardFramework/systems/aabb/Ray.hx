package beardFramework.systems.aabb;
import beardFramework.utils.simpleDataStruct.SVec2;
import lime.math.Vector2;

/**
 * @author 
 */
class Ray
{
	public var start:SVec2;
	public var dir:Vector2;
	public var length:Float;
	public var dir_inv:Vector2;
	public var callback:RayCastResult->Void;
	public var filterTags:UInt;
	public function new(origin:SVec2, direction:Vector2, length:Float = -1, filterTags:UInt = 0, callback:RayCastResult->Void = null)
	{
		start = origin;
		dir = direction;
		dir.normalize(1);
		this.length = length;
		this.callback = callback;
		this.filterTags = filterTags;
		dir_inv = new Vector2(dir.x * -1, dir.y *-1) ;
		
	}
}