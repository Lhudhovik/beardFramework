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
	public static var MAX_LIGHT_COUNT_BY_TYPE(default, never):Int = 10;
	public static var directionalLights:MinAllocArray<Light>;
	private static var pointLights:MinAllocArray<PointLight>;
	private static var spotLights:MinAllocArray<SpotLight>;
	
	
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
	
	public static function CreateDirectionalLight(name:String, position:SVec3 = null, ambient:Color = Color.WHITE, diffuse:Color = Color.WHITE, specular:Color=Color.WHITE):Light
	{
		if (directionalLights == null) directionalLights = new MinAllocArray(MAX_LIGHT_COUNT_BY_TYPE);
		if (position == null) position = {x:0, y:0, z: -50};
				
		var light:Light = GetDirectionalLight(name);
		
		if (light == null){
			
			light = new Light(name, position, ambient, diffuse, specular);
			directionalLights.Push(light);
			
		}
		
	
		return light;
		
	}
	
	public static function CreateSpotLight(name:String, position:SVec3 = null, direction:SVec3=null, cutOff:Float=25, outerCutOff:Float=35):SpotLight
	{
		if (spotLights == null) spotLights = new MinAllocArray(MAX_LIGHT_COUNT_BY_TYPE);
		if (position == null) position = {x:0, y:0, z: -50};
		if (direction == null) direction = {x:0, y:1, z:0};
		
		var light:SpotLight = GetSpotLight(name);
		
		if (light == null){
			
			light = new SpotLight(name, position, direction,  Color.WHITE, Color.WHITE, Color.WHITE);
			light.cutOff = cutOff;
			light.outerCutOff = outerCutOff;
			spotLights.Push(light);
			
		}
		
	
		return light;
		
	}
	
	public static function CreatePointLight(name:String, position:SVec3 = null, constant:Float = 1.0, linear:Float=0.0014, quadratic:Float=0.000007 ):PointLight
	{
		if (pointLights == null) pointLights = new MinAllocArray(MAX_LIGHT_COUNT_BY_TYPE);
		if (position == null) position = {x:0, y:0, z: -50};
		
		var light:PointLight = GetPointLight(name);		
		
		if (light == null){
			light = new PointLight(name, position, Color.WHITE, Color.WHITE, Color.WHITE);
			light.constant = constant;
			light.linear = linear;
			light.quadratic = quadratic;
			pointLights.Push(light) ;
		}
		
		
	
		return light;
	}
	 
	public static function GetDirectionalLight(name:String):Light
	{
		if(directionalLights != null) 
			for (i in 0...directionalLights.length)
				if (directionalLights.get(i).name == name)
					return directionalLights.get(i);
		
		return null;
		
	}
	
	public static function GetSpotLight(name:String):SpotLight
	{
		if(spotLights != null) 
			for (i in 0...spotLights.length)
				if (spotLights.get(i).name == name)
					return spotLights.get(i);
		
		return null;
		
	}
	
	public static function GetPointLight(name:String):PointLight
	{
		if(pointLights != null) 
			for (i in 0...pointLights.length)
				if (pointLights.get(i).name == name)
					return pointLights.get(i);
		
		return null;
	}
	
	public static function RemoveDirectionalLight(name:String):Light
	{
		if(directionalLights != null) 
			for (i in 0...directionalLights.length)
				if (directionalLights.get(i).name == name)
				{
					directionalLights.RemoveByIndex(i);
					break;
				}
		
		return null;
		
	}
	
	public static function RemoveSpotLight(name:String):SpotLight
	{
		if(spotLights != null) 
			for (i in 0...spotLights.length)
				if (spotLights.get(i).name == name)
				{
					spotLights.RemoveByIndex(i);
					break;
				}
		
		return null;
		
	}
	
	public static function RemovePointLight(name:String):PointLight
	{
		if(pointLights != null) 
			for (i in 0...pointLights.length)
				if (pointLights.get(i).name == name)
				{
					pointLights.RemoveByIndex(i);
					break;
				}
		
		return null;
		
	}
	
	public static function SetUniforms(shaderProgram:GLProgram):Void
	{
		
		for (i in 0...MAX_LIGHT_COUNT_BY_TYPE)
		{
			
			if ( directionalLights != null && i < directionalLights.length){
				GL.uniform3f(GL.getUniformLocation(shaderProgram , "directionalLights["+i+"].ambient"),directionalLights.get(i).ambient.getRedf(), directionalLights.get(i).ambient.getGreenf(), directionalLights.get(i).ambient.getBluef() );
				GL.uniform3f(GL.getUniformLocation(shaderProgram , "directionalLights["+i+"].diffuse"), directionalLights.get(i).diffuse.getRedf(), directionalLights.get(i).diffuse.getGreenf(), directionalLights.get(i).diffuse.getBluef() );
				GL.uniform3f(GL.getUniformLocation(shaderProgram , "directionalLights["+i+"].specular"), directionalLights.get(i).specular.getRedf(), directionalLights.get(i).specular.getGreenf(), directionalLights.get(i).specular.getBluef() );
				GL.uniform3f(GL.getUniformLocation(shaderProgram , "directionalLights["+i+"].direction"), directionalLights.get(i).position.x, directionalLights.get(i).position.y, directionalLights.get(i).position.z );
				GL.uniform1i(GL.getUniformLocation(shaderProgram , "directionalLights["+i+"].used"), 1);
			}
			else 
				GL.uniform1i(GL.getUniformLocation(shaderProgram , "directionalLights["+i+"].used"), 0);
			
			
			if ( pointLights != null &&  i < pointLights.length){
				GL.uniform3f(GL.getUniformLocation(shaderProgram , "pointLights["+i+"].ambient"), pointLights.get(i).ambient.getRedf(), pointLights.get(i).ambient.getGreenf(), pointLights.get(i).ambient.getBluef());
				GL.uniform3f(GL.getUniformLocation(shaderProgram , "pointLights["+i+"].diffuse"), pointLights.get(i).diffuse.getRedf(), pointLights.get(i).diffuse.getGreenf(), pointLights.get(i).diffuse.getBluef() );
				GL.uniform3f(GL.getUniformLocation(shaderProgram , "pointLights["+i+"].specular"), pointLights.get(i).specular.getRedf(), pointLights.get(i).specular.getGreenf(), pointLights.get(i).specular.getBluef() );
				GL.uniform3f(GL.getUniformLocation(shaderProgram , "pointLights["+i+"].position"), pointLights.get(i).position.x, pointLights.get(i).position.y, pointLights.get(i).position.z );
				GL.uniform1f(GL.getUniformLocation(shaderProgram , "pointLights["+i+"].constant"), pointLights.get(i).constant);
				GL.uniform1f(GL.getUniformLocation(shaderProgram , "pointLights["+i+"].linear"), pointLights.get(i).linear );
				GL.uniform1f(GL.getUniformLocation(shaderProgram , "pointLights["+i+"].quadratic"), pointLights.get(i).quadratic);
				GL.uniform1i(GL.getUniformLocation(shaderProgram , "pointLights["+i+"].used"), 1);
			}
			else 
				GL.uniform1i(GL.getUniformLocation(shaderProgram , "pointLights["+i+"].used"), 0);
			
			
			
			if (spotLights != null && i < spotLights.length)
			{
				GL.uniform3f(GL.getUniformLocation(shaderProgram , "spotLights["+i+"].ambient"), spotLights.get(i).ambient.getRedf(), spotLights.get(i).ambient.getGreenf(), spotLights.get(i).ambient.getBluef() );
				GL.uniform3f(GL.getUniformLocation(shaderProgram , "spotLights["+i+"].diffuse"), spotLights.get(i).diffuse.getRedf(), spotLights.get(i).diffuse.getGreenf(), spotLights.get(i).diffuse.getBluef() );
				GL.uniform3f(GL.getUniformLocation(shaderProgram , "spotLights["+i+"].specular"), spotLights.get(i).specular.getRedf(), spotLights.get(i).specular.getGreenf(), spotLights.get(i).specular.getBluef() );
				GL.uniform3f(GL.getUniformLocation(shaderProgram , "spotLights["+i+"].position"), spotLights.get(i).position.x, spotLights.get(i).position.y, spotLights.get(i).position.z );
				GL.uniform3f(GL.getUniformLocation(shaderProgram , "spotLights["+i+"].direction"), spotLights.get(i).direction.x, spotLights.get(i).direction.y, spotLights.get(i).direction.z );
				GL.uniform1f(GL.getUniformLocation(shaderProgram , "spotLights["+i+"].cutOff"), Math.cos(MathU.ToRadians(spotLights.get(i).cutOff)));
				GL.uniform1f(GL.getUniformLocation(shaderProgram , "spotLights["+i+"].outerCutOff"), Math.cos(MathU.ToRadians(spotLights.get(i).outerCutOff)));
				GL.uniform1i(GL.getUniformLocation(shaderProgram , "spotLights["+i+"].used"), 1);
			}
			else
				GL.uniform1i(GL.getUniformLocation(shaderProgram , "spotLights["+i+"].used"), 0);
			
			
			
		}
		
		
		
		
	}
	
 }
 
 


