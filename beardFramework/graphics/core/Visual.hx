package beardFramework.graphics.core;
import beardFramework.graphics.rendering.Renderer;
import beardFramework.graphics.rendering.RenderingData;
import beardFramework.graphics.rendering.Shaders;
import beardFramework.graphics.rendering.vertexData.RenderedDataBufferArray;
import beardFramework.graphics.rendering.vertexData.VertexAttribute;
import beardFramework.interfaces.IRenderable;
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
	private static var vertices:Vector<Float>; //overide with local variable if necessary
	private static var indices:UInt16Array;
	
	@:isVar public var readyForRendering(get, null):Bool;
	
	public var shaderProgram(default, null):GLProgram;
	public var cameras:List<String>;
	public var drawMode:Int;
	
	
	private var vertexAttributes:Vector<VertexAttribute>;
	private var EBO:GLBuffer;
	private var VBO:GLBuffer;
	private var VAO:GLVertexArrayObject;
	private var verticesData:Float32Array;
	private var renderer:Renderer;
	
	
	
	public function new(texture:String, atlas:String, name:String="") 
	{
		super(texture, atlas, name);
		if (vertices == null) vertices = Vector.fromArrayCopy([
		0, 1, 0.0, 1.0,
		1, 1, 1.0, 1.0,
		1, 0, 1.0, 0.0,
		0, 0, 0.0, 0.0]);
		
		if (indices == null) indices = new UInt16Array([0,1,2,2,3,0]);
	}
	
	public function InitGraphics(data:RenderingData):Void
	{
		
		renderer = Renderer.Get();
		drawMode = data.drawMode;
		verticesData = new Float32Array(data.vertexStride*4);
		
		InitShaders(data.shaders);
		InitBuffers(data.vertexAttributes, data.vertexStride);
		
		cameras = new List();
		
		for (camera in BeardGame.Get().cameras)
			cameras.add(camera.name);
	}
	
		
	public function InitShaders(shadersList:Array<Shaders.Shader>):Void
	{
		var createdShaders:Array<GLShader> = [];
		for (shader in shadersList)
		{
			
			var glShader:GLShader =  GL.createShader(shader.type);
			
			GL.shaderSource(glShader, Shaders.shader[shader.name]);
			
			GL.compileShader(glShader);
			trace(shader.name + " :\n" + GL.getShaderInfoLog(glShader));
			
			createdShaders.push(glShader);
			
		}
			
		if (shaderProgram == null) shaderProgram = GL.createProgram();
		trace(GL.getProgramInfoLog(shaderProgram ));
		
		for (shader in createdShaders)
		{
			GL.attachShader(shaderProgram, shader);
			trace(GL.getProgramInfoLog(shaderProgram ));
		}
		
		
		GL.linkProgram(shaderProgram);
		trace(GL.getProgramInfoLog(shaderProgram ));

		for (shader in createdShaders)
		{
			GL.deleteShader(shader);
		}
		
		
		GL.useProgram(shaderProgram);trace(GL.getError());
		GL.uniformMatrix4fv(GL.getUniformLocation(shaderProgram , "projection"), 1, false, renderer.projection);
		//GL.uniformMatrix4fv(GL.getUniformLocation(shaderProgram , "model"), 1, false, renderer.model);
		GL.uniformMatrix4fv(GL.getUniformLocation(shaderProgram , "view"), 1, false, renderer.view);
		
		//todefine
		for (i in 0...renderer.GetFreeTextureIndex())
		{
			GL.activeTexture(GL.TEXTURE0 + i);
			GL.uniform1i(GL.getUniformLocation(shaderProgram , "atlas[" + i + "]"), i);
		}
		
	
		
	}
	
	public function InitBuffers(attributes:Array<VertexAttribute> = null, vertexStride:Int = 0):Void
	{
		VAO = renderer.GenerateVAO();
		//trace(VAOs);
		GL.bindVertexArray(VAO);
		
		VBO = renderer.GenerateBuffer();
		GL.bindBuffer(GL.ARRAY_BUFFER, VBO);
			
		
		if (attributes != null && attributes.length > 0){
				
			vertexAttributes =  Vector.fromArrayCopy(attributes);
			var stride:Int = 0;
			for (attribute in attributes)
			{
				GL.enableVertexAttribArray(attribute.index);
				GL.vertexAttribPointer(attribute.index, attribute.size, GL.FLOAT, false, vertexStride * Float32Array.BYTES_PER_ELEMENT, stride  * Float32Array.BYTES_PER_ELEMENT );
				GL.bindAttribLocation(shaderProgram, attribute.index, attribute.name);
				stride+= attribute.size;
			}
			
		}
		else{
			vertexAttributes = new Vector(1);
			GL.enableVertexAttribArray(0);
			GL.vertexAttribPointer(0, 3, GL.FLOAT, false, 3 * Float32Array.BYTES_PER_ELEMENT, 0);
			GL.bindAttribLocation(shaderProgram, 0, "pos");
			vertexAttributes[0] = { name:"pos", size:3, index:0};
		}
			
		
		if (indicesData.length > 0)
		{
			EBO  = renderer.GenerateBuffer();
		
			GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, EBO);
			GL.bufferData(GL.ELEMENT_ARRAY_BUFFER, indicesData.byteLength, indicesData, GL.DYNAMIC_DRAW);
		}
	
		
		GL.bindBuffer(GL.ARRAY_BUFFER, 0);
		GL.bindVertexArray(0);
		
	}
	
	
	
	function get_readyForRendering():Bool 
	{
		return readyForRendering;
	}
		
	public function Render():Int 
	{
		
	}
	
	
	
}