package beardFramework.graphics.rendering;

import beardFramework.core.BeardGame;
import beardFramework.graphics.cameras.Camera;
import beardFramework.graphics.rendering.lights.LightManager;
import beardFramework.graphics.rendering.shaders.Shader;
import beardFramework.interfaces.IRenderable;
import beardFramework.resources.assets.AssetManager;
import beardFramework.utils.graphics.GLU;
import beardFramework.utils.libraries.StringLibrary;
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
class FrameBufferQuad
{
	public var x:Float;
	public var y:Float;
	public var z:Float;
	public var width:Int;
	public var height:Int;
	public var rotation:Float;
	public var renderer:Renderer;
	public var drawMode:Int = GL.LINE_LOOP;
	public var texture:GLTexture;
	public var shader(default, null):Shader;
	
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
		
		renderer = Renderer.Get();
		shader = Shader.GetShader("frame");
		
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
	
	public function Render():Void 
	{
		
		
		if (shader == null) return;
		
		
		shader.Use();
		
		renderer.model.identity();
		renderer.model.appendScale(this.width, this.height, 1.0);
		renderer.model.appendTranslation(this.x, this.y, this.z);
		renderer.model.appendRotation(this.rotation, renderer.rotationAxis);
		shader.SetMatrix4fv(StringLibrary.MODEL, renderer.model);
	
		
		if (renderer.boundBuffer != VBO){
		
			shader.Use();
			
			GL.bindBuffer(GL.ARRAY_BUFFER, VBO);
			renderer.boundBuffer = VBO;
			
			GL.enableVertexAttribArray(0);
			GL.vertexAttribPointer(0, 3, GL.FLOAT, false, 3 * Float32Array.BYTES_PER_ELEMENT, 0);
					
			GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, EBO);
			GL.bufferData(GL.ELEMENT_ARRAY_BUFFER, indices.byteLength, indices, GL.DYNAMIC_DRAW);
		}
		
		if (texture != null){
			GL.activeTexture( GL.TEXTURE0 + AssetManager.Get().GetFreeTextureUnit());
			shader.SetInt("sampler", AssetManager.Get().GetFreeTextureUnit());	
			GL.bindTexture(GL.TEXTURE_2D, texture);
		}

		GL.drawElements(drawMode, indices.length, GL.UNSIGNED_SHORT, 0);
		GLU.ShowErrors();
		
	}
	
}