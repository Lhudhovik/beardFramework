package beardFramework.display.rendering;
import beardFramework.core.BeardGame;
import beardFramework.display.cameras.Camera;
import beardFramework.display.core.BeardLayer;
import beardFramework.display.core.BeardLayer.BeardLayerType;
import beardFramework.display.rendering.vertexData.VisualDataBufferArray;
import beardFramework.resources.assets.AssetManager;
import beardFramework.utils.DataUtils;
import haxe.ds.Vector;
import lime.app.Application;
import lime.graphics.opengl.GL;
import lime.graphics.opengl.GLBuffer;
import lime.graphics.opengl.GLES3Context;
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
/**
 * ...
 * @author 
 */
class DefaultRenderer 
{
	private static var VAOCOUNT:Int = 1;
	private static var BUFFERCOUNT:Int = 1;


	public var drawCount(default, null):Int = 0;
	public var context:GLES3Context;
	private var quadVertices:Float32Array;
	private var verticesIndices:UInt16Array;	
	
	private var EBO:GLBuffer;
	private var VBO:GLBuffer;
	private var VAO:GLVertexArrayObject;
	private var TBO:GLBuffer;
	public var shaderProgram:GLProgram;
	private var ready:Bool = false;
	private var projection:Matrix4;
	private var model:Matrix4;
	private var view:Matrix4;
	private var fragmentShader:String = "fragmentShader";
	private var vertexShader:String="vertexShader";
	
	
	private var bufferIndices:Array<Bool>;
	private var visualData:VisualDataBufferArray;
	private var utilFloatArray:Float32Array;
	
	
	private function new()
	{
		
	}
	
	
	private function Init():Void
	{
		
		
		Application.current.window.onResize.add(OnResize);
		
		context = GL.context;
		
		context.enable(context.DEPTH_TEST);
		context.enable(context.SCISSOR_TEST);
		
		context.viewport(0, 0, Application.current.window.width, Application.current.window.height);
		
		projection = Matrix4.createOrtho( 0, Application.current.window.width, Application.current.window.height, 0, -1, 1);
		view = new Matrix4();
		model = new Matrix4();
			
		InitShaders();
		InitVertices();
		InitBuffers();		
		
		visualData = new VisualDataBufferArray();
		bufferIndices = new Array<Bool>();
		
		
	}
	
	public function Render():Void
	{
		if (ready)
		{
			
			drawCount = 0;
			
		
			for (camera in BeardGame.Get().cameras)
			{
				
				context.scissor(camera.viewport.x,Application.current.window.height - camera.viewport.y - camera.viewport.height, camera.viewport.width, camera.viewport.height);
				
				context.clearColor(0.2, 0.3, 0.3, 1);
				context.clear(context.COLOR_BUFFER_BIT);
				context.clear(context.DEPTH_BUFFER_BIT);
				
				
				view.identity();
				view.appendScale(camera.zoom, camera.zoom,0);
				view.appendTranslation( -(camera.centerX - camera.viewportWidth * 0.5), -(camera.centerY - camera.viewportHeight * 0.5), 0);
				
				context.uniformMatrix4fv(context.getUniformLocation(shaderProgram, "view"), 1, false, view);
			
				context.useProgram(shaderProgram);
				context.bindVertexArray(VAO);
				context.drawElements(context.TRIANGLES,verticesIndices.length,context.UNSIGNED_SHORT,0);
				
				drawCount++;
		
				context.bindVertexArray(0);
				var error:Int = context.getError();
				if (error != 0)
					trace(error);
				
			}
			//var font: Font= Font.fromFile("assets/fonts/American Captain.ttf");
			//
			//var bitmap:BitmapData = BitmapData.fromImage(font.rendercontextyph(font.getcontextyph("a"), 50), true);
			//var text:contextTexture = bitmap.getTexture(context.context);
			//context.activeTexture(context.TEXTURE1);		
			//context.bindTexture(context.TEXTURE_2D, texture);
		//VisualRenderer.Get().ActivateTexture();
		//
		}
		

			
	}
	
	public function ActivateTexture():Void
	{
		//context.useProgram(shaderProgram);
		//context.uniform1i(context.getUniformLocation(shaderProgram, "atlas"), 0);
	}
	
	public inline function InitShaders():Void
	{
		Shaders.LoadShaders();
		
		var vShader:GLShader = context.createShader(context.VERTEX_SHADER);
		context.shaderSource(vShader, Shaders.shader[vertexShader]);
		context.compileShader(vShader);
		trace(context.getShaderInfoLog(vShader));
		
		var fShader:GLShader = context.createShader(context.FRAGMENT_SHADER);
		context.shaderSource(fShader, Shaders.shader[fragmentShader]);
		context.compileShader(fShader);
		trace(context.getShaderInfoLog(fShader));
		
		
		shaderProgram = context.createProgram();
		context.attachShader(shaderProgram, vShader);
		context.attachShader(shaderProgram, fShader);
		context.linkProgram(shaderProgram);
		trace(context.getProgramInfoLog(shaderProgram));
		
		context.deleteShader(vShader);
		context.deleteShader(fShader);
		
		context.useProgram(shaderProgram);
		context.uniformMatrix4fv(context.getUniformLocation(shaderProgram, "projection"), 1, false, projection);
		context.uniformMatrix4fv(context.getUniformLocation(shaderProgram, "model"), 1, false, model);
		context.uniformMatrix4fv(context.getUniformLocation(shaderProgram, "view"), 1, false, view);
		
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
		
		//context.uniform1fv(context.getUniformLocation(shaderProgram, "quadVertices"),1,quadVertices);
		
	}
	
	public inline function InitBuffers():Void
	{
		VAO = GLObject.fromInt(GLObjectType.VERTEX_ARRAY_OBJECT, VAOCOUNT++);
		VBO = GLObject.fromInt(GLObjectType.BUFFER, BUFFERCOUNT++);
		EBO = GLObject.fromInt(GLObjectType.BUFFER, BUFFERCOUNT++);
		TBO = GLObject.fromInt(GLObjectType.BUFFER, BUFFERCOUNT++);
		
		context.bindVertexArray(VAO);
		
		context.bindBuffer(context.ARRAY_BUFFER, VBO);
				
		context.enableVertexAttribArray(0);
		context.vertexAttribPointer(0, 3, context.FLOAT, false, 10 * Float32Array.BYTES_PER_ELEMENT, 0);
		context.bindAttribLocation(shaderProgram, 0, "pos");
		
		context.enableVertexAttribArray(1);
		context.vertexAttribPointer(1, 2, context.FLOAT, false, 10 * Float32Array.BYTES_PER_ELEMENT, 3* Float32Array.BYTES_PER_ELEMENT);
		context.bindAttribLocation(shaderProgram, 1, "uv");
		
		context.enableVertexAttribArray(2);
		context.vertexAttribPointer(2, 4, context.FLOAT, false, 10 * Float32Array.BYTES_PER_ELEMENT, 5 * Float32Array.BYTES_PER_ELEMENT);
		context.bindAttribLocation(shaderProgram, 2, "color");
		
		context.enableVertexAttribArray(3);
		context.vertexAttribPointer(3, 1, context.UNSIGNED_SHORT, false, 10 * Float32Array.BYTES_PER_ELEMENT, 9 * Float32Array.BYTES_PER_ELEMENT);
		context.bindAttribLocation(shaderProgram, 2, "textureIndex");
		
		
		context.bindBuffer(context.ELEMENT_ARRAY_BUFFER, EBO);
		context.bufferData(context.ELEMENT_ARRAY_BUFFER,verticesIndices.byteLength, verticesIndices, context.DYNAMIC_DRAW);
		
	
		context.bindBuffer(context.ARRAY_BUFFER, 0);
		context.bindVertexArray(0);
	}
	
	
	
	public function Start():Void
	{
		ready = true;
		OnResize(Application.current.window.width, Application.current.window.height);
	}
	
	public function OnResize(width:Int, height:Int):Void
	{
		context.viewport(0, 0, Application.current.window.width, Application.current.window.height);
		projection = Matrix4.createOrtho( 0,Application.current.window.width, Application.current.window.height, 0, -1, 1);
		context.uniformMatrix4fv(context.getUniformLocation(shaderProgram, "projection"), 1, false, projection);
		
		
	}
	
	public function GetFreeBufferIndex():Int
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