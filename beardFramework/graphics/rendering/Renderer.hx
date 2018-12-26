package beardFramework.graphics.rendering;
import beardFramework.core.BeardGame;
import beardFramework.graphics.cameras.Camera;
import beardFramework.graphics.core.BeardLayer;
import beardFramework.graphics.core.BeardLayer.BeardLayerType;
import beardFramework.graphics.core.RenderedObject;
import beardFramework.graphics.core.Visual;
import beardFramework.graphics.rendering.vertexData.RenderedDataBufferArray;
import beardFramework.graphics.text.TextField;
import beardFramework.resources.assets.AssetManager;
import beardFramework.utils.DataUtils;
import beardFramework.utils.MinAllocArray;
import haxe.ds.Vector;
import lime.app.Application;
import lime.graphics.opengl.GL;
import lime.graphics.opengl.GLBuffer;
import lime.graphics.opengl.GLProgram;
import lime.graphics.opengl.GLShader;
import lime.graphics.opengl.GLTexture;
import lime.graphics.opengl.GLVertexArrayObject;
import lime.math.Matrix4;
import lime.math.Vector2;
import lime.math.Vector4;
import lime.text.Font;
import lime.utils.Bytes;
import lime.utils.DataPointer;
import lime.utils.Float32Array;
import lime.utils.UInt16Array;
import openfl.display.BitmapData;

@:access(lime.graphics.opengl.GL.GLObject)
/**
 * ...
 * @author 
 */
class Renderer 
{
	private static var VAOCOUNT:Int = 1;
	private static var BUFFERCOUNT:Int = 1;
	private static var FREETEXTUREINDEX:Int = 0;
	private static var ATTRIBUTEPOINTER:Int = 0;
	private static var instance:Renderer;


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
	public var dirtyObjects:MinAllocArray<RenderedObject>;
	private var renderedData:RenderedDataBufferArray;
	private var renderedDataOrdered:RenderedDataBufferArray;
	private var utilFloatArray:Float32Array;
	
	
	private function new()
	{
		
	}
	public static inline function Get():Renderer
	{
		if (instance == null)
		{
			instance = new Renderer();
			instance.Init();
		}
		
		return instance;
	}
	
	private function Init():Void
	{
		
		
		Application.current.window.onResize.add(OnResize);
		
		GL.enable(GL.DEPTH_TEST);
		GL.enable(GL.BLEND);
	
		//GL.blendFunc(GL.ONE, GL.ONE_MINUS_SRC_ALPHA);
		GL.blendFunc(GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA);
	
		
		GL.enable(GL.SCISSOR_TEST);
		
		GL.viewport(0, 0, Application.current.window.width, Application.current.window.height);
		
		projection = new Matrix4();
		projection.identity();
		projection.createOrtho( 0, Application.current.window.width, Application.current.window.height, 0, 1, -1);
		view = new Matrix4();
		model = new Matrix4();
			
		InitShaders();
		InitVertices();
		InitBuffers();		
		
		renderedData = new RenderedDataBufferArray();
		bufferIndices = new Array<Bool>();
		dirtyObjects = new MinAllocArray<RenderedObject>();
		
	}
	
	public function Render():Void
	{
		
		if (ready)
		{
			
			if (dirtyObjects.length > 0) UpdateRenderedData();
			if (renderedData.count == 0) return;
		
			drawCount = 0;
			
			
			
			for (camera in BeardGame.Get().cameras)
			{
				
				GL.clearColor(0.2, 0.3, 0.8, 1);
				GL.clear(GL.COLOR_BUFFER_BIT);
				GL.clear(GL.DEPTH_BUFFER_BIT);
				
				GL.scissor(camera.viewport.x,Application.current.window.height - camera.viewport.y - camera.viewport.height, camera.viewport.width, camera.viewport.height);
			
				
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
	
	public function GetFreeTextureIndex():Int{
		return FREETEXTUREINDEX;
	}
	
	public function AllocateFreeTextureIndex():Int
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
	
	private inline function InitShaders():Void
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
	
	private inline function InitVertices():Void
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
	
	private  function InitBuffers():Void
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
		projection.createOrtho( 0,Application.current.window.width, Application.current.window.height, 0, 1, -1);
		//projection = Matrix4.createOrtho( 0,Application.current.window.width, Application.current.window.height, 0, -1, 1);
		GL.uniformMatrix4fv(GL.getUniformLocation(shaderProgram, "projection"), 1, false, projection);
		
		
	}
	
	
	public function UpdateRenderedData():Void
	{
	
		if (ready){
				
			if ( dirtyObjects == null ||  dirtyObjects.length == 0) return;
			
			var verIndex:Int = 0;
			var attIndex:Int = 0;
			var visIndex:Int = 0;
			
			GL.bindVertexArray(VAO);
	
		
			//enlarge the buffer data if too small	
			if (GetHigherIndex()  >= renderedData.count)
			{
				var newBufferData:Float32Array = new Float32Array(40 * (GetHigherIndex()+1));
				
				if(renderedData.count > 0)
					for (i in 0...renderedData.data.length)
						newBufferData[i] = renderedData.data[i];
			
				renderedData.data = newBufferData;
				
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
				GL.bufferData(GL.ARRAY_BUFFER, renderedData.data.byteLength, renderedData.data, GL.DYNAMIC_DRAW);
				
				GL.bindBuffer(GL.ARRAY_BUFFER, 0);
			}
			
			
			GL.bindBuffer(GL.ARRAY_BUFFER, VBO);
			
			if (utilFloatArray == null) utilFloatArray = new Float32Array(40);
			
			var visual:Visual;
			var textfield:TextField;
			var center:Vector2 = new Vector2();
			//Update data
			for (i in  0...dirtyObjects.length)
			{
				
				
				if (dirtyObjects.get(i) == null) continue;
				
				else if ( Std.is(dirtyObjects.get(i), Visual) && (visual = cast(dirtyObjects.get(i), Visual)) != null)
				{
					//trace("is visual");
					visIndex = visual.bufferIndex*40;
					center.x =  visual.width * 0.5;
					center.y = visual.height * 0.5;
					for (i in 0...4)
					{
						verIndex = i * 4;
						attIndex = i * 10;
						
						
						//Position
						renderedData.data[visIndex + attIndex] = utilFloatArray[attIndex] = visual.x + center.x + ((quadVertices[verIndex] * visual.width)-center.x)*visual.rotationCosine -  ((quadVertices[verIndex+1] * visual.height)-center.y)*visual.rotationSine;
						//renderedData.data[visIndex + attIndex] = utilFloatArray[attIndex] = visual.x +  quadVertices[verIndex] * visual.width;
						renderedData.data[visIndex + attIndex+ 1] = utilFloatArray[attIndex+1] = visual.y + center.y + ((quadVertices[verIndex] * visual.width)-center.x)*visual.rotationSine +  ((quadVertices[verIndex+1] * visual.height)-center.y)*visual.rotationCosine;
						//renderedData.data[visIndex + attIndex+ 1] = utilFloatArray[attIndex+1] = visual.y +  quadVertices[verIndex+1] * visual.height;
						renderedData.data[visIndex + attIndex + 2] = utilFloatArray[attIndex + 2] = visual.visible ? visual.renderDepth : -2;
						
						//UV + TextureID
						renderedData.data[visIndex + attIndex + 3] = utilFloatArray[attIndex + 3] = visual.GetTextureData().uvX +  quadVertices[verIndex + 2] * visual.GetTextureData().uvW;
						renderedData.data[visIndex + attIndex + 4] = utilFloatArray[attIndex + 4] = visual.GetTextureData().uvY +  quadVertices[verIndex + 3] * visual.GetTextureData().uvH;
						renderedData.data[visIndex + attIndex + 5] = utilFloatArray[attIndex + 5] = cast( visual.GetTextureData().atlasIndex, Float);
						
						//color
						renderedData.data[visIndex + attIndex + 6] = utilFloatArray[attIndex + 6] = ((visual.color >> 16) & 0xff) / 255.0;
						renderedData.data[visIndex + attIndex + 7] = utilFloatArray[attIndex + 7] = ((visual.color >>  8) & 0xff) / 255.0;
						renderedData.data[visIndex + attIndex + 8] = utilFloatArray[attIndex + 8] = ( visual.color & 0xff) / 255.0;
						renderedData.data[visIndex + attIndex + 9] = utilFloatArray[attIndex + 9] = visual.alpha;		
									
					}
						
					visual.isDirty = false;
				
					GL.bufferSubData(GL.ARRAY_BUFFER, visual.bufferIndex * utilFloatArray.byteLength, utilFloatArray.byteLength, utilFloatArray); 
								
				}
				else if (Std.is(dirtyObjects.get(i), TextField) && (textfield = cast(dirtyObjects.get(i), TextField)) != null)
				{
					
					if (textfield.needLayoutUpdate)	textfield.UpdateLayout();
										center.x =  textfield.width * 0.5;
						center.y = textfield.height * 0.5;	
					for (data in textfield.glyphsData)
					{
						
						visIndex = data.bufferIndex*40;
					
						
						for (i in 0...4)
						{
							verIndex = i * 4;
							attIndex = i * 10;
							
							
							//Position
							renderedData.data[visIndex + attIndex] = utilFloatArray[attIndex] = textfield.x  +  center.x + ((quadVertices[verIndex] * data.width + data.x)-center.x)*textfield.rotationCosine -  ((quadVertices[verIndex+1] * data.height + data.y)-center.y)*textfield.rotationSine;
							//renderedData.data[visIndex + attIndex] = utilFloatArray[attIndex] = textfield.x + data.x +  quadVertices[verIndex] * data.width;
							renderedData.data[visIndex + attIndex+ 1] = utilFloatArray[attIndex+1] =  textfield.y + center.y + ((quadVertices[verIndex] * data.width+data.x)-center.x)*textfield.rotationSine +  ((quadVertices[verIndex+1] * data.height+data.y)-center.y)*textfield.rotationCosine;
							//renderedData.data[visIndex + attIndex+ 1] = utilFloatArray[attIndex+1] = textfield.y +  data.y +  quadVertices[verIndex+1] * data.height;
							renderedData.data[visIndex + attIndex + 2] = utilFloatArray[attIndex + 2] = textfield.visible ? textfield.renderDepth : -2;
							
							//UV + Texture ID
							renderedData.data[visIndex + attIndex + 3] = utilFloatArray[attIndex + 3] = data.textureData.uvX +  quadVertices[verIndex + 2] * data.textureData.uvW;
							renderedData.data[visIndex + attIndex + 4] = utilFloatArray[attIndex + 4] = data.textureData.uvY +  quadVertices[verIndex + 3] * data.textureData.uvH;
							renderedData.data[visIndex + attIndex + 5] = utilFloatArray[attIndex + 5] = cast(data.textureData.atlasIndex, Float);
							
							//color
							renderedData.data[visIndex + attIndex + 6] = utilFloatArray[attIndex + 6] = ((data.color >> 16) & 0xff) / 255.0;
							renderedData.data[visIndex + attIndex + 7] = utilFloatArray[attIndex + 7] = ((data.color >>  8) & 0xff) / 255.0;
							renderedData.data[visIndex + attIndex + 8] = utilFloatArray[attIndex + 8] = ( data.color & 0xff) / 255.0;
							renderedData.data[visIndex + attIndex + 9] = utilFloatArray[attIndex + 9] = textfield.alpha;		
							
							
						}
						
						GL.bufferSubData(GL.ARRAY_BUFFER, data.bufferIndex * utilFloatArray.byteLength ,utilFloatArray.byteLength, utilFloatArray); 
						
					}
					
					textfield.isDirty = false;
					
				}
			}
			
			GL.bindBuffer(GL.ARRAY_BUFFER, 0);
			GL.bindVertexArray(0);
			
			dirtyObjects.Clean();
		}
		
		
	}
	
	public function CleanRenderedData(index:Int = -1):Void
	{
		var verIndex:Int = 0;
		var attIndex:Int = 0;
		var visIndex:Int = index*40;
			
		
		GL.bindVertexArray(VAO);
		
		GL.bindBuffer(GL.ARRAY_BUFFER, VBO);
					
		if (utilFloatArray == null) utilFloatArray = new Float32Array(40);
		for (i in 0...4)
		{
			verIndex = i * 4;
			attIndex = i * 10;
			
			//Position
			renderedData.data[visIndex + attIndex] = utilFloatArray[attIndex] = 0;
			renderedData.data[visIndex + attIndex+ 1] = utilFloatArray[attIndex+1] =0;
			renderedData.data[visIndex + attIndex + 2] = utilFloatArray[attIndex + 2] = -2;
			
			//UV + TextureID
			renderedData.data[visIndex + attIndex + 3] = utilFloatArray[attIndex + 3] = 0;
			renderedData.data[visIndex + attIndex + 4] = utilFloatArray[attIndex + 4] = 0;
			renderedData.data[visIndex + attIndex + 5] = utilFloatArray[attIndex + 5] = 0;
			
			//color
			renderedData.data[visIndex + attIndex + 6] = utilFloatArray[attIndex + 6] = 0;
			renderedData.data[visIndex + attIndex + 7] = utilFloatArray[attIndex + 7] = 0;
			renderedData.data[visIndex + attIndex + 8] = utilFloatArray[attIndex + 8] = 0;
			renderedData.data[visIndex + attIndex + 9] = utilFloatArray[attIndex + 9] = 0;		
			
			//textureID
			
		}
	
		GL.bufferSubData(GL.ARRAY_BUFFER, index * utilFloatArray.byteLength, utilFloatArray.byteLength, utilFloatArray); 
			
		GL.bindBuffer(GL.ARRAY_BUFFER, 0);
		GL.bindVertexArray(0); 				
		
	}
	
	
	public inline function AddDirtyObject(object:RenderedObject):Void
	{
		if (dirtyObjects.IndexOf(object) == -1)
		{
			dirtyObjects.Push(object);
		}
	}
	
	public function RemoveDirtyObject(object:RenderedObject):Void
	{
		dirtyObjects.Remove(object);
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
		//trace("allocated index : " + index);
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
		trace("free");
		if (index < bufferIndices.length && index > 0){
			
			bufferIndices[index] = false;
			CleanRenderedData(index);
		}
		
			
		return -1;
		
	}
	
	private inline function GetHigherIndex():Int
	{
		return bufferIndices.length - 1;
	}
	
}