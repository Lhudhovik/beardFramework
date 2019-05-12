package beardFramework.graphics.rendering.lights;
import beardFramework.core.BeardGame;
import beardFramework.graphics.rendering.Framebuffer;
import beardFramework.resources.MinAllocArray;
import beardFramework.utils.graphics.Color;
import beardFramework.utils.libraries.StringLibrary;
import beardFramework.utils.math.MathU;
import beardFramework.utils.simpleDataStruct.SVec3;
import lime.graphics.opengl.GL;
import lime.graphics.opengl.GLProgram;
import lime.math.Matrix4;
import lime.math.Vector4;

/**
 * @author Ludovic
 */

 
 class Light
 {
	
	public static var position:Vector4 = new Vector4();
	 
	public var name(default, null):String;
	public var x(default, set):Float;
	public var y(default, set):Float;
	public var z(default, set):Float;
	public var ambient(default, set):Color;
	public var diffuse(default, set):Color;
	public var specular(default, set):Color;
	public var isDirty:Bool;
	public var type:LightType;
	public var spaceMatrix:Matrix4;
	
	public function new(name:String, position:SVec3, ambient:Color, diffuse:Color, specular:Color)
	{
		this.specular = specular;
		this.diffuse = diffuse;
		this.ambient = ambient;
		this.x = position.x;
		this.y = position.y;
		this.z = position.z;
		this.name = name;		
		type = LightType.DIRECTIONAL;
		isDirty = true;
		spaceMatrix = new Matrix4();
		
	}
	
	public inline function SetPosition(x:Float, y:Float, z:Float):Void
	{
		this.x = x;
		this.y = y;
		this.z = z;
	}
	
	public inline function GetPosition():Vector4
	{
		position.setTo(x, y, z);
		return position;
	}
		
	function set_x(value:Float):Float 
	{
		if(x!= value) isDirty = true;
		return x = value;
	}
	
	function set_y(value:Float):Float 
	{
		if(y!= value) isDirty = true;
		return y = value;
	}
	
	function set_z(value:Float):Float 
	{
		if(z != value) isDirty = true;
		return z = value;
	}
	
	function set_ambient(value:Color):Color 
	{
		if(ambient != value) isDirty = true;
		return ambient = value;
	}
	
	function set_diffuse(value:Color):Color 
	{
		if(diffuse != value) isDirty = true;
		return diffuse = value;
	}
	
	function set_specular(value:Color):Color 
	{
		if(specular != value) isDirty = true;
		return specular = value;
	}
		
	
 }
 
 
 


