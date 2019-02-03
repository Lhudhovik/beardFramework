package beardFramework.graphics.rendering;
import beardFramework.core.BeardGame;
import beardFramework.graphics.core.RenderedObject;
import beardFramework.graphics.core.Visual;
import beardFramework.graphics.rendering.vertexData.RenderedDataBufferArray;
import beardFramework.graphics.text.TextField;
import beardFramework.utils.DataUtils;
import beardFramework.utils.MinAllocArray;
import lime.app.Application;
import lime.graphics.opengl.GL;
import lime.graphics.opengl.GLBuffer;
import lime.graphics.opengl.GLProgram;
import lime.graphics.opengl.GLShader;
import lime.graphics.opengl.GLVertexArrayObject;
import lime.math.Matrix4;
import lime.math.Vector2;
import lime.utils.Float32Array;
import lime.utils.UInt16Array;


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

	
	public var DEFAULT(default, never):String = "default";
	#if debug	
	public var DEBUG(default, never):String = "debug";
	#end

	public var drawCount(default, null):Int = 0;
	public var projection:Matrix4;
	public var view:Matrix4;
	
	private var quadVertices:Float32Array;
	private var verticesIndices:Map<String, UInt16Array>;	
	private var EBOs:Map<String,GLBuffer>;
	private var VBOs:Map<String, GLBuffer>;
	private var VAOs:Map<String,GLVertexArrayObject>;
	private var TBO:GLBuffer;
	private var ready:Bool = false;
	private var model:Matrix4;
	private var fragmentShader:String = "fragmentShader";
	private var vertexShader:String="vertexShader";
	private var bufferIndices:Map<String, Array<Bool>>;
	private var dirtyObjects:Map < String, MinAllocArray<RenderedObject>>;
	private var renderedData:Map < String, RenderedDataBufferArray>;
	private var renderedDataOrdered:Map<String, RenderedDataBufferArray>;
	private var utilFloatArray:Float32Array;
	private var batches:MinAllocArray<Batch>;
	private	var pointer:Int;
	private var shaderPrograms:Map<String, GLProgram>;
	
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
		//
		GL.enable(GL.DEPTH_TEST);
		GL.enable(GL.BLEND);
	
		//GL.disable(GL.CULL_FACE);
		//GL.blendFunc(GL.ONE, GL.ONE_MINUS_SRC_ALPHA);
		GL.blendFunc(GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA);
	
		
		GL.enable(GL.SCISSOR_TEST);
		
		GL.viewport(0, 0, Application.current.window.width, Application.current.window.height);
		
		projection = new Matrix4();
		projection.identity();
		projection.createOrtho( 0, Application.current.window.width, Application.current.window.height, 0, 1, -1);
		view = new Matrix4();
		model = new Matrix4();
			
		quadVertices = new Float32Array(null, [ 
		//x		y	 	uvX		uvY	new uv
		0,		1,		0.0,	1.0,
		1, 		1, 		1.0,	1.0,
		1, 		0,		1.0,    0.0,
		0,		0,		0.0,	0.0
		]);	
		//
		
		
		batches = new MinAllocArray();
		renderedData = new Map();
		bufferIndices = new Map();
		dirtyObjects = new Map();
		shaderPrograms = new Map();
		VAOs = new Map();
		VBOs = new Map();
		EBOs = new Map();
		verticesIndices = new Map();
		#if debug
		InitBatch(DEBUG, "", [{name:vertexShader, type:GL.VERTEX_SHADER}, {name:fragmentShader, type:GL.FRAGMENT_SHADER}]);
		#end
		InitBatch(DEFAULT, "", [{name:vertexShader, type:GL.VERTEX_SHADER}, {name:fragmentShader, type:GL.FRAGMENT_SHADER}]);
		
	}
	
	public function InitBatch(name:String, shaderProgram:String = "", shaderList:Array<Shaders.Shader> = null, needOrdering:Bool = false ):Void
	{
		for (i in 0...batches.length)
			if (batches.get(i).name == name) return;
			
		if (shaderProgram != "" && shaderPrograms[shaderProgram] != null) shaderPrograms[name] = shaderPrograms[shaderProgram];
		else if(shaderList != null)	InitShaders(shaderList, name);
		else shaderPrograms[name] = shaderPrograms[DEFAULT];
		
		GL.useProgram(shaderPrograms[name]);
		
		InitBuffers(name);	
		
		renderedData[name] = new RenderedDataBufferArray();
		bufferIndices[name] = new Array<Bool>();
		dirtyObjects[name] = new MinAllocArray<RenderedObject>();
	
		batches.Push({name:name, needOrdering:needOrdering});
		
		#if debug
		MoveBatchToLast(DEBUG);
		#end
	}
	
	private inline function InitShaders(shadersList:Array<Shaders.Shader>, batch:String):Void
	{
				
		var createdShaders:Array<GLShader> = [];
		for (shader in shadersList)
		{
			
			var glShader:GLShader =  GL.createShader(shader.type);
			GL.shaderSource(glShader, Shaders.shader[shader.name]);
			GL.compileShader(glShader);
			trace(GL.getShaderInfoLog(glShader));
			
			createdShaders.push(glShader);
			
		}
			
		if (shaderPrograms[batch] == null) shaderPrograms[batch] = GL.createProgram();
		
		for (shader in createdShaders)
		{
			GL.attachShader(shaderPrograms[batch], shader);
		}
		
		
		GL.linkProgram(shaderPrograms[batch] );
		trace(GL.getProgramInfoLog(shaderPrograms[batch] ));
		
		for (shader in createdShaders)
		{
			GL.deleteShader(shader);
		}
		
		
		GL.useProgram(shaderPrograms[batch] );
		GL.uniformMatrix4fv(GL.getUniformLocation(shaderPrograms[batch] , "projection"), 1, false, projection);
		GL.uniformMatrix4fv(GL.getUniformLocation(shaderPrograms[batch] , "model"), 1, false, model);
		GL.uniformMatrix4fv(GL.getUniformLocation(shaderPrograms[batch] , "view"), 1, false, view);
		
		//
		for (i in 0...FREETEXTUREINDEX)
		{
			GL.activeTexture(GL.TEXTURE0 + i);
			GL.useProgram(shaderPrograms[batch]) ;
			GL.uniform1i(GL.getUniformLocation(shaderPrograms[batch] , "atlas[" + i + "]"), i);
		}
		
	}
	
	private  function InitBuffers(batch:String):Void
	{
	
		VAOs[batch] = GLObject.fromInt(GLObjectType.VERTEX_ARRAY_OBJECT, VAOCOUNT++);
		//trace(VAOs);
		GL.bindVertexArray(VAOs[batch]);
		
		VBOs[batch]  = GLObject.fromInt(GLObjectType.VERTEX_ARRAY_OBJECT, BUFFERCOUNT++);
		GL.bindBuffer(GL.ARRAY_BUFFER, VBOs[batch]);
		//trace(VBOs[batch] );
		GL.enableVertexAttribArray(0);
		GL.vertexAttribPointer(0, 3, GL.FLOAT, false, 10 * Float32Array.BYTES_PER_ELEMENT, 0);
		GL.bindAttribLocation(shaderPrograms[batch], 0, "pos");
		
		GL.enableVertexAttribArray(1);
		GL.vertexAttribPointer(1, 3, GL.FLOAT, false, 10 * Float32Array.BYTES_PER_ELEMENT, 3* Float32Array.BYTES_PER_ELEMENT);
		GL.bindAttribLocation(shaderPrograms[batch], 1, "uv");
		
		GL.enableVertexAttribArray(2);
		GL.vertexAttribPointer(2, 4, GL.FLOAT, false, 10 * Float32Array.BYTES_PER_ELEMENT, 6 * Float32Array.BYTES_PER_ELEMENT);
		GL.bindAttribLocation(shaderPrograms[batch], 2, "color");
		
		//var pointer:Int = GL.getAttribLocation(shaderPrograms[batch], "pos");
		//GL.enableVertexAttribArray(pointer);
		//GL.vertexAttribPointer(pointer, 3, GL.FLOAT, false, 10 * Float32Array.BYTES_PER_ELEMENT, 0);
		//trace(pointer);
		//pointer = GL.getAttribLocation(shaderPrograms[batch], "uv");
		//GL.enableVertexAttribArray(pointer);
		//GL.vertexAttribPointer(pointer, 3, GL.FLOAT, false, 10 * Float32Array.BYTES_PER_ELEMENT, 3* Float32Array.BYTES_PER_ELEMENT);
		//trace(pointer);
		//pointer = GL.getAttribLocation(shaderPrograms[batch], "color");	
		//GL.enableVertexAttribArray(pointer);
		//GL.vertexAttribPointer(pointer, 4, GL.FLOAT, false, 10 * Float32Array.BYTES_PER_ELEMENT, 6 * Float32Array.BYTES_PER_ELEMENT);
		//trace(pointer);
		
		
		EBOs[batch]  = GLObject.fromInt(GLObjectType.VERTEX_ARRAY_OBJECT, BUFFERCOUNT++);
		verticesIndices[batch] = new UInt16Array([0, 1, 2, 2, 3, 0]);
		GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, EBOs[batch]);
		GL.bufferData(GL.ELEMENT_ARRAY_BUFFER, verticesIndices[batch].byteLength, verticesIndices[batch], GL.DYNAMIC_DRAW);
		
		GL.bindBuffer(GL.ARRAY_BUFFER, 0);
		GL.bindVertexArray(0);
	}
		
	public function Start():Void
	{
		ready = true;
		//BeardGame.Get().onWindowResize(Application.current.window.width, Application.current.window.height);
		OnResize(Application.current.window.width, Application.current.window.height);
		
		
	}
	
	public function Render():Void
	{
		
		if (ready)
		{
			//GL.scissor(0,0, BeardGame.Get().window.width, BeardGame.Get().window.height);
			GL.clearColor(0.2, 0.3, 0.8, 1);
			GL.clear(GL.COLOR_BUFFER_BIT);
			GL.clear(GL.DEPTH_BUFFER_BIT);
			var batch:Batch;
			drawCount = 0;
			
			
			for (i in 0...batches.length)
			{
				
				batch = batches.get(i);
				
				if (dirtyObjects[batch.name].length > 0) UpdateRenderedData(batch.name);
				if (renderedData[batch.name].activeDataCount == 0) continue;
		
				//trace("go to render " + batch + " " +renderedData[batch].activeDataCount  );
				
				GL.useProgram(shaderPrograms[batch.name]);
			
				for (camera in BeardGame.Get().cameras)
				{
			
					
					
					GL.scissor(camera.viewport.x,Application.current.window.height - camera.viewport.y - camera.viewport.height, camera.viewport.width, camera.viewport.height);
					
					
					view.identity();
					view.appendScale(camera.zoom, camera.zoom,0);
					view.appendTranslation( -(camera.centerX - camera.viewportWidth * 0.5), -(camera.centerY - camera.viewportHeight * 0.5), 0);
					GL.uniformMatrix4fv(GL.getUniformLocation(shaderPrograms[batch.name], "view"), 1, false, view);
					
				
					//GL.bindVertexArray(VAOs[batch]);
					
					GL.bindBuffer(GL.ARRAY_BUFFER, VBOs[batch.name]);
										
					pointer = GL.getAttribLocation(shaderPrograms[batch.name], "pos");
					GL.enableVertexAttribArray(pointer);
					GL.vertexAttribPointer(pointer, 3, GL.FLOAT, false, 10 * Float32Array.BYTES_PER_ELEMENT, 0);
					
					pointer = GL.getAttribLocation(shaderPrograms[batch.name], "uv");
					GL.enableVertexAttribArray(pointer);
					GL.vertexAttribPointer(pointer, 3, GL.FLOAT, false, 10 * Float32Array.BYTES_PER_ELEMENT, 3* Float32Array.BYTES_PER_ELEMENT);
					
					pointer = GL.getAttribLocation(shaderPrograms[batch.name], "color");	
					GL.enableVertexAttribArray(pointer);
					GL.vertexAttribPointer(pointer, 4, GL.FLOAT, false, 10 * Float32Array.BYTES_PER_ELEMENT, 6 * Float32Array.BYTES_PER_ELEMENT);
					
								
					
					GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, EBOs[batch.name]);
					GL.bufferData(GL.ELEMENT_ARRAY_BUFFER, verticesIndices[batch.name].byteLength, verticesIndices[batch.name], GL.DYNAMIC_DRAW);
				
					GL.drawElements(GL.TRIANGLES, verticesIndices[batch.name].length, GL.UNSIGNED_SHORT, 0);
				
					drawCount++;
								
					GL.bindVertexArray(0);
					
					var error:Int = GL.getError();
				
					if (error != 0)
						trace(error);
					
				}
			
				
				
				
				
			}
			//trace(drawCount);
		}
		

			
	}
	
	public function OnResize(width:Int, height:Int):Void
	{
		GL.viewport(0, 0, Application.current.window.width, Application.current.window.height);
		projection.identity();
		projection.createOrtho( 0,Application.current.window.width, Application.current.window.height, 0, 1, -1);
		
		for (program in shaderPrograms){
			GL.useProgram(program);
			GL.uniformMatrix4fv(GL.getUniformLocation(program, "projection"), 1, false, projection);
		}
		
		
	}
	
	public function GetFreeTextureIndex():Int
	{
		return FREETEXTUREINDEX;
	}
	
	public inline function AllocateFreeTextureIndex():Int
	{
		
		return FREETEXTUREINDEX++;
	}
	
	public function UpdateTexture(index:Int = 0):Void
	{
		for (program in shaderPrograms){
			GL.useProgram(program);
			GL.uniform1i(GL.getUniformLocation(program, "atlas[" + index + "]"), index);
		}
		
	}
	
	public function UpdateRenderedData(batch:String):Void
	{
	
		if (ready){
				
			
			if ( dirtyObjects[batch] == null ||  dirtyObjects[batch].length == 0) return;
			
			var verIndex:Int = 0;
			var attIndex:Int = 0;
			var visIndex:Int = 0;
			
			
			GL.bindVertexArray(VAOs[batch]);
	
			
			//enlarge the buffer data if too small	
			if (GetHigherIndex(batch)  >= renderedData[batch].size)
			{
			
				var newBufferData:Float32Array = new Float32Array(40 * (GetHigherIndex(batch)+1));
				
				if(renderedData[batch].size > 0)
					for (i in 0...renderedData[batch].data.length)
						newBufferData[i] = renderedData[batch].data[i];
			
				renderedData[batch].data = newBufferData;
				
				verticesIndices[batch] = new UInt16Array(6 * (GetHigherIndex(batch) + 1));
				
				for (i in 0...Math.round(verticesIndices[batch].length / 6)){
					attIndex = i * 6 ;
					verticesIndices[batch][attIndex] 	= 0 + i*4;
					verticesIndices[batch][attIndex+1] = 1 + i*4;
					verticesIndices[batch][attIndex+2] = 2	+ i*4;
					verticesIndices[batch][attIndex+3] = 2 + i*4;
					verticesIndices[batch][attIndex+4] = 3	+ i*4;
					verticesIndices[batch][attIndex+5] = 0 + i*4;
					
				}
				
				GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, EBOs[batch]);
				GL.bufferData(GL.ELEMENT_ARRAY_BUFFER,verticesIndices[batch].byteLength, verticesIndices[batch], GL.DYNAMIC_DRAW);
				
				GL.bindBuffer(GL.ARRAY_BUFFER, VBOs[batch]);
				GL.bufferData(GL.ARRAY_BUFFER, renderedData[batch].data.byteLength, renderedData[batch].data, GL.DYNAMIC_DRAW);
				
				GL.bindBuffer(GL.ARRAY_BUFFER, 0);
			}
			
			
			GL.bindBuffer(GL.ARRAY_BUFFER, VBOs[batch]);
			
			if (utilFloatArray == null) utilFloatArray = new Float32Array(40);
					
			var visual:Visual;
			var textfield:TextField;
			var center:Vector2 = new Vector2();
			
			//Update data
			for (i in  0...dirtyObjects[batch].length)
			{
				
				
				if (dirtyObjects[batch].get(i) == null) continue;
				
				else if ( Std.is(dirtyObjects[batch].get(i), Visual) && (visual = cast(dirtyObjects[batch].get(i), Visual)) != null)
				{
					
					visIndex = visual.bufferIndex*40;
					center.x =  visual.width * 0.5;
					center.y = visual.height * 0.5;
					for (i in 0...4)
					{
						verIndex = i * 4;
						attIndex = i * 10;
						
						
						//Position
						renderedData[batch].data[visIndex + attIndex] = utilFloatArray[attIndex] = visual.x + center.x + ((quadVertices[verIndex] * visual.width)-center.x)*visual.rotationCosine -  ((quadVertices[verIndex+1] * visual.height)-center.y)*visual.rotationSine;
						//renderedData.data[visIndex + attIndex] = utilFloatArray[attIndex] = visual.x +  quadVertices[verIndex] * visual.width;
						renderedData[batch].data[visIndex + attIndex+ 1] = utilFloatArray[attIndex+1] = visual.y + center.y + ((quadVertices[verIndex] * visual.width)-center.x)*visual.rotationSine +  ((quadVertices[verIndex+1] * visual.height)-center.y)*visual.rotationCosine;
						//renderedData.data[visIndex + attIndex+ 1] = utilFloatArray[attIndex+1] = visual.y +  quadVertices[verIndex+1] * visual.height;
						renderedData[batch].data[visIndex + attIndex + 2] = utilFloatArray[attIndex + 2] = visual.visible ? visual.renderDepth : -2;
								
						
						//UV + TextureID
						renderedData[batch].data[visIndex + attIndex + 3] = utilFloatArray[attIndex + 3] = visual.GetTextureData().uvX +  quadVertices[verIndex + 2] * visual.GetTextureData().uvW;
						renderedData[batch].data[visIndex + attIndex + 4] = utilFloatArray[attIndex + 4] = visual.GetTextureData().uvY +  quadVertices[verIndex + 3] * visual.GetTextureData().uvH;
						renderedData[batch].data[visIndex + attIndex + 5] = utilFloatArray[attIndex + 5] = cast( visual.GetTextureData().atlasIndex, Float);
						
						//color
						renderedData[batch].data[visIndex + attIndex + 6] = utilFloatArray[attIndex + 6] = ((visual.color >> 16) & 0xff) / 255.0;
						renderedData[batch].data[visIndex + attIndex + 7] = utilFloatArray[attIndex + 7] = ((visual.color >>  8) & 0xff) / 255.0;
						renderedData[batch].data[visIndex + attIndex + 8] = utilFloatArray[attIndex + 8] = ( visual.color & 0xff) / 255.0;
						renderedData[batch].data[visIndex + attIndex + 9] = utilFloatArray[attIndex + 9] = visual.alpha;		
						
					}
						
					visual.isDirty = false;
				
					GL.bufferSubData(GL.ARRAY_BUFFER, visual.bufferIndex * utilFloatArray.byteLength, utilFloatArray.byteLength, utilFloatArray); 
								
				}
				else if (Std.is(dirtyObjects[batch].get(i), TextField) && (textfield = cast(dirtyObjects[batch].get(i), TextField)) != null)
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
							renderedData[batch].data[visIndex + attIndex] = utilFloatArray[attIndex] = textfield.x  +  center.x + ((quadVertices[verIndex] * data.width + data.x)-center.x)*textfield.rotationCosine -  ((quadVertices[verIndex+1] * data.height + data.y)-center.y)*textfield.rotationSine;
							//renderedData.data[visIndex + attIndex] = utilFloatArray[attIndex] = textfield.x + data.x +  quadVertices[verIndex] * data.width;
							renderedData[batch].data[visIndex + attIndex+ 1] = utilFloatArray[attIndex+1] =  textfield.y + center.y + ((quadVertices[verIndex] * data.width+data.x)-center.x)*textfield.rotationSine +  ((quadVertices[verIndex+1] * data.height+data.y)-center.y)*textfield.rotationCosine;
							//renderedData.data[visIndex + attIndex+ 1] = utilFloatArray[attIndex+1] = textfield.y +  data.y +  quadVertices[verIndex+1] * data.height;
							renderedData[batch].data[visIndex + attIndex + 2] = utilFloatArray[attIndex + 2] = textfield.visible ? textfield.renderDepth : -2;
							
							//UV + Texture ID
							renderedData[batch].data[visIndex + attIndex + 3] = utilFloatArray[attIndex + 3] = data.textureData.uvX +  quadVertices[verIndex + 2] * data.textureData.uvW;
							renderedData[batch].data[visIndex + attIndex + 4] = utilFloatArray[attIndex + 4] = data.textureData.uvY +  quadVertices[verIndex + 3] * data.textureData.uvH;
							renderedData[batch].data[visIndex + attIndex + 5] = utilFloatArray[attIndex + 5] = cast(data.textureData.atlasIndex, Float);
							
							//color
							renderedData[batch].data[visIndex + attIndex + 6] = utilFloatArray[attIndex + 6] = ((data.color >> 16) & 0xff) / 255.0;
							renderedData[batch].data[visIndex + attIndex + 7] = utilFloatArray[attIndex + 7] = ((data.color >>  8) & 0xff) / 255.0;
							renderedData[batch].data[visIndex + attIndex + 8] = utilFloatArray[attIndex + 8] = ( data.color & 0xff) / 255.0;
							renderedData[batch].data[visIndex + attIndex + 9] = utilFloatArray[attIndex + 9] = textfield.alpha;		
							
						}
						
						GL.bufferSubData(GL.ARRAY_BUFFER, data.bufferIndex * utilFloatArray.byteLength ,utilFloatArray.byteLength, utilFloatArray); 
						
					}
					
					textfield.isDirty = false;
					
				}
			}
			
			GL.bindBuffer(GL.ARRAY_BUFFER, 0);
			GL.bindVertexArray(0);
			dirtyObjects[batch].Clean();
			
			var visu:Array<Float> = [];
			for (i in 0...renderedData[batch].data.length)
				visu.push(renderedData[batch].data[i]);
			//trace(visu);
			
		}
		
		
	}
	
	public function CleanRenderedData(index:Int, batch:String):Void
	{
		var attIndex:Int = 0;
		var visIndex:Int = index*40;
			
		
		GL.bindVertexArray(VAOs[batch]);
		
		GL.bindBuffer(GL.ARRAY_BUFFER, VBOs[batch]);
					
		utilFloatArray = new Float32Array(40);
		for (i in 0...4)
		{
			//verIndex = i * 4;
			attIndex = i * 10;
			
			//Position
			renderedData[batch].data[visIndex + attIndex] = utilFloatArray[attIndex] = 0;
			renderedData[batch].data[visIndex + attIndex+ 1] = utilFloatArray[attIndex+1] =0;
			renderedData[batch].data[visIndex + attIndex + 2] = utilFloatArray[attIndex + 2] = -2;
			
			//UV + TextureID
			renderedData[batch].data[visIndex + attIndex + 3] = utilFloatArray[attIndex + 3] = 0;
			renderedData[batch].data[visIndex + attIndex + 4] = utilFloatArray[attIndex + 4] = 0;
			renderedData[batch].data[visIndex + attIndex + 5] = utilFloatArray[attIndex + 5] = 0;
			
			//color
			renderedData[batch].data[visIndex + attIndex + 6] = utilFloatArray[attIndex + 6] = 0;
			renderedData[batch].data[visIndex + attIndex + 7] = utilFloatArray[attIndex + 7] = 0;
			renderedData[batch].data[visIndex + attIndex + 8] = utilFloatArray[attIndex + 8] = 0;
			renderedData[batch].data[visIndex + attIndex + 9] = utilFloatArray[attIndex + 9] = 0;		
			
			//textureID
			
		}
	
		GL.bufferSubData(GL.ARRAY_BUFFER, index * utilFloatArray.byteLength, utilFloatArray.byteLength, utilFloatArray); 
		if(renderedData[batch].activeDataCount >0)  renderedData[batch].activeDataCount --;
		
		GL.bindBuffer(GL.ARRAY_BUFFER, 0);
		GL.bindVertexArray(0); 				
		
	}
	
	public inline function AddDirtyObject(object:RenderedObject, batch:String):Void
	{
		if (dirtyObjects[batch].IndexOf(object) == -1)
		{
			dirtyObjects[batch].Push(object);
		}
	}
	
	public function RemoveDirtyObject(object:RenderedObject, batch:String):Void
	{
		dirtyObjects[batch].Remove(object);
	}
	
	public function AllocateBufferIndex(batch:String):Int
	{
		var index:Int = -1;
		var length:Int = bufferIndices[batch].length;
		
		for (i in 0...length)
			if (bufferIndices[batch][i] == false)
			{
				bufferIndices[batch][i] = true;
				index = i;
				break;
			}
		
		if (index == -1)
		{
			bufferIndices[batch].push(true);
			index = length;
		}
		//trace("allocated index : " + index);
		renderedData[batch].activeDataCount++;
		return index;
		
	}
	
	public function AllocateBufferIndices(count:Int, batch:String):Array<Int>
	{
		var indices:Array<Int>=new Array();
		var length:Int = bufferIndices[batch].length;
		
		for (i in 0...length)
			if (bufferIndices[batch][i] == false)
			{
				bufferIndices[batch][i] = true;
				indices.push(i);
				count--;
				
				if (count == 0) break;
			}
		
		while (count-- > 0)
		{
			bufferIndices[batch].push(true);
			indices.push(length++);
		}
		
		return indices;
		
	}
	
	public function GetFreeBufferIndex(batch:String):Int
	{
		var index:Int = -1;
		var length:Int = bufferIndices[batch].length;
		
		for (i in 0...length)
			if (bufferIndices[batch][i] == false)
			{
				index = i;
				break;
			}
		
		return index;
		
	}
	
	public inline function FreeBufferIndex(index:Int, batch:String):Int
	{
		
		if (index < bufferIndices[batch].length && index >= 0){
			
			bufferIndices[batch][index] = false;
			CleanRenderedData(index, batch);
			
		}
		
			
		return -1;
		
	}
	
	private inline function GetHigherIndex(batch:String ):Int
	{
		return bufferIndices[batch].length - 1;
	}
	
	public function MoveBatchToFirst(batch:String):Void
	{
			
		for (i in 0...batches.length)
		{
			if (batches.get(i).name == batch)
			{
				batches.MoveByIndex(i, 0);
				break;
			}
		}
		
	}
	
	public function MoveBatchToLast(batch:String):Void
	{
		for (i in 0...batches.length)
		{
			if (batches.get(i).name == batch)
			{
				batches.MoveByIndex(i, batches.length-1);
				break;
			}
		}
	}
	
	public function MoveBatchUp(batch:String):Void
	{
		
		for (i in 0...batches.length)
		{
			if (batches.get(i).name == batch && i < batches.length-1)
			{
				batches.MoveByIndex(i, i+1);
				break;
			}
		}
		
	}
	
	public function MoveBatchDown(batch:String):Void
	{
		
		for (i in 0...batches.length)
		{
			if (batches.get(i).name == batch && i > 0)
			{
				batches.MoveByIndex(i, i-1);
				break;
			}
		}
		
	}
	
}

typedef Batch =
{
	public var name:String;
	public var needOrdering:Bool;
}