package beardFramework.graphics.rendering.lights;
import beardFramework.utils.graphics.Color;
import beardFramework.utils.math.MathU;
import beardFramework.utils.simpleDataStruct.SVec3;
import lime.graphics.opengl.GL;
import lime.graphics.opengl.GLProgram;

/**
 * ...
 * @author Ludovic
 */
class LightManager 
{
	
	private static var instance(default, null):LightManager;
	
	public var MAX_LIGHT_COUNT_BY_TYPE(default, never):Int = 10;
	private var lights:Map<String, Light>;
	private var lightGroups:Map<String,LightGroup>;
	private var dirtyLights:List<String>;
	private var dirtyGroups:List<String>;
	
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
		lightGroups["default"] = {
			lights:new List<String>(),
			directionalLightsCount:0,
			spotLightsCount:0,
			pointLightsCount:0,
			orderChanged:true
		}
		dirtyGroups = new List();
		dirtyLights = new List();
		
		dirtyGroups.add("default");
		lights = new Map();
	}
	
	public function AddToGroup(light:Light, group:String="default"):Void
	{
		if (lightGroups[group] == null) CreateLightGroup(group, [light.name]);
		else
		{
			var canBeAdded:Bool = false;
			switch(light.type)
			{
				case LightType.DIRECTIONAL : canBeAdded = (lightGroups[group].directionalLightsCount < MAX_LIGHT_COUNT_BY_TYPE);
				case LightType.POINT :canBeAdded = (lightGroups[group].pointLightsCount < MAX_LIGHT_COUNT_BY_TYPE) ;
				case LightType.SPOT : canBeAdded = (lightGroups[group].spotLightsCount < MAX_LIGHT_COUNT_BY_TYPE);
				
			}
			if (canBeAdded){
				
				lightGroups[group].lights.add(light.name);
				light.isDirty = true;
			}
			
			
		}
		
		
		
	}
	
	public function RemoveFromGroup(light:Light, group:String="default"):Void
	{
		
		if (lightGroups[group] != null && lightGroups[group].lights.remove(light.name))
		{
			switch(light.type)
			{
				case LightType.DIRECTIONAL : lightGroups[group].directionalLightsCount--;
				case LightType.POINT :lightGroups[group].pointLightsCount-- ;
				case LightType.SPOT : lightGroups[group].spotLightsCount--;
				
			}
			
			lightGroups[group].orderChanged = true;
			dirtyGroups.add(group);
		}
		
	}
	
	public inline function AddToGroupByName(light:String, group:String="default"):Void
	{
		if (lights[light] != null) AddToGroup(lights[light], group);
		
	}
	
	public inline function RemoveFromGroupByName(light:String, group:String="default"):Void
	{
		if (lights[light] != null) RemoveFromGroup(lights[light], group);
		
	}
	
	public  function CreateLightGroup(name:String, addedLights:Array<String> = null):String
	{
		if (name != null){
			if (lightGroups[name] == null) lightGroups[name] = {lights:new List<String>(),	directionalLightsCount:0,spotLightsCount:0,	pointLightsCount:0, orderChanged:true}
		
			if (addedLights != null)
				for (i in 0...addedLights.length)
					AddToGroupByName(addedLights[i], name);			
				
			
		}
		
		
		
		return name;		
	}
	
	public function CreateDirectionalLight(name:String, group:String="default", position:SVec3 = null, ambient:Color = Color.WHITE, diffuse:Color = Color.WHITE, specular:Color=Color.WHITE):Light
	{
		
		if (position == null) position = {x:0, y:0, z: -50};
	
		var light:Light = GetLight(name);
		
		if (light == null ){
			
			light = new Light(name, position, ambient, diffuse, specular);
			lights[name] =light;
		}
		
		AddToGroup(light, group);
		
	
		return light;
		
	}
	
	public function CreateSpotLight(name:String, group:String="default", position:SVec3 = null, direction:SVec3=null, cutOff:Float=25, outerCutOff:Float=35):SpotLight
	{
		
		if (position == null) position = {x:0, y:0, z: -50};
		if (direction == null) direction = {x:0, y:1, z:0};
		
		var light:SpotLight =  cast GetLight(name);
		
		if (light == null ){
			
			light = new SpotLight(name, position, direction,  0x050505ff, Color.WHITE, Color.WHITE);
			light.cutOff = cutOff;
			light.outerCutOff = outerCutOff;
			lights[name] = light;
		
		}
		
		AddToGroup(light, group);
	
		return light;
		
	}
	
	public function CreatePointLight(name:String, group:String="default",position:SVec3 = null, constant:Float = 1.0, linear:Float=0.0014, quadratic:Float=0.000007 ):PointLight
	{
		
		if (position == null) position = {x:0, y:0, z: -50};
		
		var light:PointLight = cast GetLight(name);		
		
		if (light == null ){
			light = new PointLight(name, position, Color.WHITE, Color.WHITE, Color.WHITE);
			light.constant = constant;
			light.linear = linear;
			light.quadratic = quadratic;
			lights[name] = light;
		}
		
		AddToGroup(light, group);
	
		return light;
	}
	 
	public inline function GetLight(name:String):Light
	{
		return lights[name];
	}
	
	public function RemoveLight(name:String):Light
	{
		if (lights[name] != null)
		{
			for (group in lightGroups.keys())
			{
				
				if ( lightGroups[group].lights.remove(name))
				{
					switch(lights[name].type)
					{
						case LightType.DIRECTIONAL : lightGroups[group].directionalLightsCount--;
						case LightType.POINT :lightGroups[group].pointLightsCount-- ;
						case LightType.SPOT : lightGroups[group].spotLightsCount--;
						
					}
					lightGroups[group].orderChanged = true;
					dirtyGroups.add(group);
				}
			}
			
			lights.remove(name);
			
		}
		
		return null;
		
	}
	
	public function CleanLightStates():Void
	{
		for (light in dirtyLights)
			lights[light].isDirty = false;
		
		dirtyLights.clear();
		
		for (group in dirtyGroups)
			lightGroups[group].orderChanged = false;
			
		dirtyGroups.clear();
	}
	
	public function SetUniforms(shaderProgram:GLProgram, lightGroup:String, forceUpdated:Bool = false):Void
	{
		if (lightGroups[lightGroup] != null)
		{
			var directionalIndex:Int = 0;			
			var spotIndex:Int = 0;			
			var pointIndex:Int = 0;			
			var light:Light;
			for (lightName in lightGroups[lightGroup].lights)
			{
				light = GetLight(lightName);
				if (light.isDirty) dirtyLights.add(light.name);
				switch(light.type)
				{
					
					case LightType.DIRECTIONAL : 
						if (light.isDirty || lightGroups[lightGroup].orderChanged || forceUpdated)
						{
							
							GL.uniform3f(GL.getUniformLocation(shaderProgram , "directionalLights["+directionalIndex+"].ambient"),light.ambient.getRedf(), light.ambient.getGreenf(), light.ambient.getBluef() );
							GL.uniform3f(GL.getUniformLocation(shaderProgram , "directionalLights["+directionalIndex+"].diffuse"), light.diffuse.getRedf(), light.diffuse.getGreenf(), light.diffuse.getBluef() );
							GL.uniform3f(GL.getUniformLocation(shaderProgram , "directionalLights["+directionalIndex+"].specular"), light.specular.getRedf(), light.specular.getGreenf(), light.specular.getBluef() );
							GL.uniform3f(GL.getUniformLocation(shaderProgram , "directionalLights["+directionalIndex+"].direction"), light.x, light.y, light.z );
							GL.uniform1i(GL.getUniformLocation(shaderProgram , "directionalLights["+directionalIndex+"].used"), 1);
							
						}
						directionalIndex++;
				
					case LightType.POINT : 
						if (light.isDirty || lightGroups[lightGroup].orderChanged || forceUpdated )
						{
							GL.uniform3f(GL.getUniformLocation(shaderProgram , "pointLights["+pointIndex+"].ambient"), light.ambient.getRedf(), light.ambient.getGreenf(), light.ambient.getBluef());
							GL.uniform3f(GL.getUniformLocation(shaderProgram , "pointLights["+pointIndex+"].diffuse"), light.diffuse.getRedf(), light.diffuse.getGreenf(), light.diffuse.getBluef() );
							GL.uniform3f(GL.getUniformLocation(shaderProgram , "pointLights["+pointIndex+"].specular"), light.specular.getRedf(), light.specular.getGreenf(), light.specular.getBluef() );
							GL.uniform3f(GL.getUniformLocation(shaderProgram , "pointLights["+pointIndex+"].position"), light.x, light.y, light.z );
							GL.uniform1f(GL.getUniformLocation(shaderProgram , "pointLights["+pointIndex+"].constant"), cast( light, PointLight).constant);
							GL.uniform1f(GL.getUniformLocation(shaderProgram , "pointLights["+pointIndex+"].linear"), cast( light, PointLight).linear );
							GL.uniform1f(GL.getUniformLocation(shaderProgram , "pointLights["+pointIndex+"].quadratic"), cast( light, PointLight).quadratic);
							GL.uniform1i(GL.getUniformLocation(shaderProgram , "pointLights["+pointIndex+"].used"), 1);
						}
						pointIndex++;
					
					case LightType.SPOT :
						if (light.isDirty || lightGroups[lightGroup].orderChanged|| forceUpdated)
						{
							GL.uniform3f(GL.getUniformLocation(shaderProgram , "spotLights["+spotIndex+"].ambient"), light.ambient.getRedf(), light.ambient.getGreenf(), light.ambient.getBluef() );
							GL.uniform3f(GL.getUniformLocation(shaderProgram , "spotLights["+spotIndex+"].diffuse"), light.diffuse.getRedf(), light.diffuse.getGreenf(), light.diffuse.getBluef() );
							GL.uniform3f(GL.getUniformLocation(shaderProgram , "spotLights["+spotIndex+"].specular"), light.specular.getRedf(), light.specular.getGreenf(), light.specular.getBluef() );
							GL.uniform3f(GL.getUniformLocation(shaderProgram , "spotLights["+spotIndex+"].position"), light.x, light.y, light.z );
							GL.uniform3f(GL.getUniformLocation(shaderProgram , "spotLights["+spotIndex+"].direction"), cast( light, SpotLight).directionX,  cast( light, SpotLight).directionY,  cast( light, SpotLight).directionZ );
							GL.uniform1f(GL.getUniformLocation(shaderProgram , "spotLights["+spotIndex+"].cutOff"), Math.cos(MathU.ToRadians( cast( light, SpotLight).cutOff)));
							GL.uniform1f(GL.getUniformLocation(shaderProgram , "spotLights["+spotIndex+"].outerCutOff"), Math.cos(MathU.ToRadians( cast( light, SpotLight).outerCutOff)));
							GL.uniform1i(GL.getUniformLocation(shaderProgram , "spotLights["+spotIndex+"].used"), 1);
						}
						spotIndex++;
				
				
				}			
	
			}
			
			if (lightGroups[lightGroup].orderChanged || forceUpdated)
			{
				
				for (i in directionalIndex...MAX_LIGHT_COUNT_BY_TYPE)
					GL.uniform1i(GL.getUniformLocation(shaderProgram , "directionalLights[" + i + "].used"), 0);
					
				for (i in pointIndex...MAX_LIGHT_COUNT_BY_TYPE)
					GL.uniform1i(GL.getUniformLocation(shaderProgram , "pointLights[" + i + "].used"), 0);
				
				for (i in spotIndex...MAX_LIGHT_COUNT_BY_TYPE)
					GL.uniform1i(GL.getUniformLocation(shaderProgram , "spotLights["+i+"].used"), 0);
	
			}
			
		}
		
		
		
		
		
	}
	
}

private typedef LightGroup =
{
	public var lights:List<String>;
	public var directionalLightsCount:Int;
	public var spotLightsCount:Int;
	public var pointLightsCount:Int;
	public var orderChanged:Bool;
	
}

