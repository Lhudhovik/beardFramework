package beardFramework.display.rendering;
import beardFramework.core.BeardGame;
import beardFramework.display.cameras.Camera;
import beardFramework.display.core.BeardLayer;
import beardFramework.display.core.BeardLayer.BeardLayerType;
import beardFramework.display.rendering.vertexData.RenderedDataBufferArray;
import beardFramework.resources.assets.AssetManager;
import beardFramework.utils.DataUtils;
import haxe.ds.Vector;
import lime.app.Application;
import lime.graphics.opengl.GL;
import lime.graphics.opengl.GLBuffer;
import lime.graphics.opengl.GLProgram;
import lime.graphics.opengl.GLShader;
import lime.graphics.opengl.GLTexture;
import lime.graphics.opengl.GLVertexArrayObject;
import lime.math.Matrix4;
import lime.math.Vector4;
import lime.text.Font;
import lime.utils.Float32Array;
import lime.utils.UInt16Array;
import openfl.display.BitmapData;

@:access(lime.graphics.opengl.GL.GLObject)
/**
 * ...
 * @author 
 */
class DefaultRenderer 
{
	private static var VAOCOUNT:Int = 1;
	private static var BUFFERCOUNT:Int = 1;
	private static var FREETEXTUREINDEX:Int = 0;
	private static var ATTRIBUTEPOINTER:Int = 0;


	public var drawCount(default, null):Int = 0;
	private var quadVertices:Float32Array;
	private var verticesIndices:UInt16Array;	
	
	private var EBO:GLBuffer;
	private var VBO:GLBuffer;
	private var VAO:GLVertexArrayObject;
	private var TBO:GLBuffer;
	public static var shaderProgram:GLProgram;
	private var ready:Bool = false;
	public var projection:Matrix4;
	private var model:Matrix4;
	public var view:Matrix4;
	private var fragmentShader:String = "fragmentShader";
	private var vertexShader:String="vertexShader";
	
	
	private var bufferIndices:Array<Bool>;
	private var renderedData:RenderedDataBufferArray;
	private var utilFloatArray:Float32Array;
	
	
	private function new()
	{
		
	}
	
	
	private function Init():Void
	{
		
		
		Application.current.window.onResize.add(OnResize);
		
		GL.enable(GL.DEPTH_TEST);
		GL.enable(GL.BLEND);
		GL.blendFunc(GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA); 
		GL.enable(GL.SCISSOR_TEST);
		
		GL.viewport(0, 0, Application.current.window.width, Application.current.window.height);
		
		projection = new Matrix4();
		projection.identity();
		projection.createOrtho( 0, Application.current.window.width, Application.current.window.height, 0, -1, 1);
		view = new Matrix4();
		model = new Matrix4();
			
		InitShaders();
		InitVertices();
		InitBuffers();		
		
		renderedData = new RenderedDataBufferArray();
		bufferIndices = new Array<Bool>();
		
		
	}
	
	public function Render():Void
	{
		if (ready)
		{
			
			drawCount = 0;
			
		
			for (camera in BeardGame.Get().cameras)
			{
				
				
				
				
				GL.clearColor(0.2, 0.3, 0.3, 1);
				GL.clear(GL.COLOR_BUFFER_BIT);
				GL.clear(GL.DEPTH_BUFFER_BIT);
				
				GL.scissor(camera.viewport.x,Application.current.window.height - camera.viewport.y - camera.viewport.height, camera.viewport.width, camera.viewport.height);
				
				
				view.identity();
				view.appendScale(camera.zoom, camera.zoom,0);
				view.appendTranslation( -(camera.centerX - camera.viewportWidth * 0.5), -(camera.centerY - camera.viewportHeight * 0.5), 0);
				
				GL.uniformMatrix4fv(GL.getUniformLocation(shaderProgram, "view"), 1, false, view);
			
				GL.useProgram(shaderProgram);
				GL.bindVertexArray(VAO);
				if (renderedData.visualsCount > 0){
					GL.drawElements(GL.TRIANGLES,verticesIndices.length,GL.UNSIGNED_SHORT,0);
					drawCount++;
				}
						
				GL.bindVertexArray(0);
				
				var error:Int = GL.getError();
				
				if (error != 0)
					trace(error);
				
			}
			
		}
		

			
	}
	
	public function GetFreeTextureIndex():Int{
		return FREETEXTUREINDEX;
	}
	
	public function AssociateFreeTextureIndex():Int
	{
		var index:Int = FREETEXTUREINDEX;
		FREETEXTUREINDEX++;
		
		return index;
	}
	
	public function UpdateTexture(index:Int = 0):Void
	{
		GL.useProgram(shaderProgram);
		GL.uniform1i(GL.getUniformLocation(shaderProgram, "atlas[" + index + "]"), index);
	}
	
	public inline function InitShaders():Void
	{
		if (shaderProgram == null)
		{
			
		
		Shaders.LoadShaders();
		
		var vShader:GLShader = GL.createShader(GL.VERTEX_SHADER);
		GL.shaderSource(vShader, Shaders.shader[vertexShader]);
		GL.compileShader(vShader);
		trace(GL.getShaderInfoLog(vShader));
		
		var fShader:GLShader = GL.createShader(GL.FRAGMENT_SHADER);
		GL.shaderSource(fShader, Shaders.shader[fragmentShader]);
		GL.compileShader(fShader);
		trace(GL.getShaderInfoLog(fShader));
		
		
		shaderProgram = GL.createProgram();
		GL.attachShader(shaderProgram, vShader);
		GL.attachShader(shaderProgram, fShader);
		GL.linkProgram(shaderProgram);
		trace(GL.getProgramInfoLog(shaderProgram));
		
		GL.deleteShader(vShader);
		GL.deleteShader(fShader);
		
		GL.useProgram(shaderProgram);
		GL.uniformMatrix4fv(GL.getUniformLocation(shaderProgram, "projection"), 1, false, projection);
		GL.uniformMatrix4fv(GL.getUniformLocation(shaderProgram, "model"), 1, false, model);
		GL.uniformMatrix4fv(GL.getUniformLocation(shaderProgram, "view"), 1, false, view);
		}
	}
	
	public inline function InitVertices():Void
	{
	
		quadVertices = new Float32Array(null, [ 
		//x		y	 	uvX		uvY	new uv
		0,		1,		0.0,	1.0,
        1, 		1, 		1.0,	1.0,
        1, 		0,		1.0,    0.0,
        0,		0,		0.0,	0.0
		]);	
		
		
		verticesIndices = new UInt16Array([0, 1, 2, 2, 3, 0]);
		
		//GL.uniform1fv(GL.getUniformLocation(shaderProgram, "quadVertices"),1,quadVertices);
		
	}
	
	public  function InitBuffers():Void
	{
		
		VAO = GLObject.fromInt(GLObjectType.VERTEX_ARRAY_OBJECT, VAOCOUNT++);
		VBO = GLObject.fromInt(GLObjectType.BUFFER, BUFFERCOUNT++);
		EBO = GLObject.fromInt(GLObjectType.BUFFER, BUFFERCOUNT++);
	
		GL.bindVertexArray(VAO);
		
		GL.bindBuffer(GL.ARRAY_BUFFER, VBO);
				
		GL.enableVertexAttribArray(ATTRIBUTEPOINTER);
		GL.vertexAttribPointer(ATTRIBUTEPOINTER, 3, GL.FLOAT, false, 10 * Float32Array.BYTES_PER_ELEMENT, 0);
		GL.bindAttribLocation(shaderProgram, ATTRIBUTEPOINTER++, "pos");
		
		GL.enableVertexAttribArray(ATTRIBUTEPOINTER);
		GL.vertexAttribPointer(ATTRIBUTEPOINTER, 3, GL.FLOAT, false, 10 * Float32Array.BYTES_PER_ELEMENT, 3* Float32Array.BYTES_PER_ELEMENT);
		GL.bindAttribLocation(shaderProgram, ATTRIBUTEPOINTER++, "uv");
		
		GL.enableVertexAttribArray(ATTRIBUTEPOINTER);
		GL.vertexAttribPointer(ATTRIBUTEPOINTER, 4, GL.FLOAT, false, 10 * Float32Array.BYTES_PER_ELEMENT, 6 * Float32Array.BYTES_PER_ELEMENT);
		GL.bindAttribLocation(shaderProgram, ATTRIBUTEPOINTER++, "color");
		
		GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, EBO);
		GL.bufferData(GL.ELEMENT_ARRAY_BUFFER,verticesIndices.byteLength, verticesIndices, GL.DYNAMIC_DRAW);
		
		GL.bindBuffer(GL.ARRAY_BUFFER, 0);
		GL.bindVertexArray(0);
	}
		
	public function Start():Void
	{
		ready = true;
		//BeardGame.Get().onWindowResize(Application.current.window.width, Application.current.window.height);
		OnResize(Application.current.window.width, Application.current.window.height);
		
		
	}
	
	public function OnResize(width:Int, height:Int):Void
	{
		GL.viewport(0, 0, Application.current.window.width, Application.current.window.height);
		projection.identity();
		projection.createOrtho( 0,Application.current.window.width, Application.current.window.height, 0, -1, 1);
		//projection = Matrix4.createOrtho( 0,Application.current.window.width, Application.current.window.height, 0, -1, 1);
		GL.uniformMatrix4fv(GL.getUniformLocation(shaderProgram, "projection"), 1, false, projection);
		
		
	}
	
	public function AllocateBufferIndex():Int
	{
		var index:Int = -1;
		var length:Int = bufferIndices.length;
		
		for (i in 0...length)
			if (bufferIndices[i] == false)
			{
				bufferIndices[i] = true;
				index = i;
				break;
			}
		
		if (index == -1)
		{
			bufferIndices.push(true);
			index = length;
		}
		
		return index;
		
	}
	
	public function AllocateBufferIndices(count:Int):Array<Int>
	{
		var indices:Array<Int>=new Array();
		var length:Int = bufferIndices.length;
		
		for (i in 0...length)
			if (bufferIndices[i] == false)
			{
				bufferIndices[i] = true;
				indices.push(i);
				count--;
				
				if (count == 0) break;
			}
		
		while (count-- > 0)
		{
			bufferIndices.push(true);
			indices.push(length++);
		}
		
		return indices;
		
	}
	
	public function GetFreeBufferIndex():Int
	{
		var index:Int = -1;
		var length:Int = bufferIndices.length;
		
		for (i in 0...length)
			if (bufferIndices[i] == false)
			{
				index = i;
				break;
			}
		
		return index;
		
	}
	
	public inline function FreeBufferIndex(index:Int):Int
	{
		
		if (index < bufferIndices.length)
			bufferIndices[index] = false;
			
		return -1;
		
	}
	
	public inline function GetHigherIndex():Int
	{
		return bufferIndices.length - 1;
	}
	
}