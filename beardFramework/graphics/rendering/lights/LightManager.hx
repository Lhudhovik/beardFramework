package beardFramework.graphics.rendering.lights;
import beardFramework.core.BeardGame;
import beardFramework.graphics.rendering.shaders.Shader;
import beardFramework.resources.assets.AssetManager;
import beardFramework.utils.graphics.Color;
import beardFramework.utils.libraries.StringLibrary;
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
	public var lights:Map<String, Light>;
	private var lightGroups:Map<String,LightGroup>;
	private var dirtyLights:List<String>;
	private var dirtyGroups:List<String>;
	
	public var shadowShader:Shader;
	public var depthShader(default, null):Shader;
	public var framebuffer:Framebuffer;
	
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
		
		shadowShader = Shader.GetShader("shadow");
		//framebuffer = new Framebuffer();
		//framebuffer.Bind(GL.FRAMEBUFFER);
		//framebuffer.CreateTexture(StringLibrary.SHADOW_MAP, BeardGame.Get().window.width, BeardGame.Get().window.height,GL.DEPTH_COMPONENT, GL.DEPTH_COMPONENT, GL.FLOAT, GL.DEPTH_ATTACHMENT,true);
		////framebuffer.CreateTexture(StringLibrary.COLOR, BeardGame.Get().window.width, BeardGame.Get().window.height, GL.RGB, GL.RGB, GL.UNSIGNED_BYTE, GL.COLOR_ATTACHMENT0,false);
		//
		//var samplerIndex:Int = AssetManager.Get().AllocateFreeTextureIndex();
		//GL.activeTexture(GL.TEXTURE0 + samplerIndex);
		//GL.bindTexture(GL.TEXTURE_2D, AssetManager.Get().AddTexture(StringLibrary.SHADOW_MAP,framebuffer.textures[StringLibrary.SHADOW_MAP].texture, BeardGame.Get().window.width,BeardGame.Get().window.height, samplerIndex ));
			//
		////trace("is the framebuffer ready ? " + (GL.checkFramebufferStatus(GL.FRAMEBUFFER) == GL.FRAMEBUFFER_COMPLETE));
		//
		//
		//
		//depthShader = Shader.GetShader(StringLibrary.DEPTH);
		//
		//framebuffer.quad.shader = Shader.GetShader("debugDepth");
		//framebuffer.quad.shader.Use();
		//framebuffer.quad.shader.SetMatrix4fv(StringLibrary.PROJECTION, Renderer.Get().projection);
		//
		//
		//framebuffer.UnBind(GL.FRAMEBUFFER);
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
	public function CheckIsGroup(light:Light, group:String):Bool
	{
		var result:Bool = false;
		if (lightGroups[group] != null)
			for (groupedLight in lightGroups[group].lights)
				if (result = (groupedLight == light.name))	break;
		
		return result;
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
		
		if (position == null) position = {x:0, y:0, z: -1};
	
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
		
		if (position == null) position = {x:0, y:0, z: -1};
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
		
		if (position == null) position = {x:0, y:0, z: -1};
		
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
	
	public function CompileLights(shader:Shader, lightGroup:String, forceUpdated:Bool = false):Void
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
							
							shader.Set3Float( "directionalLights["+directionalIndex+"].ambient",light.ambient.getRedf(), light.ambient.getGreenf(), light.ambient.getBluef() );
							shader.Set3Float( "directionalLights["+directionalIndex+"].diffuse", light.diffuse.getRedf(), light.diffuse.getGreenf(), light.diffuse.getBluef() );
							shader.Set3Float( "directionalLights["+directionalIndex+"].specular", light.specular.getRedf(), light.specular.getGreenf(), light.specular.getBluef() );
							shader.Set3Float( "directionalLights["+directionalIndex+"].direction", light.x, light.y, light.z );
							shader.SetInt("directionalLights["+directionalIndex+"].used", 1);
							
						}
						directionalIndex++;
				
					case LightType.POINT : 
						if (light.isDirty || lightGroups[lightGroup].orderChanged || forceUpdated )
						{
							shader.Set3Float( "pointLights["+pointIndex+"].ambient", light.ambient.getRedf(), light.ambient.getGreenf(), light.ambient.getBluef());
							shader.Set3Float( "pointLights["+pointIndex+"].diffuse", 200, 200, 200 );
							//shader.Set3Float( "pointLights["+pointIndex+"].diffuse", light.diffuse.getRedf(), light.diffuse.getGreenf(), light.diffuse.getBluef() );
							shader.Set3Float( "pointLights["+pointIndex+"].specular", light.specular.getRedf(), light.specular.getGreenf(), light.specular.getBluef() );
							shader.Set3Float( "pointLights["+pointIndex+"].position", light.x, light.y, light.z );
							shader.SetFloat( "pointLights["+pointIndex+"].constant", cast( light, PointLight).constant);
							shader.SetFloat("pointLights["+pointIndex+"].linear", cast( light, PointLight).linear );
							shader.SetFloat( "pointLights["+pointIndex+"].quadratic", cast( light, PointLight).quadratic);
							shader.SetInt("pointLights["+pointIndex+"].used", 1);
						}
						pointIndex++;
					
					case LightType.SPOT :
						if (light.isDirty || lightGroups[lightGroup].orderChanged|| forceUpdated)
						{
							shader.Set3Float( "spotLights["+spotIndex+"].ambient", light.ambient.getRedf(), light.ambient.getGreenf(), light.ambient.getBluef() );
							shader.Set3Float( "spotLights["+spotIndex+"].diffuse", light.diffuse.getRedf(), light.diffuse.getGreenf(), light.diffuse.getBluef() );
							shader.Set3Float( "spotLights["+spotIndex+"].specular", light.specular.getRedf(), light.specular.getGreenf(), light.specular.getBluef() );
							shader.Set3Float( "spotLights["+spotIndex+"].position", light.x, light.y, light.z );
							shader.Set3Float( "spotLights["+spotIndex+"].direction", cast( light, SpotLight).directionX,  cast( light, SpotLight).directionY,  cast( light, SpotLight).directionZ );
							shader.SetFloat( "spotLights["+spotIndex+"].cutOff", Math.cos(MathU.ToRadians( cast( light, SpotLight).cutOff)));
							shader.SetFloat( "spotLights[" + spotIndex + "].outerCutOff", Math.cos(MathU.ToRadians( cast( light, SpotLight).outerCutOff)));
							shader.SetFloat( "spotLights["+spotIndex+"].constant", cast( light, PointLight).constant);
							shader.SetFloat("spotLights["+spotIndex+"].linear", cast( light, PointLight).linear );
							shader.SetFloat( "spotLights["+spotIndex+"].quadratic", cast( light, PointLight).quadratic);
							shader.SetInt("spotLights["+spotIndex+"].used", 1);
						}
						spotIndex++;
				
				
				}			
	
			}
			
			if (lightGroups[lightGroup].orderChanged || forceUpdated)
			{
				
				for (i in directionalIndex...MAX_LIGHT_COUNT_BY_TYPE)
					shader.SetInt( "directionalLights[" + i + "].used", 0);
					
				for (i in pointIndex...MAX_LIGHT_COUNT_BY_TYPE)
					shader.SetInt( "pointLights[" + i + "].used", 0);
				
				for (i in spotIndex...MAX_LIGHT_COUNT_BY_TYPE)
					shader.SetInt("spotLights["+i+"].used", 0);
	
			}
			//shader.SetInt(StringLibrary.SHADOW_MAP, AssetManager.Get().GetTexture(StringLibrary.SHADOW_MAP).fixedIndex);
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

