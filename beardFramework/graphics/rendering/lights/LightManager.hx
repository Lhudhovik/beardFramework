package beardFramework.graphics.rendering.lights;
import lime.graphics.opengl.GL;

/**
 * ...
 * @author Ludovic
 */
class LightManager 
{
	public var MAX_LIGHT_COUNT_BY_TYPE(default, never):Int = 10;
	public var directionalLights:Map<String, Light>;
	private var pointLights:Map<String, PointLight>;
	private var spotLights:Map<String, SpotLight>;
	private var lightGroups:Map<String, List<String>>;
	private var directionalLightsCount:Int = 0;
	private var spotLightsCount:Int = 0;
	private var pointLightsCount:Int=0;
	
	private function new() 
	{
		
	}
	
	public static inline function Get():LightManager
	{
		if (instance == null)
		{
			instance = new LightManager();
			instance.Init();
		}
		
		return instance;
	}
	
	private function Init():Void
	{
		
		lightGroups = new Map();
		
	}
	
	public static function CreateLightGroup(name:String, lights:Array<String>):List<Light>
	{
		
		if (lightGroups[name] == null) lightGroups[name] = new List<Light>();
		
		for (i in 0...lights.length)
		{
			if (i > MAX_LIGHT_COUNT_BY_TYPE) break;
			lightGroups[name].add(lights[i]);
			
		}
		
		return lightGroups[name];		
	}
	
	
	public static function CreateDirectionalLight(name:String, group:String="default", position:SVec3 = null, ambient:Color = Color.WHITE, diffuse:Color = Color.WHITE, specular:Color=Color.WHITE):Light
	{
		if (directionalLights == null) directionalLights = new Map();
		if(lightGroups == null) lightGroups = new Map();
		if (position == null) position = {x:0, y:0, z: -50};
		
				
		var light:Light = GetDirectionalLight(name);
		
		if (light == null ){
			
			light = new Light(name, position, ambient, diffuse, specular);
			directionalLights[name] =light;
			directionalLightsCount++;
			
		
			
		}
		
	
		return light;
		
	}
	
	public static function CreateSpotLight(name:String, group:String="default", position:SVec3 = null, direction:SVec3=null, cutOff:Float=25, outerCutOff:Float=35):SpotLight
	{
		if (spotLights == null) spotLights = new Map();
		if (position == null) position = {x:0, y:0, z: -50};
		if (direction == null) direction = {x:0, y:1, z:0};
		
		var light:SpotLight = GetSpotLight(name);
		
		if (light == null ){
			
			light = new SpotLight(name, position, direction,  0x050505ff, Color.WHITE, Color.WHITE);
			light.cutOff = cutOff;
			light.outerCutOff = outerCutOff;
			spotLights[name] = light;
			spotLightsCount++;
			
		}
		
	
		return light;
		
	}
	
	public static function CreatePointLight(name:String, group:String="default",position:SVec3 = null, constant:Float = 1.0, linear:Float=0.0014, quadratic:Float=0.000007 ):PointLight
	{
		if (pointLights == null) pointLights = new Map();
		if (position == null) position = {x:0, y:0, z: -50};
		
		var light:PointLight = GetPointLight(name);		
		
		if (light == null ){
			light = new PointLight(name, position, Color.WHITE, Color.WHITE, Color.WHITE);
			light.constant = constant;
			light.linear = linear;
			light.quadratic = quadratic;
			pointLights[name] = light;
			pointLightsCount++;
		}
		
		
	
		return light;
	}
	 
	public static inline function GetDirectionalLight(name:String):Light
	{
		return (directionalLights != null ? directionalLights[name] : null);
	}
	
	public static inline function GetSpotLight(name:String):SpotLight
	{
		return (spotLights != null ? spotLights[name] : null);
		
	}
	
	public static inline function GetPointLight(name:String):PointLight
	{
		return (pointLights != null ? pointLights[name] : null);
	}
	
	public static function RemoveDirectionalLight(name:String):Light
	{
		if (directionalLights != null && directionalLights[name] != null)
		{
			directionalLights.remove(name);
			directionalLightsCount--;
		}
		
		return null;
		
	}
	
	public static function RemoveSpotLight(name:String):SpotLight
	{
		if (spotLights != null && spotLights[name] != null)
		{
			spotLights.remove(name);
			spotLightsCount--;
		}
		
		return null;
	}
	
	public static function RemovePointLight(name:String):PointLight
	{
		if (pointLights != null && pointLights[name] != null)
		{
			pointLights.remove(name);
			pointLightsCount--;
		}
		
		return null;
		
	}
	
	public static function SetUniforms(shaderProgram:GLProgram, lightGroup:String):Void
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