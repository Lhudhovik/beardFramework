package beardFramework.graphics.rendering.lights;

import beardFramework.utils.graphics.Color;
import beardFramework.utils.simpleDataStruct.SVec3;

/**
 * ...
 * @author Ludovic
 */
class PointLight extends Light 
{
	public var constant(default, set) : Float = 1.0;
	public var linear(default, set) : Float= 0.0014;
	public var quadratic(default, set) : Float=0.000007;	
	
	public function new(name:String, position:SVec3, ambient:Color, diffuse:Color, specular:Color) 
	{
		super(name, position, ambient,diffuse, specular);
		type = LightType.POINT;
	}
	
	function set_constant(value:Float):Float 
	{
		if (constant != value) isDirty = true;
		return constant = value;
	}
	
	function set_linear(value:Float):Float 
	{
		if (linear != value) isDirty = true;
		return linear = value;
	}
	
	function set_quadratic(value:Float):Float 
	{
		if (quadratic != value) isDirty = true;
		return quadratic = value;
	}
	
}