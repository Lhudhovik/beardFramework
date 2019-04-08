package beardFramework.graphics.core;
import beardFramework.core.BeardGame;
import beardFramework.graphics.cameras.Camera;
import beardFramework.graphics.rendering.Renderer;
import beardFramework.graphics.rendering.RenderingData;
import beardFramework.graphics.rendering.shaders.Shader;
import beardFramework.graphics.rendering.lights.LightManager;
import beardFramework.graphics.rendering.shaders.MaterialComponent;
import beardFramework.graphics.rendering.shaders.RenderedDataBufferArray;
import beardFramework.graphics.rendering.shaders.VertexAttribute;
import beardFramework.interfaces.IRenderable;
import beardFramework.resources.assets.AssetManager;
import beardFramework.utils.graphics.GLU;
import haxe.ds.Vector;
import lime.graphics.opengl.GL;
import lime.graphics.opengl.GLBuffer;
import lime.graphics.opengl.GLProgram;
import lime.graphics.opengl.GLShader;
import lime.graphics.opengl.GLVertexArrayObject;
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
	
	@:isVar public var readyForRendering(get, null):Bool;
	
	public var shader(default, null):Shader;
	public var cameras:List<String>;
	public var drawMode:Int;
	public var lightGroup(default, set):String;	
	
	private var renderer:Renderer;
	
	public static function InitSharedGraphics():Void
	{
		
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
		
		GL.bufferData(GL.ARRAY_BUFFER, verticesData.byteLength, verticesData, GL.STATIC_DRAW);
		
					
		var indices:UInt16Array = new UInt16Array([0, 1, 2, 2, 3, 0]);
		
		EBO  = Renderer.Get().GenerateBuffer();
		
		GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, EBO);
		GL.bufferData(GL.ELEMENT_ARRAY_BUFFER, indices.byteLength, indices, GL.DYNAMIC_DRAW);
		
		
		GL.bindBuffer(GL.ARRAY_BUFFER, 0);
		GL.bindVertexArray(0);
		
			
		
	}
	
	public function new(texture:String, atlas:String, name:String="") 
	{
		super(texture, atlas, name);
				
		cameras = new List();
		for (camera in BeardGame.Get().cameras)
			cameras.add(camera.name);
		
	}
	
	public function Init(data:RenderingData):Void
	{
		
		renderer = Renderer.Get();
		drawMode = data.drawMode;
	
		lightGroup = data.lightGroup;
		
		InitShaders(data.shaders);
				
		cameras = new List();
		
		for (camera in BeardGame.Get().cameras)
			cameras.add(camera.name);
	}
	
		
	public function InitShaders(shadersList:Array<NativeShader>):Void
	{
		
		shader = Shader.CreateShader(shadersList);
		
		shader.Use();
		
		for (camera in cameras)
		{
			shader.SetMatrix4fv("projection", BeardGame.Get().cameras[camera].projection);
			shader.SetMatrix4fv("view", BeardGame.Get().cameras[camera].view);
		}
	}
	
		
	function get_readyForRendering():Bool 
	{
		return readyForRendering;
	}
	
	private inline function SetUniforms():Void
	{
		
		shader.Use();
		shader.SetMatrix4fv("projection", renderer.projection);
		
		var component:MaterialComponent;
		var textureIndex:Int = renderer.GetFreeTextureUnit();
		for (componentName in material.components.keys())
		{
			
			component = material.components[componentName];
			if (component.texture != "")
			{
				
				if (component.atlas > -1)
				{
					GL.uniform1i(GL.getUniformLocation(shader , "material." + componentName+".atlasIndex"), component.atlas);			
				}
				else
				{
					GL.activeTexture(GL.TEXTURE0 + textureIndex);
					GL.bindTexture(GL.TEXTURE_2D, AssetManager.Get().GetTexture(component.texture));
					GL.uniform1i(GL.getUniformLocation(shader , "material." + componentName+".sampler"), component.atlas);
				}
				
				
			}
						
			
		}
		
		
		GL.uniform1i(GL.getUniformLocation(shader , "material.diffuse.sampler")
		//GL.uniform3f(GL.getUniformLocation(shaderProgram , "directionalLights["+directionalIndex+"].ambient"),light.ambient.getRedf(), light.ambient.getGreenf(), light.ambient.getBluef() );
			sampler2D sampler;
	vec4 uv;
	vec3 color;
	int atlasIndex;
	int useSampler;
		
	}
		
	public function Render():Int 
	{
		
		if (isDirty){
			SetUniforms();
			isDirty = false;
		}
		var drawCount:Int = 0;
		
		//GL.bindVertexArray(VAO);
		if (renderer.boundBuffer != VBO){
			
			GL.bindBuffer(GL.ARRAY_BUFFER, VBO);
			renderer.boundBuffer = VBO;
			//var pointer:Int;
			//var stride:Int = 0;
			//for (attribute in vertexAttributes)
			//{
				//
				////trace(attribute);
				//pointer = GL.getAttribLocation(shaderProgram, attribute.name);
				//GL.enableVertexAttribArray(pointer);
				////GL.enableVertexAttribArray(attribute.index);
				////GL.vertexAttribPointer(attribute.index, attribute.size, GL.FLOAT, false, renderedData.vertexStride * Float32Array.BYTES_PER_ELEMENT, stride* Float32Array.BYTES_PER_ELEMENT);
				//GL.vertexAttribPointer(pointer, attribute.size, GL.FLOAT, false, verticesData.vertexStride * Float32Array.BYTES_PER_ELEMENT, stride* Float32Array.BYTES_PER_ELEMENT);
				//stride += attribute.size;
				//
				//
			//}
			
			GL.enableVertexAttribArray(0);
			GL.vertexAttribPointer(0, 3, GL.FLOAT, false, 3 * Float32Array.BYTES_PER_ELEMENT, 0);
			
			
			GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, EBO);
			GL.bufferData(GL.ELEMENT_ARRAY_BUFFER, indices.byteLength, indices, GL.DYNAMIC_DRAW);
		}
		
		
		var camera:Camera;
		for (cam in cameras)
		{
	
			camera = BeardGame.Get().cameras[cam];
			//trace(camera.name);
			GL.scissor(camera.viewport.x,BeardGame.Get().window.height - camera.viewport.y - camera.viewport.height, camera.viewport.width, camera.viewport.height);
			
			shader.SetMatrix4fv("view", camera.view);
			LightManager.Get().CompileLights(shader, this.lightGroup);
					
			GL.drawElements(drawMode, indices.length, GL.UNSIGNED_SHORT, 0);
			drawCount++;
			GLU.ShowErrors();
			
		}
			
		
		return drawCount;
	}
	
		

	
	function set_lightGroup(value:String):String 
	{
		return lightGroup = value;
	}
	
	
	
}