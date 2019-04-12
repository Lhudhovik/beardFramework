package beardFramework.graphics.rendering.lights;

import beardFramework.utils.graphics.Color;
import beardFramework.utils.simpleDataStruct.SVec3;

/**
 * ...
 * @author Ludovic
 */
class SpotLight extends PointLight 
{
	public var directionX(default, set):Float;
	public var directionY(default, set):Float;
	public var directionZ(default, set):Float;
	public var cutOff(default, set):Float=25;
	public var outerCutOff(default, set):Float=35;
	
	public function new(name:String, position:SVec3, direction:SVec3, ambient:Color, diffuse:Color, specular:Color) 
	{
		super(name, position, ambient, diffuse, specular);
		directionX = direction.x;
		directionY = direction.y;
		directionZ = direction.z;
		type = LightType.SPOT;
	}
	
	public inline function SetDirection(x:Float, y:Float, z:Float):Void
	{
		directionX = x;
		directionY = y;
		directionZ = z;
	}
	
	function set_directionX(value:Float):Float 
	{
		if (directionX != value) isDirty = true;
		return directionX = value;
	}
	
	function set_directionY(value:Float):Float 
	{
		if (directionY != value) isDirty = true;
		return directionY = value;
	}
	
	function set_directionZ(value:Float):Float 
	{
		if (directionZ != value) isDirty = true;
		return directionZ = value;
	}
	
	function set_cutOff(value:Float):Float 
	{
		if (cutOff != value) isDirty = true;
		return cutOff = value;
	}
	
	function set_outerCutOff(value:Float):Float 
	{
		if (outerCutOff != value) isDirty = true;
		return outerCutOff = value;
	}
	
}