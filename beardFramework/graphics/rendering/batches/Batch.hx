package beardFramework.graphics.rendering.batches;
import beardFramework.core.BeardGame;
import beardFramework.graphics.cameras.Camera;
import beardFramework.graphics.core.RenderedObject;
import beardFramework.graphics.rendering.vertexData.RenderedDataBufferArray;
import beardFramework.graphics.rendering.vertexData.VertexAttribute;
import beardFramework.resources.MinAllocArray;
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
class Batch 
{

	public var needUpdate:Bool;
	public var cameras:List<String>;
	public var name:String;
	public var shaderProgram(default, null):GLProgram;
	public var drawMode:Int;
	
	private var vertices:Vector<Float>; //implement as you like on each batch class
	private var indices:Vector<Int>;
	private var vertexAttributes:Vector<VertexAttribute>;
	private var bufferIndices:Array<Bool>;
	private var EBO:GLBuffer;
	private var VBO:GLBuffer;
	private var VAO:GLVertexArrayObject;
	private var verticesData:RenderedDataBufferArray;
	private var indicesData:UInt16Array;
	private var verticesDataOrdered:RenderedDataBufferArray;

	private var utilFloatArray:Float32Array;
	private var utilUIntArray:UInt16Array;
	private	var pointer:Int;
	private	var indicesPerObject:Int;
	private var needOrdering:Bool;
	private var renderer:Renderer;
	private var drawCount:Int = 0;

	
	public static function CreateBatch(batchData:BatchData):Batch
	{
		
		var batch:Batch = Type.createInstance(Type.resolveClass("beardFramework.graphics.rendering.batches."+batchData.type), []);
		batch.Init(batchData);
		return batch;
		
	}
	
	public function new() 
	{
	
	}
	
	private function Init(batchData:BatchData):Void
	{
		name = batchData.name;
		needOrdering = batchData.needOrdering;
		renderer = Renderer.Get();
		drawMode = batchData.drawMode;
		needUpdate = false;
		indicesPerObject = 0;
		
		verticesData = new RenderedDataBufferArray(batchData.vertexStride, batchData.vertexPerObject);
		bufferIndices = new Array<Bool>();
		
		InitVertices(batchData.vertices, batchData.indices);
		InitShaders(batchData.shaders);
		InitBuffers(batchData.vertexAttributes, batchData.vertexStride);
		
		cameras = new List();
		
		for (camera in BeardGame.Get().cameras)
			cameras.add(camera.name);
	
	}
	
	public function InitVertices(vertices: Array<Float> , indices:Array<Int> = null):Void
	{
		
		indicesData = new UInt16Array(indices);
		this.indices = Vector.fromArrayCopy(indices);
		indicesPerObject = (indices != null? indices.length : 0);
		//trace(indices);
		this.vertices = Vector.fromArrayCopy(vertices);
	
	}
	
	public function InitShaders(shadersList:Array<Shaders.Shader>):Void
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
			
		if (shaderProgram == null) shaderProgram = GL.createProgram();
		
		for (shader in createdShaders)
		{
			GL.attachShader(shaderProgram, shader);
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
	
	public function UpdateRenderedData():Void
	{
	
		
		
	}
	
	public function CleanRenderedData(index:Int):Void
	{
		if (index >= 0)
		{
			
	
			var attIndex:Int = 0;
			var visIndex:Int = index*verticesData.objectStride;
				
			
			GL.bindVertexArray(VAO);
			
			GL.bindBuffer(GL.ARRAY_BUFFER, VBO);
						
			utilFloatArray = new Float32Array(verticesData.objectStride);
			for (i in 0...verticesData.vertexPerObject)
			{
				//verIndex = i * 4;
				attIndex = i * verticesData.vertexStride;
				
				for (j in 0...verticesData.vertexStride)
				{
					verticesData.data[visIndex + attIndex + j] = utilFloatArray[attIndex+j] = 0;
				}
			
				
			}
		
			GL.bufferSubData(GL.ARRAY_BUFFER, index * utilFloatArray.byteLength, utilFloatArray.byteLength, utilFloatArray); 
			if(verticesData.activeDataCount >0)  verticesData.activeDataCount --;
		}
		else
		{
			for (i in 0...verticesData.data.length)
				verticesData.data[i] = 0;
			
				
			GL.bufferData(GL.ARRAY_BUFFER, verticesData.data.byteLength, verticesData.data, GL.DYNAMIC_DRAW);	
			verticesData.activeDataCount = 0;
			
			
		}
		GL.bindBuffer(GL.ARRAY_BUFFER, 0);
		GL.bindVertexArray(0); 				
		
	}
	
	public inline function AddData(data:Vector<Float>):Int
	{
		
		
		var index:Int = AllocateBufferIndex();
		AddDataAt(data, index);
		//trace(verticesData.activeDataCount);
		return index;
	}
	
	public inline function AddMultipleData(data:Vector<Float>):Array<Int>
	{
		var dataIndices:Array<Int> = [];
		var index:Int = 0;
		var util:Vector<Float> = new Vector(verticesData.vertexStride);
		for (i in 0...Std.int(data.length / verticesData.vertexStride))
		{
			for (j in 0...util.length)
				util[j] = data[i * verticesData.vertexStride + j];
					
			index = AllocateBufferIndex();
			AddDataAt(util, index);
			dataIndices.push(index);
		}		
		
		return dataIndices;
	}
	
	public function AddDataAt(data:Vector<Float>, index:Int):Void
	{
		
		
		var attIndex:Int = 0;
		var dataIndex:Int = 0;
			
		
		//enlarge the buffer data if too small	
		if (GetHigherIndex()  >= verticesData.size)
		{
		
			var newBufferData:Float32Array = new Float32Array(verticesData.objectStride * (GetHigherIndex()+1));
			
			if(verticesData.size > 0)
				for (i in 0...verticesData.data.length)
					newBufferData[i] = verticesData.data[i];
		
			verticesData.data = newBufferData;
			
			if (indicesPerObject > 0){
				
				//if (utilUIntArray == null) utilUIntArray = new UInt16Array();
				indicesData = new UInt16Array(indicesPerObject * (GetHigherIndex() + 1));
			
				for (i in 0...Math.round(indicesData.length / indicesPerObject)){
					attIndex = i * indicesPerObject ;
					for(j in 0...indicesPerObject)
						indicesData[attIndex+j] = indices[j] + i*vertices.length;
				}
				
				GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, EBO);
				GL.bufferData(GL.ELEMENT_ARRAY_BUFFER,indicesData.byteLength, indicesData, GL.DYNAMIC_DRAW);
			}
					
			
			GL.bindBuffer(GL.ARRAY_BUFFER, VBO);
			GL.bufferData(GL.ARRAY_BUFFER, verticesData.data.byteLength, verticesData.data, GL.DYNAMIC_DRAW);
			
			GL.bindBuffer(GL.ARRAY_BUFFER, 0);
			
			
		}
		
		
		GL.bindBuffer(GL.ARRAY_BUFFER, VBO);
		
		if (utilFloatArray == null) utilFloatArray = new Float32Array(verticesData.objectStride);
		
		dataIndex = index * verticesData.objectStride;
		
		for (i in 0...data.length)
			verticesData.data[dataIndex + i] = utilFloatArray[i] = data[i];
		
		GL.bufferSubData(GL.ARRAY_BUFFER, index * utilFloatArray.byteLength, utilFloatArray.byteLength, utilFloatArray); 

		GL.bindBuffer(GL.ARRAY_BUFFER, 0);
		GL.bindVertexArray(0);
			
		//var visu:Array<Float> = [];
			//for (i in 0...verticesData.data.length)
				//visu.push(verticesData.data[i]);
			//trace(visu);
		
	}
	
	public function AllocateBufferIndex():Int
	{
		//trace(bufferIndices);
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
		verticesData.activeDataCount++;
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
		
		if (index < bufferIndices.length && index >= 0){
			
			bufferIndices[index] = false;
			CleanRenderedData(index);
			
		}
		else if (index < 0)
		{
			for (i in 0...bufferIndices.length)
			bufferIndices[i] = false;
		}
			
		return -1;
		
	}
	
	public function Flush():Void
	{
		
		FreeBufferIndex( -1);
		CleanRenderedData( -1);
		
	}
	private inline function GetHigherIndex():Int
	{
		return bufferIndices.length - 1;
	}
	
	public inline function IsEmpty():Bool
	{
		return verticesData.activeDataCount == 0;
	}
	
	public function ToString():String
	{
		var visu:Array<Float> = [];
			for (i in 0...verticesData.data.length)
				visu.push(verticesData.data[i]);
			
		return visu.toString();
		
	}
	
	
	public function Render():Int
	{
		
		drawCount = 0;
		
		GL.useProgram(shaderProgram);
		GL.uniformMatrix4fv(GL.getUniformLocation(shaderProgram , "projection"), 1, false, renderer.projection);
			
		//GL.lineWidth(125);
		//GL.bindVertexArray(VAO);
		GL.bindBuffer(GL.ARRAY_BUFFER, VBO);
			
		var stride:Int = 0;
		for (attribute in vertexAttributes)
		{
			
			
			pointer = GL.getAttribLocation(shaderProgram, attribute.name);
			GL.enableVertexAttribArray(pointer);
			//GL.enableVertexAttribArray(attribute.index);
			//GL.vertexAttribPointer(attribute.index, attribute.size, GL.FLOAT, false, renderedData.vertexStride * Float32Array.BYTES_PER_ELEMENT, stride* Float32Array.BYTES_PER_ELEMENT);
			GL.vertexAttribPointer(pointer, attribute.size, GL.FLOAT, false, verticesData.vertexStride * Float32Array.BYTES_PER_ELEMENT, stride* Float32Array.BYTES_PER_ELEMENT);
			stride += attribute.size;
			
			
		}
		
			
		if (indicesPerObject > 0){
			GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, EBO);
			GL.bufferData(GL.ELEMENT_ARRAY_BUFFER, indicesData.byteLength, indicesData, GL.DYNAMIC_DRAW);
		}
		//
		
		for (batchCam in cameras)
		{
	
			var camera:Camera = BeardGame.Get().cameras[batchCam];
			//trace(camera.name);
			GL.scissor(camera.viewport.x,BeardGame.Get().window.height - camera.viewport.y - camera.viewport.height, camera.viewport.width, camera.viewport.height);
			
			
			renderer.view.identity();
			renderer.view.appendScale(camera.zoom, camera.zoom,1);
			//renderer.view.appendTranslation( -(camera.centerX - camera.viewportWidth * 0.5), -(camera.centerY - camera.viewportHeight * 0.5), 0);
			renderer.view.appendTranslation( (camera.viewportX + camera.viewportWidth *0.5) - camera.centerX, (camera.viewportY + camera.viewportHeight *0.5) - camera.centerY, 0);
			GL.uniformMatrix4fv(GL.getUniformLocation(shaderProgram , "view"), 1, false, renderer.view);
		
			
			if (indicesPerObject> 0){
				//trace(verticesData.activeDataCount);
				GL.drawElements(drawMode, indicesData.length, GL.UNSIGNED_SHORT, 0);
			}
			else
			{
				//trace(verticesData.activeDataCount);
				
				GL.drawArrays(drawMode, 0, verticesData.activeDataCount*verticesData.vertexPerObject);
			}
		
			drawCount++;
			
			
			var error:Int = GL.getError();
		
			if (error != 0)
				trace(error);
			
		}
			
		GL.bindVertexArray(0);
		
		return drawCount;
	}
}