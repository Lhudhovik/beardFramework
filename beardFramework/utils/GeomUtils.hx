package beardFramework.utils;
import lime.math.Matrix4;

/**
 * ...
 * @author 
 */
class GeomUtils 
{

	public static var utilMatrix(get, null):Matrix4;
	public static var utilSimpleRect(get, null):SimpleRect;
	public static var utilSimplePoint(get, null):SimplePoint;
	
	
	static function get_utilSimpleRect():SimpleRect 
	{
		if (utilSimpleRect == null) utilSimpleRect = {width:0, height:0, x :0 , y:0};
		return utilSimpleRect;
	}
	static function get_utilSimplePoint():SimplePoint 
	{
		if (utilSimplePoint == null) utilSimplePoint = { x :0 , y:0};
		return utilSimplePoint;
	}
	
	static function get_utilMatrix():Matrix4 
	{
		if (utilMatrix == null) utilMatrix = new Matrix4();
		return utilMatrix;
	}
	
	
	
	
}
typedef SimpleRect =
{
	public var width:Float;
	public var height:Float;
	public var x : Float;
	public var y:Float;

}

typedef SimplePoint =
{
	public var x : Float;
	public var y:Float;

}