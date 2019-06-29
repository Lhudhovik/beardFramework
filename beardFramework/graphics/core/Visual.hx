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
import beardFramework.utils.math.MathU;
import beardFramework.utils.simpleDataStruct.SRect;
import beardFramework.utils.simpleDataStruct.SVec2;
import beardFramework.utils.simpleDataStruct.SVec3;
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
	private static var tangent1:Vector4;
	private static var tangent2:Vector4;
	private static var bitangent1:Vector4;
	private static var bitangent2:Vector4;
	public static var sharedShader:Shader;
	
	@:isVar public var readyForRendering(get, null):Bool;
	
	public var shader(default, null):Shader;
	public var drawMode:Int;
	public var lightGroup(default, set):String;	
	public var lightGroupChanged:Bool;
	
	private var renderer:Renderer;
	
	
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
		
		tangent1 = new Vector4();
		tangent2 = new Vector4();
		bitangent1 = new Vector4();
		bitangent2 = new Vector4();
		
		
		
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
		
		
		if (material.components[StringLibrary.NORMAL_MAP].texture != "")
		{
			
			var uvs:SRect = material.components[StringLibrary.NORMAL_MAP].uv;
			
			var pos1:Vector4 = new Vector4(verticesData[0], verticesData[1], verticesData[2]);
			var pos2:Vector4 = new Vector4(verticesData[3], verticesData[4], verticesData[5]);
			var pos3:Vector4 = new Vector4(verticesData[6], verticesData[7], verticesData[8]);
			var pos4:Vector4 = new Vector4(verticesData[9], verticesData[10], verticesData[11]);
			
			var uv1:Vector2 = new Vector2(uvs.x + verticesData[0]*uvs.width, uvs.y + verticesData[1]*uvs.height);
			var uv2:Vector2= new Vector2(uvs.x + verticesData[3]*uvs.width, uvs.y + verticesData[4]*uvs.height);
			var uv3:Vector2= new Vector2(uvs.x + verticesData[6]*uvs.width, uvs.y + verticesData[7]*uvs.height);
			var uv4:Vector2= new Vector2(uvs.x + verticesData[9]*uvs.width, uvs.y + verticesData[10]*uvs.height);
			
			var edge1 = pos2.subtract(pos1);
			var edge2 = pos3.subtract(pos1);
			var deltaUV1 = uv2.subtract(uv1);
			var deltaUV2 = uv3.subtract(uv1);
			var f:Float = 1.0 / (deltaUV1.x * deltaUV2.y - deltaUV2.x * deltaUV1.y);
			
			tangent1.x = f * (deltaUV2.y * edge1.x - deltaUV1.y * edge2.x);
			tangent1.y = f * (deltaUV2.y * edge1.y - deltaUV1.y * edge2.y);
			tangent1.z = f * (deltaUV2.y * edge1.z - deltaUV1.y * edge2.z);
			tangent1.normalize();
			
			bitangent1.x = f * (-deltaUV2.x * edge1.x + deltaUV1.x * edge2.x);
			bitangent1.y = f * (-deltaUV2.x * edge1.y + deltaUV1.x * edge2.y);
			bitangent1.z = f * ( -deltaUV2.x * edge1.z + deltaUV1.x * edge2.z);
			bitangent1.normalize();
			
			edge1 = pos4.subtract(pos3);
			edge2 = pos1.subtract(pos3);
			
			deltaUV1 = uv4.subtract(uv3);
			deltaUV2 = uv1.subtract(uv3);
			
			tangent2.x = f * (deltaUV2.y * edge1.x - deltaUV1.y * edge2.x);
			tangent2.y = f * (deltaUV2.y * edge1.y - deltaUV1.y * edge2.y);
			tangent2.z = f * (deltaUV2.y * edge1.z - deltaUV1.y * edge2.z);
			tangent2.normalize();
			
			bitangent2.x = f * (-deltaUV2.x * edge1.x + deltaUV1.x * edge2.x);
			bitangent2.y = f * (-deltaUV2.x * edge1.y + deltaUV1.x * edge2.y);
			bitangent2.z = f * ( -deltaUV2.x * edge1.z + deltaUV1.x * edge2.z);
			bitangent2.normalize();
			
			shader.Set3Float("tangent", tangent1.x, tangent1.y, tangent1.z);
			shader.Set3Float("bitangent", bitangent1.x, bitangent1.y, bitangent1.z);
		}
		
		
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
		shader.Set3Float("viewPosition", camera.viewportWidth*0.5 -camera.centerX, camera.viewportHeight*0.5 - camera.centerY, -1 );
		
		GL.drawElements(drawMode, indices.length, GL.UNSIGNED_SHORT, 0);
		
		drawCount++;
		//trace(renderDepth);
		GLU.ShowErrors();
			
		
			
		
		return drawCount;
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
	override function set_atlas(value:String):String 
	{
		if (material != null && material.hasComponent(StringLibrary.DIFFUSE))
		{
			material.components[StringLibrary.DIFFUSE].atlas = value;
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