package beardFramework.utils;
import beardFramework.utils.simpleDataStruct.SRect;
import beardFramework.utils.simpleDataStruct.SVec2;
import lime.math.Matrix4;

/**
 * ...
 * @author 
 */
class GeomUtils 
{

	public static var utilMatrix(get, null):Matrix4;
	public static var utilSimpleRect(get, null):SRect;
	public static var utilSimplePoint(get, null):SVec2;
	
	
	static function get_utilSimpleRect():SRect 
	{
		if (utilSimpleRect == null) utilSimpleRect = {width:0, height:0, x :0 , y:0};
		return utilSimpleRect;
	}
	static function get_utilSimplePoint():SVec2 
	{
		if (utilSimplePoint == null) utilSimplePoint = { x :0 , y:0};
		return utilSimplePoint;
	}
	
	static function get_utilMatrix():Matrix4 
	{
		if (utilMatrix == null) utilMatrix = new Matrix4();
		return utilMatrix;
	}
	
	public static inline function Max(val1:Float, val2:Float):Float
	{
		
		return val1 > val2 ? val1 : val2;
		
	}
	
		
	public static inline function Min(val1:Float, val2:Float):Float
	{
		
		return val1 < val2 ? val1 : val2;
		
	}
	
	private static inline function GetMinValue ():Float {
		
		return 2.2250738585072014e-308;
	}
	
	
	private static inline function GetMaxValue ():Float {
		return 1.7976931348623158e+308;
	}
	
	
}
