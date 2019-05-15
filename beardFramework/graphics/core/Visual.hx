package beardFramework.graphics.core;
import beardFramework.core.BeardGame;
import beardFramework.graphics.cameras.Camera;
import beardFramework.graphics.rendering.Quad;
import beardFramework.graphics.rendering.Renderer;
import beardFramework.graphics.rendering.RenderingData;
import beardFramework.graphics.rendering.Shadow;
import beardFramework.graphics.rendering.lights.Light;
import beardFramework.graphics.rendering.shaders.Shader;
import beardFramework.graphics.rendering.lights.LightManager;
import beardFramework.graphics.rendering.shaders.MaterialComponent;
import beardFramework.graphics.rendering.shaders.RenderedDataBufferArray;
import beardFramework.graphics.rendering.shaders.VertexAttribute;
import beardFramework.interfaces.IRenderable;
import beardFramework.resources.assets.AssetManager;
import beardFramework.resources.save.data.StructDataVisual;
import beardFramework.utils.graphics.GLU;
import beardFramework.utils.libraries.StringLibrary;
import beardFramework.utils.math.Edge;
import beardFramework.utils.simpleDataStruct.SVec2;
import haxe.ds.Vector;
import lime.graphics.opengl.GL;
import lime.graphics.opengl.GLBuffer;
import lime.graphics.opengl.GLProgram;
import lime.graphics.opengl.GLShader;
import lime.graphics.opengl.GLVertexArrayObject;
import lime.math.Vector2;
import lime.math.Vector4;
import lime.utils.Float32Array;
import lime.utils.UInt16Array;

/**
 * ...
 * @author 
 */
class Visual extends AbstractVisual implements IRenderable
{
	private static var TEMPLATE(default, never):String ="visual" ; //overide with local variable if necessary
	private static var verticesData:Float32Array; //overide with local variable if necessary
	private static var indices:UInt16Array;
	private static var VBO:GLBuffer;
	private static var EBO:GLBuffer;
	private static var VAO:GLVertexArrayObject;
	public static var sharedShader:Shader;
	
	@:isVar public var readyForRendering(get, null):Bool;
	
	public var shader(default, null):Shader;
	public var cameras:List<String>;
	public var drawMode:Int;
	public var lightGroup(default, set):String;	
	public var lightGroupChanged:Bool;
	
	private var renderer:Renderer;
	private var shadows:Map<String, Shadow>;
	
	public static function InitSharedGraphics():Void
	{
		sharedShader = Shader.GetShader("visualDefault");
		
		VAO = Renderer.Get().GenerateVAO();
		
		GL.bindVertexArray(VAO);
		
		VBO = Renderer.Get().GenerateBuffer();
		GL.bindBuffer(GL.ARRAY_BUFFER, VBO);
			
		GL.enableVertexAttribArray(0);
		GL.vertexAttribPointer(0, 3, GL.FLOAT, false, 3 * Float32Array.BYTES_PER_ELEMENT, 0);
		//----------------------------  x   y  z  
		verticesData = new Float32Array([0, 1, 0,
										1, 1, 0,
										1, 0, 0,
										0, 0, 0]);
		
		GL.bufferData(GL.ARRAY_BUFFER, verticesData.byteLength, verticesData, GL.DYNAMIC_DRAW);
		
					
		indices = new UInt16Array([0, 1, 2, 2, 3, 0]);
		
		EBO  = Renderer.Get().GenerateBuffer();
		
		GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, EBO);
		GL.bufferData(GL.ELEMENT_ARRAY_BUFFER, indices.byteLength, indices, GL.DYNAMIC_DRAW);
		
		
		GL.bindBuffer(GL.ARRAY_BUFFER, 0);
		GL.bindVertexArray(0);
		
		
		
	}
	
	public function new(texture:String, atlas:String, name:String="") 
	{
		super(texture, atlas, name);
		lightGroup = StringLibrary.DEFAULT;
		drawMode = GL.TRIANGLES;
		shader = sharedShader;
		cameras = new List();
		cameras.add(StringLibrary.DEFAULT);
		renderer = Renderer.Get();
		readyForRendering = true;
		shadows = new Map();
	}
	
	function get_readyForRendering():Bool 
	{
		return material!=null;
	}
	
	private function SetUniforms():Void
	{
		
		shader.Use();
				
		var component:MaterialComponent;
		var activeTextures:Map<String,Int> = new Map();
		var sampleUnit:Int = 0;
		var availableUnit:Int = AssetManager.Get().GetFreeTextureUnit();
		
		for (componentName in material.components.keys())
		{
			component = material.components[componentName];
			if (component.texture != "")
			{
				
				if (component.atlas != "")
				{
					sampleUnit = AssetManager.Get().GetTexture(component.atlas).fixedIndex;
				}
				else
				{
					if (activeTextures[component.texture] == null)
					{
						activeTextures[component.texture] = availableUnit++;
					}
					
					GL.activeTexture(GL.TEXTURE0 + activeTextures[component.texture]);
					GL.bindTexture(GL.TEXTURE_2D, AssetManager.Get().GetTexture(component.texture).glTexture);
					sampleUnit = activeTextures[component.texture] ;
				}
				
				shader.SetInt("material." + componentName + ".sampler", sampleUnit);			
				shader.Set4Float("material." + componentName+".uv", component.uv.x, component.uv.y, component.uv.width, component.uv.height);
				
			}
			else
			{
				
				shader.SetInt("material." + componentName + ".sampler", 0);			
				shader.Set4Float("material." + componentName+".uv", component.uv.x, component.uv.y, component.uv.width, component.uv.height);
				
				
			}
			shader.Set3Float("material." + componentName + ".color", component.color.getRedf(), component.color.getGreenf(), component.color.getBluef());
			
			
		}
		
		shader.SetFloat("material.transparency", material.transparency);
		shader.SetFloat("material.shininess", material.shininess);
		
		
		
		renderer.model.identity();
		renderer.model.appendScale(this.width, this.height, 1.0);
		renderer.model.appendTranslation(this.x, this.y, (visible ? renderDepth : Renderer.Get().VISIBLEDEPTHLIMIT + 1));
		renderer.model.appendRotation(this.rotation, renderer.rotationAxis);
		shader.SetMatrix4fv(StringLibrary.MODEL, renderer.model);
		
		

	}
		
	public function Render(camera:Camera):Int 
	{
		
		
		SetUniforms();
		
		var drawCount:Int = 0;
		
		//GL.bindVertexArray(VAO);
		if (renderer.boundBuffer != VBO){
		
			shader.Use();
			
			GL.bindBuffer(GL.ARRAY_BUFFER, VBO);
			renderer.boundBuffer = VBO;
			
			GL.enableVertexAttribArray(0);
			GL.vertexAttribPointer(0, 3, GL.FLOAT, false, 3 * Float32Array.BYTES_PER_ELEMENT, 0);
					
			GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, EBO);
			GL.bufferData(GL.ELEMENT_ARRAY_BUFFER, indices.byteLength, indices, GL.DYNAMIC_DRAW);
		}
		

		LightManager.Get().CompileLights(shader, this.lightGroup, lightGroupChanged);
		lightGroupChanged = false;
		
		shader.SetMatrix4fv(StringLibrary.PROJECTION, camera.projection);
		shader.SetMatrix4fv(StringLibrary.VIEW, camera.view);
		GL.drawElements(drawMode, indices.length, GL.UNSIGNED_SHORT, 0);
		
		drawCount++;
		
		GLU.ShowErrors();
			
		
			
		
		return drawCount;
	}
	
	
	
	override public function CastShadow(light:Light):Void 
	{
		
		if (shadows[light.name] == null){
			shadows[light.name] = new Shadow();
			renderer.AddRenderable(shadows[light.name], true);
		}
		
		var shadow:Shadow =  shadows[light.name] ;
		shadow.shader.Use();
			
		var TopL:SVec2 = {x:x, y:y};
		var TopR:SVec2 = {x:x+width, y:y};
		var BotR:SVec2 = {x:x+width, y:y+height};
		var BotL:SVec2 = {x:x, y:y + height};
		
		RenderedObject.topEdge.normal.x = TopR.y - TopL.y;
		RenderedObject.topEdge.normal.y = -(TopR.x - TopL.x);
		
		RenderedObject.leftEdge.normal.x = TopL.y - BotL.y;
		RenderedObject.leftEdge.normal.y = TopL.x - BotL.x;
		
		RenderedObject.rightEdge.normal.x = BotR.y - TopR.y;
		RenderedObject.rightEdge.normal.y = BotR.x - TopR.x;
		
		RenderedObject.bottomEdge.normal.x = BotL.y - BotR.y;
		RenderedObject.bottomEdge.normal.y = -(BotL.x - BotR.x);
				
		var direction:SVec2 ={x:light.x - (this.x + this.width * 0.5), y:  light.y - (y + height * 0.5) };
		
		var dot:Float; 
				
		RenderedObject.topEdge.lighted = ((dot = RenderedObject.topEdge.normal.x * direction.x + RenderedObject.topEdge.normal.y * direction.y) > 0);
		
		RenderedObject.leftEdge.lighted = ((dot = RenderedObject.leftEdge.normal.x * direction.x + RenderedObject.leftEdge.normal.y * direction.y) > 0);
		
		RenderedObject.rightEdge.lighted = ((dot = RenderedObject.rightEdge.normal.x * direction.x + RenderedObject.rightEdge.normal.y * direction.y) > 0);
		
		RenderedObject.bottomEdge.lighted = ((dot = RenderedObject.bottomEdge.normal.x * direction.x + RenderedObject.bottomEdge.normal.y * direction.y) > 0);
		
		var shadowPoint:Array<SVec2> = [];
				
		var firstIndex:Int =-1;
		var secondIndex:Int =-1;
		
		var pos1:SVec2 = {x:0,y:0};
		var pos2:SVec2 = {x:0, y: 0};
		
		
		
		if ((RenderedObject.topEdge.lighted && !RenderedObject.leftEdge.lighted) || (RenderedObject.leftEdge.lighted && !RenderedObject.topEdge.lighted)){
			
			//shadowPoint.push(TopL);
		
			firstIndex = 0;
			
			pos1 = TopL;
		}
			
		if ((RenderedObject.topEdge.lighted && !RenderedObject.rightEdge.lighted) || (RenderedObject.rightEdge.lighted && !RenderedObject.topEdge.lighted)){
			
			//shadowPoint.push(TopR);
			
			if (firstIndex < 0){
				firstIndex = 1;
				pos1 = TopR;
			}
			
			else{
				secondIndex = 1;
				pos2 = TopR;
			}
			
			
		}
							
		if ((RenderedObject.rightEdge.lighted && !RenderedObject.bottomEdge.lighted) || (RenderedObject.bottomEdge.lighted && !RenderedObject.rightEdge.lighted)){
			
		
			if (firstIndex < 0){
				firstIndex = 2;
				pos1 = BotR;
			}			
			else{
				secondIndex = 2;
				pos2 = BotR;
			}
			
		}
				
		if ((RenderedObject.bottomEdge.lighted && !RenderedObject.leftEdge.lighted) || (RenderedObject.leftEdge.lighted && !RenderedObject.bottomEdge.lighted)){
			
			
			secondIndex = 3;
			pos2 = BotL;
			//shadowPoint.push(BotL);
		
		}
		
		
		
		
		
	
		//
		shadow.shader.SetInt("borderPoint1", firstIndex); 
		shadow.shader.Set2Float("borderPoint1Pos", borderPoint1Pos.x, borderPoint1Pos.y); 
		shadow.shader.SetInt("borderPoint2", borderPoint2); 
		shadow.shader.Set2Float("borderPoint2Pos", borderPoint2Pos.x, borderPoint2Pos.y); 
		
		shadow.width = this.width;
		shadow.height = this.height;
		shadow.x = this.x;
		shadow.y = this.y;
		shadow.z = this.z;
		shadow.cameras = this.cameras;
		shadow.shader.Set3Float("lightPos", light.x, light.y, light.z);
		shadow.shader.SetInt("useModel", 1);

		//trace(shadowPointID);
		//trace("top : " + RenderedObject.topEdge.lighted);
		//trace("left : " +  RenderedObject.leftEdge.lighted);
		//trace("right : " +  RenderedObject.rightEdge.lighted);
		//trace("bottom: " +  RenderedObject.bottomEdge.lighted);
		//trace("\n");
		
		
	}
	//public function CastShadow(light:Light, camera:Camera):Void 
	//{
		//
		//
		//var usedShader:Shader = LightManager.Get().shadowShader;
		//
		//usedShader.Use();
		//
		//usedShader.SetInt("useModel", 1);
		//
		//renderer.model.identity();
		//renderer.model.appendScale(this.width, this.height, 1.0);
		//renderer.model.appendTranslation(this.x, this.y, (visible ? renderDepth : Renderer.Get().VISIBLEDEPTHLIMIT + 1));
		//renderer.model.appendRotation(this.rotation, renderer.rotationAxis);
		//usedShader.SetMatrix4fv(StringLibrary.MODEL, renderer.model);
		//
		//usedShader.Set3Float("lightPos", light.x, light.y, light.z);
		//usedShader.SetFloat("groundY", 100);
		//usedShader.SetFloat("groundAngle", 10);
				//
		////var drawCount:Int = 0;
		//
		////GL.bindVertexArray(VAO);
		//if (renderer.boundBuffer != VBO){
		//
			////shader.Use();
			//
			//GL.bindBuffer(GL.ARRAY_BUFFER, VBO);
			//renderer.boundBuffer = VBO;
			//
			//GL.enableVertexAttribArray(0);
			//GL.vertexAttribPointer(0, 3, GL.FLOAT, false, 3 * Float32Array.BYTES_PER_ELEMENT, 0);
					//
			//GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, EBO);
			//GL.bufferData(GL.ELEMENT_ARRAY_BUFFER, indices.byteLength, indices, GL.DYNAMIC_DRAW);
		//}
		//
//
		////LightManager.Get().CompileLights(shader, this.lightGroup, lightGroupChanged);
		////lightGroupChanged = false;
		//
		//usedShader.SetMatrix4fv(StringLibrary.PROJECTION, camera.projection);
		//usedShader.SetMatrix4fv(StringLibrary.VIEW, camera.view);
		//GL.drawElements(drawMode, indices.length, GL.UNSIGNED_SHORT, 0);
		//
		////drawCount++;
		//
		//GLU.ShowErrors();
			//
		//
			//
		////
		////return drawCount;
	//}
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
	override function set_atlas(value:String):String 
	{
		if (material != null && material.hasComponent("diffuse"))
		{
			material.components["diffuse"].atlas = value;
		}
		
		return super.set_atlas(value);
	}

	function set_lightGroup(value:String):String 
	{
		if (lightGroup != value) lightGroupChanged = true;
		return lightGroup = value;
	}
	
	public function ToData():StructDataVisual
	{
		
		
		var data:StructDataVisual =
		{
			
			name:this.name,
			type:Type.getClassName(Visual),
			x:this.x,
			y:this.y,
			z:this.z,
			shader:	Shader.GetShaderName(this.shader),
			material: this.material.ToData(),
			drawMode:drawMode,
			lightGroup:lightGroup,
			cameras:cameras,
			additionalData:""
			
			
		}
	
		return data;
		
	}
	
	public function ParseData(data:StructDataVisual):Void
	{
		this.name = data.name;
		this.x = data.x;
		this.y = data.y;
		this.z = data.z;
		if (data.shader != "")
			this.shader = Shader.GetShader(data.shader);
		else this.shader = sharedShader;
		
		material.ParseData(data.material);
		
		drawMode = data.drawMode;
		
		lightGroup = data.lightGroup;
		cameras = data.cameras;
	}
	
	
}