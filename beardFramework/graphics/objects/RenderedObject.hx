package beardFramework.graphics.objects;
import beardFramework.core.BeardGame;
import beardFramework.graphics.cameras.Camera;
import beardFramework.graphics.core.Renderer;
import beardFramework.graphics.lights.Shadow;
import beardFramework.graphics.batches.Batch;
import beardFramework.graphics.batches.RenderedObjectBatch;
import beardFramework.graphics.lights.Light;
import beardFramework.graphics.screens.BeardLayer;
import beardFramework.graphics.shaders.Material;
import beardFramework.graphics.shaders.MaterialComponent;
import beardFramework.graphics.shaders.Shader;
import beardFramework.interfaces.IRenderable;
import beardFramework.interfaces.ISpatialized;
import beardFramework.systems.aabb.AABB;
import beardFramework.utils.graphics.Color;
import beardFramework.utils.graphics.Edge;
import beardFramework.utils.libraries.StringLibrary;
import beardFramework.utils.simpleDataStruct.SVec2;


/**
 * ...
 * @author 
 */
class RenderedObject extends WorldObject implements IRenderable
{
	
	public static var topEdge:Edge = {lighted:false, normal: {x:0, y:0}};
	public static var leftEdge:Edge= {lighted:false, normal: {x:0, y:0}};
	public static var rightEdge:Edge= {lighted:false, normal: {x:0, y:0}};
	public static var bottomEdge:Edge= {lighted:false, normal: {x:0, y:0}};
	
	
	@:isVar public var canRender(get, set):Bool;
	@:isVar public var shader(get, set):Shader;
	@:isVar public var depth(get, set):Float;		
		
	public var alpha(get, set):Float;
	public var cameras:List<String>;	
	public var rotationCosine(default,null):Float;
	public var rotationSine(default, null):Float;
	public var material:Material;
	public var color(get, set):Color;
	public var shadowCaster(default, set):Bool;
	public var lightGroup(default, set):String;
	
	private var shadows:Map<String, Shadow>;
	
	private function new() 
	{
		super();
		canRender = true;
		z = -1;
		depth = -2;
		scaleX = scaleY = 1;
		cachedWidth = cachedHeight = 0;
		rotation = 0;
		rotationSine = Math.sin (0);
		rotationCosine = Math.cos (0);
		cameras = new List<String>();
		material = new Material();
		var diffuseComponent:MaterialComponent = {color:Color.WHITE, texture:"", atlas:"", uv: { width:1, height:1, x : 0, y:0 }};
		var specularComponent:MaterialComponent = {color:Color.WHITE, texture:"", atlas:"", uv: { width:1, height:1, x : 0, y:0 }};
		var normalComponent:MaterialComponent = {color:Color.WHITE, texture:"", atlas:"", uv: { width:0, height:0, x : 0, y:0 }};
		var bloomComponent:MaterialComponent = {color:Color.CLEAR, texture:"", atlas:"", uv: { width:0, height:0, x : 0, y:0 }};
		material.components[StringLibrary.DIFFUSE] = diffuseComponent;
		material.components[StringLibrary.SPECULAR] = specularComponent;
		material.components[StringLibrary.NORMAL_MAP] = normalComponent;
		material.components[StringLibrary.BLOOM_MAP] = bloomComponent;
		material.transparency = 1;
		shadows = new Map();
		shadowCaster = true;
	}
	
	override function set_z(value:Float):Float 
	{
		z = value;
		
		if (layer != null)
		{
			depth = layer.depth + (z*100 / layer.maxObjectsCount);
			//trace(layer.name);
			//trace(z);
			//trace(layer.depth);
		}
		
		isDirty = true;
		return z;
	}
	
	function get_alpha():Float 
	{
		return material.transparency;
	}
	
	function set_alpha(value:Float):Float 
	{
		return material.transparency = value;
	}
	
	function get_color():Color 
	{
		return material.components[StringLibrary.DIFFUSE].color;
	}
	
	function set_color(value:Color):Color 
	{
		isDirty = true;
		return material.components[StringLibrary.DIFFUSE].color = value;
	}
	
	
	
	public function CastShadow(light:Light):Void 
	{
		var shadowName:String = this.name + StringLibrary.SHADOW + light.name;
		if (shadows[shadowName] == null){
			shadows[shadowName] = new Shadow();
			shadows[shadowName].name = shadowName;
			Renderer.Get().AddRenderable(shadows[shadowName], true);
		}
		
		var shadow:Shadow =  shadows[shadowName] ;
		shadow.shader.Use();
			
		var TopL:SVec2 = {x:x, y:y};
		var TopR:SVec2 = {x:x+width, y:y};
		var BotR:SVec2 = {x:x+width, y:y+height};
		var BotL:SVec2 = {x:x, y:y + height};
		
		topEdge.normal.x = TopR.y - TopL.y;
		topEdge.normal.y = -(TopR.x - TopL.x);
		
		leftEdge.normal.x = TopL.y - BotL.y;
		leftEdge.normal.y = TopL.x - BotL.x;
		
		rightEdge.normal.x = BotR.y - TopR.y;
		rightEdge.normal.y = BotR.x - TopR.x;
		
		bottomEdge.normal.x = BotL.y - BotR.y;
		bottomEdge.normal.y = -(BotL.x - BotR.x);
				
		var direction:SVec2 ={x:0, y: 0 };
		var dot:Float; 
		
		direction.x = light.x - (this.x + this.width * 0.5);
		direction.y = light.y- (this.y);
		topEdge.lighted = ((dot = topEdge.normal.x * direction.x + topEdge.normal.y * direction.y) > 0);
			
		direction.x = light.x - (this.x);
		direction.y = light.y- (this.y+ this.height *0.5);
		leftEdge.lighted = ((dot = leftEdge.normal.x * direction.x + leftEdge.normal.y * direction.y) > 0);
		
	
		direction.x = light.x - (this.x + this.width);
		direction.y = light.y- (this.y + this.height*0.5);
		rightEdge.lighted = ((dot = rightEdge.normal.x * direction.x + rightEdge.normal.y * direction.y) > 0);
	
		
		direction.x = light.x - (this.x + this.width * 0.5);
		direction.y = light.y- (this.y + this.height);
		bottomEdge.lighted = ((dot = bottomEdge.normal.x * direction.x + bottomEdge.normal.y * direction.y) > 0);
			
		var pos1:SVec2 = null;
		var pos2:SVec2 = null;
		
		if ((topEdge.lighted && !leftEdge.lighted) || (leftEdge.lighted && !topEdge.lighted)){
			
			pos1 = TopL;
			
		}
		if ((topEdge.lighted && !rightEdge.lighted) || (rightEdge.lighted && !topEdge.lighted)){
			if (pos1 == null)		pos1 = TopR;
			else if(pos2 == null) 	pos2 = TopR;
		
		}				
		if ((rightEdge.lighted && !bottomEdge.lighted) || (bottomEdge.lighted && !rightEdge.lighted)){
			if (pos1 == null)		pos1 = BotR;
			else if(pos2 == null)	pos2 = BotR;
			
		}
		if ((bottomEdge.lighted && !leftEdge.lighted) || (leftEdge.lighted && !bottomEdge.lighted)){
			if(pos2 == null) pos2 = BotL;
				
		}
		
		
		
		if (pos1 != null && pos2 != null){
			shadow.corner1.x = pos1.x; 
			shadow.corner1.y = pos1.y; 
			shadow.corner2.x = pos2.x; 
			shadow.corner2.y = pos2.y; 
			shadow.depth = this.depth +0.0005;
		}
		else shadow.depth = Renderer.Get().VISIBLE + 1;
		shadow.shader.Set4Float(StringLibrary.SHADOW_COLOR, 0,0,0,0.2); 
				
		shadow.width = this.width;
		shadow.height = this.height;
		shadow.x = this.x;
		shadow.y = this.y;
		
		shadow.z = this.z + 0.0005;
		//trace(shadow.z);
		shadow.cameras = this.cameras;
		shadow.lightPos.x = light.x; 
		shadow.lightPos.y = light.y; 
		shadow.lightPos.z = light.z;
		shadow.limits.x = -10000;
		shadow.limits.y = this.y + this.height + 100000;
		shadow.limits.width = -50000; 
		shadow.limits.height = 150000;
		
		
		//trace(shadowPointID);
		//trace("top : " + RenderedObject.topEdge.lighted);
		//trace("left : " +  RenderedObject.leftEdge.lighted);
		//trace("right : " +  RenderedObject.rightEdge.lighted);
		//trace("bottom: " +  RenderedObject.bottomEdge.lighted);
		////trace("\n");
		
		
	}
	
	function set_lightGroup(value:String):String 
	{
		return lightGroup = value;
	}
	
	public function Render(camera:Camera):Int 
	{
		return 0;
	}
	
	public inline function HasCamera(camera:String):Bool 
	{
		var result:Bool = false;
		
		for (name in cameras)
		if (name == camera)
		{
			result = true;
			break;
		}
		
		return result;
	}
		
		
	override public function DeActivate():Void 
	{
		isActivated = false;
		canRender = false;
	}
	
	inline function get_depth():Float 
	{
		return depth;
	}
	
	inline function set_depth(value:Float):Float 
	{
		return depth = value;
	}
		
	function get_canRender():Bool 
	{
		return canRender;
	}
	
	function set_canRender(value:Bool):Bool 
	{
		return canRender = value;
	}
	
	
	
	function set_shadowCaster(value:Bool):Bool 
	{
		
		if (value != shadowCaster && value == false)
		{
			for (shadow in shadows)
			{				
				Renderer.Get().RemoveRenderable(shadow);
				shadows.remove(shadow.name);
				shadow = null;
			}
		}
		return shadowCaster = value;
	}
	
	function get_shader():Shader 
	{
		return shader;
	}
	
	function set_shader(value:Shader):Shader 
	{
		return shader=value;
	}
	
	
	
}