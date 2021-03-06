package beardFramework.graphics.lights;

import beardFramework.graphics.core.Renderer;
import beardFramework.interfaces.IRenderable;
import beardFramework.core.BeardGame;
import beardFramework.graphics.cameras.Camera;
import beardFramework.graphics.lights.LightManager;
import beardFramework.graphics.shaders.Shader;
import beardFramework.interfaces.IRenderable;
import beardFramework.resources.assets.AssetManager;
import beardFramework.utils.graphics.GLU;
import beardFramework.utils.libraries.StringLibrary;
import beardFramework.utils.simpleDataStruct.SRect;
import beardFramework.utils.simpleDataStruct.SVec2;
import beardFramework.utils.simpleDataStruct.SVec3;
import lime.graphics.opengl.GL;
import lime.graphics.opengl.GLBuffer;
import lime.graphics.opengl.GLTexture;
import lime.graphics.opengl.GLVertexArrayObject;
import lime.utils.Float32Array;
import lime.utils.UInt16Array;

/**
 * ...
 * @author Ludovic
 */
class Shadow implements IRenderable
{
	public static var shadowLength:Float = 1000;
	
	@:isVar public var name(get, set):String;
	@:isVar public var z(get, set):Float;
	@:isVar public var shader(get, set):Shader;
	
	public var isActivated(default, null):Bool;
	public var cameras:List<String>;
	public var lightGroup(default, set):String;
	public var x:Float;
	public var y:Float;
	public var width:Float;
	public var height:Float;
	public var rotation:Float;
	public var renderer:Renderer;
	public var drawMode:Int = GL.TRIANGLES;
	public var corner1:SVec2;
	public var corner2:SVec2;
	public var lightPos:SVec3;
		
	@:isVar public var group(get, set):String;
	@:isVar public var depth(get, set):Float;
	/**
	 * x: top, y: bottom, width : left, height: right
	 */
	public var limits:SRect; 
	//public var texture:GLTexture;
	
	private static var verticesData:Float32Array; //overide with local variable if necessary
	private static var indices:UInt16Array;
	private static var VBO:GLBuffer;
	private static var EBO:GLBuffer;
	private static var VAO:GLVertexArrayObject;
	
	
	public function new() 
	{
		x = 0;
		y = 0;
		z = 0;
		width = 1;
		height = 1;
		
		corner1 = {x:0, y:0};
		corner2 = {x:0, y:0};
		lightPos = {x:0, y:0, z:0};
		limits = {x:0, y:0, width:0, height:0};
		renderer = Renderer.Get();
		shader = Shader.GetShader(StringLibrary.SHADOW);
		shader.Use();
		shader.SetMatrix4fv(StringLibrary.PROJECTION, renderer.projection);
		canRender = true;
		if (VAO == null || VBO == null)
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
			
			GL.bufferData(GL.ARRAY_BUFFER, verticesData.byteLength, verticesData, GL.DYNAMIC_DRAW);
			
			indices = new UInt16Array([0, 1, 2, 2, 3, 0]);
			
			EBO  = Renderer.Get().GenerateBuffer();
			
			GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, EBO);
			GL.bufferData(GL.ELEMENT_ARRAY_BUFFER, indices.byteLength, indices, GL.DYNAMIC_DRAW);
			
			
			GL.bindBuffer(GL.ARRAY_BUFFER, 0);
			GL.bindVertexArray(0);
		}
		
		
		
	}
	
	
	/* INTERFACE beardFramework.interfaces.IRenderable */
	
	
	
	function get_name():String 
	{
		return name;
	}
	
	function set_name(value:String):String 
	{
		return name = value;
	}
	
	
	
	function get_z():Float 
	{
		return z;
	}
	
	function set_z(value:Float):Float 
	{
		return z = value;
	}
	
	public function Activate():Void 
	{
		isActivated = true;
		
	}
	
	public function DeActivate():Void 
	{
		isActivated = false;
		canRender = false;
	}
	
	
		
		
	function set_lightGroup(value:String):String 
	{
		return lightGroup = value;
	}
	
	public function Render(camera:Camera):Int 
	{
		
		if (shader == null) return 1;
		
		
		shader.Use();
		
		renderer.model.identity();
		renderer.model.appendScale(width, this.height, 1.0);
		renderer.model.appendTranslation(this.x, this.y,this.depth);
		renderer.model.appendRotation(this.rotation, renderer.rotationAxis);
		shader.SetMatrix4fv(StringLibrary.MODEL, renderer.model);
		shader.SetMatrix4fv(StringLibrary.VIEW, camera.view);
		shader.SetMatrix4fv(StringLibrary.PROJECTION, renderer.projection);
		
		shader.Set2Float("corner1Pos", corner1.x, corner1.y); 
		shader.Set2Float("corner2Pos", corner2.x, corner2.y); 
		shader.Set4Float("limits", limits.x,limits.y, limits.width,limits.height);
		
		//trace(shadowPointID);
		shader.Set3Float("lightPos", lightPos.x, lightPos.y, lightPos.z);
		shader.SetInt("useModel", 1);
		shader.SetFloat("shadowLength",shadowLength); 
		if (renderer.boundBuffer != VBO){
		
			shader.Use();
			
			GL.bindBuffer(GL.ARRAY_BUFFER, VBO);
			renderer.boundBuffer = VBO;
			
			GL.enableVertexAttribArray(0);
			GL.vertexAttribPointer(0, 3, GL.FLOAT, false, 3 * Float32Array.BYTES_PER_ELEMENT, 0);
					
			GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, EBO);
			GL.bufferData(GL.ELEMENT_ARRAY_BUFFER, indices.byteLength, indices, GL.DYNAMIC_DRAW);
		}
		
		//if (texture != null){
			//GL.activeTexture( GL.TEXTURE0 + AssetManager.Get().GetFreeTextureUnit());
			//shader.SetInt("sampler", 0);	
			//GL.bindTexture(GL.TEXTURE_2D, texture);
		//}

		GL.drawElements(drawMode, indices.length, GL.UNSIGNED_SHORT, 0);
		GLU.ShowErrors();
		
		return 1;
		
	}
	
	public inline function HasCamera(camera:String):Bool 
	{
		var result:Bool = true;
		//
		//for (name in cameras)
			//if (name == camera)
			//{
				//result = true;
				//break;
			//}
		
		return result;
	}
		
	public function Destroy():Void 
	{
		
	}
	
	
	
	function get_group():String 
	{
		return group;
	}
	
	function set_group(value:String):String 
	{
		return group = value;
	}
	
	
	/* INTERFACE beardFramework.interfaces.IRenderable */
	
	
	
	function get_depth():Float 
	{
		return depth;
	}
	
	function set_depth(value:Float):Float 
	{
		return depth = value;
	}
	
	@:isVar public var canRender(get, set):Bool;
	
	function get_canRender():Bool 
	{
		return canRender;
	}
	
	function set_canRender(value:Bool):Bool 
	{
		return canRender = value;
	}
	
	function get_shader():Shader 
	{
		return shader;
	}
	
	function set_shader(value:Shader):Shader 
	{
		return shader = value;
	}
	
}

