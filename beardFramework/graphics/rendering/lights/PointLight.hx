package beardFramework.graphics.rendering.lights;

import beardFramework.utils.graphics.Color;
import beardFramework.utils.simpleDataStruct.SVec3;

/**
 * ...
 * @author Ludovic
 */
class PointLight extends Light 
{
	public var constant : Float = 1.0;
	public var linear : Float= 0.0014;
	public var quadratic : Float=0.000007;	
	
	private function new(name:String, position:SVec3, ambient:Color, diffuse:Color, specular:Color) 
	{
		super(name, position, ambient, diffuse, specular);
		
	}
	
}