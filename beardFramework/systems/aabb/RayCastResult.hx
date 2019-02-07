package beardFramework.systems.aabb;
import beardFramework.utils.simpleDataStruct.SVec2;

/**
 * @author 
 */
typedef RayCastResult =
{
	public var hit:Bool;
	public var collider:AABB;
	public var hitPos:SVec2;
	public var fraction:Float;
	public var normal:SVec2;
}