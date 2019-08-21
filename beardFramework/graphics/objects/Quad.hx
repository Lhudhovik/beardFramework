package beardFramework.graphics.objects;

import beardFramework.core.BeardGame;
import beardFramework.graphics.cameras.Camera;
import beardFramework.graphics.core.Renderer;
import beardFramework.graphics.lights.LightManager;
import beardFramework.graphics.shaders.Shader;
import beardFramework.interfaces.IRenderable;
import beardFramework.interfaces.ISpatialized;
import beardFramework.resources.assets.AssetManager;
import beardFramework.resources.options.GraphicSettings;
import beardFramework.utils.graphics.Color;
import beardFramework.utils.graphics.GLU;
import beardFramework.utils.libraries.StringLibrary;
import beardFramework.utils.simpleDataStruct.SRect;
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
class Quad extends GraphicsObject
{
	
	public var renderer:Renderer;
	public var drawMode:Int = GL.TRIANGLES;
	public var texture:GLTexture;
	public var shader:Shader;
	public var uvs:SRect;
	public var reverse:Bool;
	public var alpha:Float;
	public var color:Color;
	private static var verticesData:Float32Array; //overide with local variable if necessary
	private static var indices:UInt16Array;
	private static var VBO:GLBuffer;
	private static var EBO:GLBuffer;
	private static var VAO:GLVertexArrayObject;
	
	public function new(shaderName:String = StringLibrary.QUAD) 
	{
		x = 0;
		y = 0;
		z = 0;
		width = 1;
		height = 1;
		alpha = 1;
		color = Color.WHITE;
		reverse = true;
		uvs = {x:0, y:0, width:0, height:0};
		renderer = Renderer.Get();
		this.shader = Shader.GetShader(shaderName);
		shader.Use();
		shader.SetMatrix4fv(StringLibrary.PROJECTION, renderer.projection);
		
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
		renderer.model.appendScale(width, this.height, 1.0);
		renderer.model.appendTranslation(this.x, this.y,1);
		renderer.model.appendRotation(this.rotation, renderer.rotationAxis);
		shader.SetMatrix4fv(StringLibrary.MODEL, renderer.model);
		shader.SetFloat(StringLibrary.EXPOSURE, GraphicSettings.exposure);
		shader.SetFloat(StringLibrary.GAMMA, GraphicSettings.gamma);
		shader.Set4Float(StringLibrary.UVS, uvs.x, uvs.y, uvs.width, uvs.height);
		shader.SetFloat(StringLibrary.TRANSPARENCY, alpha);
		shader.Set3Float(StringLibrary.COLOR, color.getRedf(), color.getGreenf(), color.getBluef());
		shader.SetInt("reverse", this.reverse ? 1:0);
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