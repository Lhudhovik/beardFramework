package beardFramework.graphics.rendering.lights;
import beardFramework.resources.MinAllocArray;
import beardFramework.utils.graphics.Color;
import beardFramework.utils.math.MathU;
import beardFramework.utils.simpleDataStruct.SVec3;
import lime.graphics.opengl.GL;
import lime.graphics.opengl.GLProgram;

/**
 * @author Ludovic
 */

 
 class Light
 {
	
	public var name(default, null):String;
	public var position:SVec3;
	public var ambient:Color;
	public var diffuse:Color;
	public var specular:Color;
	
	private function new(name:String, position:SVec3, ambient:Color, diffuse:Color, specular:Color)
	{
		this.specular = specular;
		this.diffuse = diffuse;
		this.ambient = ambient;
		this.position = position;
		this.name = name;		
	}
		
	
 }
 
 


