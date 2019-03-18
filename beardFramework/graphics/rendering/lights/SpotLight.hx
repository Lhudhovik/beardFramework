package beardFramework.graphics.rendering.lights;

import beardFramework.utils.graphics.Color;
import beardFramework.utils.simpleDataStruct.SVec3;

/**
 * ...
 * @author Ludovic
 */
class SpotLight extends Light 
{
	public var direction:SVec3;
	public var cutOff:Float=25;
	public var outerCutOff:Float=35;
	
	public function new(name:String, position:SVec3, direction:SVec3, ambient:Color, diffuse:Color, specular:Color) 
	{
		super(name, position, ambient, diffuse, specular);
		this.direction = direction;
	}
	
}