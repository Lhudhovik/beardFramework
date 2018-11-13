package beardFramework.display.rendering;
import beardFramework.core.BeardGame;
import beardFramework.display.cameras.Camera;
import beardFramework.display.core.BeardLayer;
import beardFramework.display.core.BeardLayer.BeardLayerType;
import beardFramework.display.core.Visual;
import beardFramework.display.rendering.vertexData.VisualDataBufferArray;
import beardFramework.resources.assets.AssetManager;
import beardFramework.utils.DataUtils;
import haxe.ds.Vector;
import lime.app.Application;
import lime.graphics.opengl.GL;
import lime.graphics.opengl.GLBuffer;
import lime.graphics.opengl.GLProgram;
import lime.graphics.opengl.GLShader;
import lime.graphics.opengl.GLVertexArrayObject;
import lime.math.Matrix4;
import lime.math.Vector4;
import lime.utils.Float32Array;
import lime.utils.UInt16Array;



@:access(lime.graphics.opengl.GL)
/**
 * ...
 * @author 
 */
class VisualRenderer 
{
	
	private static var instance:VisualRenderer;

	public var drawCount(default, null):Int = 0;
	
	private var quadVertices:Float32Array;
	private var verticesIndices:UInt16Array;	
	
	private var EBO:GLBuffer;
	private var VBO:GLBuffer;
	private var VAO:GLVertexArrayObject;
	private var TBO:GLBuffer;
	private var shaderProgram:GLProgram;
	private var ready:Bool = false;
	private var projection:Matrix4;
	private var model:Matrix4;
	private var view:Matrix4;
	
	private var bufferIndices:Array<Bool>;
	private var visualData:VisualDataBufferArray;
	private var utilFloatArray:Float32Array;
	
	
	private function new()
	{
		
	}
	
	public static inline function Get():VisualRenderer
	{
		if (instance == null)
		{
			instance = new VisualRenderer();
			instance.Init();
		}
		
		return instance;
	}
	
	private function Init():Void
	{
		
		Application.current.window.onResize.add(OnResize);
		
		GL.enable(GL.DEPTH_TEST);
		GL.enable(GL.SCISSOR_TEST);
		
		GL.viewport(0, 0, Application.current.window.width, Application.current.window.height);
		
		projection = new Matrix4();
		projection.createOrtho( 0, Application.current.window.width, Application.current.window.height, 0, -1, 1);
		view = new Matrix4();
		model = new Matrix4();
		
		
		InitShaders();
		InitVertices();
		InitBuffers();		
		
		visualData = new VisualDataBufferArray();
		bufferIndices = new Array<Bool>();
		//utilCam = new Vector4();
		//utilTarget =new Vector4();
		//utilUp = new Vector4();
	}
	
	public function Render():Void
	{
		if (ready)
		{
			
			drawCount = 0;
			
		
			for (camera in BeardGame.Get().cameras)
			{
				
				GL.scissor(camera.viewport.x,Application.current.window.height - camera.viewport.y - camera.viewport.height, camera.viewport.width, camera.viewport.height);
				
				GL.clearColor(0.2, 0.3, 0.3, 1);
				GL.clear(GL.COLOR_BUFFER_BIT);
				GL.clear(GL.DEPTH_BUFFER_BIT);
				
				
				view.identity();
				view.appendScale(camera.zoom, camera.zoom,0);
				view.appendTranslation( -(camera.centerX - camera.viewportWidth * 0.5), -(camera.centerY - camera.viewportHeight * 0.5), 0);
				
				GL.uniformMatrix4fv(GL.getUniformLocation(shaderProgram, "view"), 1, false, view);
			
				GL.useProgram(shaderProgram);
				GL.bindVertexArray(VAO);
				GL.drawElements(GL.TRIANGLES,verticesIndices.length,GL.UNSIGNED_SHORT,0);
				
				drawCount++;
		
				GL.bindVertexArray(0);
				var error:Int = GL.getError();
				if (error != 0)
					trace(error);
				
			}
			
			
		}
		

			
	}
	
	public inline function ActivateTexture():Void
	{
		GL.useProgram(shaderProgram);
		GL.uniform1i(GL.getUniformLocation(shaderProgram, "atlas"), 0);
	}
	
	public inline function InitShaders():Void
	{
		Shaders.LoadShaders();
		
		var vShader:GLShader = GL.createShader(GL.VERTEX_SHADER);
		GL.shaderSource(vShader, Shaders.shader["vertexShader"]);
		GL.compileShader(vShader);
		trace(GL.getShaderInfoLog(vShader));
		
		var fShader:GLShader = GL.createShader(GL.FRAGMENT_SHADER);
		GL.shaderSource(fShader, Shaders.shader["fragmentShader"]);
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
	
	public inline function InitBuffers():Void
	{
		VAO = GLObject.fromInt(GLObjectType.VERTEX_ARRAY_OBJECT, 1);
		VBO = GLObject.fromInt(GLObjectType.BUFFER, 1);
		EBO = GLObject.fromInt(GLObjectType.BUFFER, 2);
		TBO = GLObject.fromInt(GLObjectType.BUFFER, 3);
		
		GL.bindVertexArray(VAO);
		
		GL.bindBuffer(GL.ARRAY_BUFFER, VBO);
				
		GL.enableVertexAttribArray(0);
		GL.vertexAttribPointer(0, 3, GL.FLOAT, false, 10 * Float32Array.BYTES_PER_ELEMENT, 0);
		GL.bindAttribLocation(shaderProgram, 0, "pos");
		
		GL.enableVertexAttribArray(1);
		GL.vertexAttribPointer(1, 2, GL.FLOAT, false, 10 * Float32Array.BYTES_PER_ELEMENT, 3* Float32Array.BYTES_PER_ELEMENT);
		GL.bindAttribLocation(shaderProgram, 1, "uv");
		
		GL.enableVertexAttribArray(2);
		GL.vertexAttribPointer(2, 4, GL.FLOAT, false, 10 * Float32Array.BYTES_PER_ELEMENT, 5 * Float32Array.BYTES_PER_ELEMENT);
		GL.bindAttribLocation(shaderProgram, 2, "color");
		
		GL.enableVertexAttribArray(3);
		GL.vertexAttribPointer(3, 1, GL.UNSIGNED_SHORT, false, 10 * Float32Array.BYTES_PER_ELEMENT, 9 * Float32Array.BYTES_PER_ELEMENT);
		GL.bindAttribLocation(shaderProgram, 2, "atlasIndex");
		
		
		GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, EBO);
		GL.bufferData(GL.ELEMENT_ARRAY_BUFFER,verticesIndices.byteLength, verticesIndices, GL.DYNAMIC_DRAW);
		
	
		GL.bindBuffer(GL.ARRAY_BUFFER, 0);
		GL.bindVertexArray(0);
	}
	
	public function UpdateBufferFromVisuals(visuals:Array<Visual>):Void
	{
		
		if (visuals == null || visuals.length == 0) return;
		
		var verIndex:Int = 0;
		var attIndex:Int = 0;
		var visIndex:Int = 0;
		
		GL.bindVertexArray(VAO);
	
		
		//enlarge the buffer data if too small	
		if (GetHigherIndex()  >= visualData.visualsCount)
		{
			var newBufferData:Float32Array = new Float32Array(40 * (GetHigherIndex()+1));
			
			if(visualData.visualsCount > 0)
				for (i in 0...visualData.data.length)
					newBufferData[i] = visualData.data[i];
		
			visualData.data = newBufferData;

			verticesIndices = new UInt16Array(6 * (GetHigherIndex() + 1));
			
			for (i in 0...Math.round(verticesIndices.length / 6)){
				attIndex = i * 6 ;
				verticesIndices[attIndex] 	= 0 + i*4;
				verticesIndices[attIndex+1] = 1 + i*4;
				verticesIndices[attIndex+2] = 2	+ i*4;
				verticesIndices[attIndex+3] = 2 + i*4;
				verticesIndices[attIndex+4] = 3	+ i*4;
				verticesIndices[attIndex+5] = 0 + i*4;
				
			}
			
			GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, EBO);
			GL.bufferData(GL.ELEMENT_ARRAY_BUFFER,verticesIndices.byteLength, verticesIndices, GL.DYNAMIC_DRAW);
			
			GL.bindBuffer(GL.ARRAY_BUFFER, VBO);
			GL.bufferData(GL.ARRAY_BUFFER, visualData.data.byteLength, visualData.data, GL.DYNAMIC_DRAW);
				
			
			GL.bindBuffer(GL.ARRAY_BUFFER, 0);
		}
		
		
		GL.bindBuffer(GL.ARRAY_BUFFER, VBO);
		
		if (utilFloatArray == null) utilFloatArray = new Float32Array(40);
		
		
		//Update data
		for (visual in visuals)
		{
			if (visual.isDirty == false) continue;
			visIndex = visual.bufferIndex*40;
		
			for (i in 0...4)
			{
				verIndex = i * 4;
				attIndex = i * 10;
				
				
				//Position
				visualData.data[visIndex + attIndex] = utilFloatArray[attIndex] = visual.x +  quadVertices[verIndex] * visual.width;
				visualData.data[visIndex + attIndex+ 1] = utilFloatArray[attIndex+1] = visual.y +  quadVertices[verIndex+1] * visual.height;
				visualData.data[visIndex + attIndex + 2] = utilFloatArray[attIndex + 2] = visual.visible ? visual.renderDepth : -2;
				
				//UV
				visualData.data[visIndex + attIndex + 3] = utilFloatArray[attIndex + 3] = visual.GetTextureData().uvX +  quadVertices[verIndex + 2] * visual.GetTextureData().uvW;
				visualData.data[visIndex + attIndex + 4] = utilFloatArray[attIndex + 4] = visual.GetTextureData().uvY +  quadVertices[verIndex + 3] * visual.GetTextureData().uvH;
				
				//color
				visualData.data[visIndex + attIndex + 5] = utilFloatArray[attIndex + 5] = ((visual.color >> 16) & 0xff) / 255.0;
				visualData.data[visIndex + attIndex + 6] = utilFloatArray[attIndex + 6] = ((visual.color >>  8) & 0xff) / 255.0;
				visualData.data[visIndex + attIndex + 7] = utilFloatArray[attIndex + 7] = ( visual.color & 0xff) / 255.0;
				visualData.data[visIndex + attIndex + 8] = utilFloatArray[attIndex + 8] = visual.alpha;		
				
				//textureID
				visualData.data[visIndex + attIndex + 9] = utilFloatArray[attIndex + 9] = visual.GetTextureData().atlasIndex;
			}
	
			
			
			
			GL.bufferSubData(GL.ARRAY_BUFFER, visual.bufferIndex * utilFloatArray.byteLength ,utilFloatArray.byteLength, utilFloatArray); 
			
			
			
		}
	
		//DataUtils.DisplayFloatArrayContent(visualData.data, 10);
		
		GL.bindBuffer(GL.ARRAY_BUFFER, 0);
		GL.bindVertexArray(0);
		
		
	}

	public function UpdateBufferFromLayer(layer:BeardLayer):Void
	{
				
		if ( layer.dirtyVisuals == null ||  layer.dirtyVisuals.length == 0) return;
		
		var verIndex:Int = 0;
		var attIndex:Int = 0;
		var visIndex:Int = 0;
		
		GL.bindVertexArray(VAO);
	
		
		//enlarge the buffer data if too small	
		if (GetHigherIndex()  >= visualData.visualsCount)
		{
			var newBufferData:Float32Array = new Float32Array(40 * (GetHigherIndex()+1));
			
			if(visualData.visualsCount > 0)
				for (i in 0...visualData.data.length)
					newBufferData[i] = visualData.data[i];
		
			visualData.data = newBufferData;

			verticesIndices = new UInt16Array(6 * (GetHigherIndex() + 1));
			
			for (i in 0...Math.round(verticesIndices.length / 6)){
				attIndex = i * 6 ;
				verticesIndices[attIndex] 	= 0 + i*4;
				verticesIndices[attIndex+1] = 1 + i*4;
				verticesIndices[attIndex+2] = 2	+ i*4;
				verticesIndices[attIndex+3] = 2 + i*4;
				verticesIndices[attIndex+4] = 3	+ i*4;
				verticesIndices[attIndex+5] = 0 + i*4;
				
			}
			
			GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, EBO);
			GL.bufferData(GL.ELEMENT_ARRAY_BUFFER,verticesIndices.byteLength, verticesIndices, GL.DYNAMIC_DRAW);
			
			GL.bindBuffer(GL.ARRAY_BUFFER, VBO);
			GL.bufferData(GL.ARRAY_BUFFER, visualData.data.byteLength, visualData.data, GL.DYNAMIC_DRAW);
			
			GL.bindBuffer(GL.ARRAY_BUFFER, 0);
		}
		
		
		GL.bindBuffer(GL.ARRAY_BUFFER, VBO);
		
		if (utilFloatArray == null) utilFloatArray = new Float32Array(40);
		
		var visual:Visual;
		//Update data
		for (index in  0...layer.dirtyVisuals.length)
		{
			
			if ((visual = layer.visuals[layer.dirtyVisuals.get(index)]) == null) continue;
			
			visIndex = visual.bufferIndex*40;
		
			for (i in 0...4)
			{
				verIndex = i * 4;
				attIndex = i * 10;
				
				
				//Position
				visualData.data[visIndex + attIndex] = utilFloatArray[attIndex] = visual.x +  quadVertices[verIndex] * visual.width;
				visualData.data[visIndex + attIndex+ 1] = utilFloatArray[attIndex+1] = visual.y +  quadVertices[verIndex+1] * visual.height;
				visualData.data[visIndex + attIndex + 2] = utilFloatArray[attIndex + 2] = visual.visible ? visual.renderDepth : -2;
				
				//UV
				visualData.data[visIndex + attIndex + 3] = utilFloatArray[attIndex + 3] = visual.GetTextureData().uvX +  quadVertices[verIndex + 2] * visual.GetTextureData().uvW;
				visualData.data[visIndex + attIndex + 4] = utilFloatArray[attIndex + 4] = visual.GetTextureData().uvY +  quadVertices[verIndex + 3] * visual.GetTextureData().uvH;
				
				//color
				visualData.data[visIndex + attIndex + 5] = utilFloatArray[attIndex + 5] = ((visual.color >> 16) & 0xff) / 255.0;
				visualData.data[visIndex + attIndex + 6] = utilFloatArray[attIndex + 6] = ((visual.color >>  8) & 0xff) / 255.0;
				visualData.data[visIndex + attIndex + 7] = utilFloatArray[attIndex + 7] = ( visual.color & 0xff) / 255.0;
				visualData.data[visIndex + attIndex + 8] = utilFloatArray[attIndex + 8] = visual.alpha;		
				
				//textureID
				visualData.data[visIndex + attIndex + 9] = utilFloatArray[attIndex + 9] = visual.GetTextureData().atlasIndex;
			}
	
			
			visual.isDirty = false;
			
			GL.bufferSubData(GL.ARRAY_BUFFER, visual.bufferIndex * utilFloatArray.byteLength, utilFloatArray.byteLength, utilFloatArray); 
			
			
			
		}
		
	
		
		GL.bindBuffer(GL.ARRAY_BUFFER, 0);
		GL.bindVertexArray(0);
		
		layer.dirtyVisuals.Clean();
		
	}
	
	public function Start():Void
	{
		ready = true;
	}
	
	public function OnResize(width:Int, height:Int):Void
	{
		GL.viewport(0, 0, Application.current.window.width, Application.current.window.height);
		projection.identity();
		projection.createOrtho( 0, Application.current.window.width, Application.current.window.height, 0, -1, 1);
		//projection = Matrix4.createOrtho( 0,Application.current.window.width, Application.current.window.height, 0, -1, 1);
		GL.uniformMatrix4fv(GL.getUniformLocation(shaderProgram, "projection"), 1, false, projection);
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