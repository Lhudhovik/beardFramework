package beardFramework.graphics.batches;
import beardFramework.core.BeardGame;
import beardFramework.graphics.cameras.Camera;
import beardFramework.graphics.core.Renderer;
import beardFramework.graphics.objects.RenderedObject;
import beardFramework.graphics.lights.Light;
import beardFramework.graphics.lights.LightManager;
import beardFramework.graphics.shaders.RenderedDataBufferArray;
import beardFramework.graphics.shaders.Shader;
import beardFramework.graphics.shaders.Shader.NativeShader;
import beardFramework.graphics.shaders.VertexAttribute;
import beardFramework.interfaces.IBatch;
import beardFramework.interfaces.IBatchable;
import beardFramework.resources.MinAllocArray;
import beardFramework.resources.assets.AssetManager;
import beardFramework.utils.graphics.Color;
import beardFramework.utils.graphics.GLU;
import beardFramework.utils.libraries.StringLibrary;
import beardFramework.utils.math.MathU;
import haxe.ds.Vector;
import lime.graphics.opengl.GL;
import lime.graphics.opengl.GLBuffer;
import lime.graphics.opengl.GLProgram;
import lime.graphics.opengl.GLShader;
import lime.graphics.opengl.GLVertexArrayObject;
import lime.math.Vector4;
import lime.utils.Float32Array;
import lime.utils.UInt16Array;

/**
 * ...
 * @author 
 */
@:keepSub class Batch implements IBatch
{

	private static var nullPtr:Float32Array = null;
	@:isVar public var name(get, set):String;
	@:isVar public var z(get, set):Float;
	@:isVar public var shader(get, set):Shader;
	
	public var isActivated:Bool;
	public var needUpdate:Bool;
	public var needOrdering:Bool;
	public var readyForRendering(get, null):Bool;
	public var cameras:List<String>;
	public var drawMode:Int;
	public var lightGroup(default, set):String;
	
	public var vertices:Vector<Float>; //implement as you like on each batch class
	private var indices:Vector<Int>;
	private var vertexAttributes:Vector<VertexAttribute>;
	private var bufferIndices:Array<BufferIndexData>;
	private var EBO:GLBuffer;
	private var VBO:GLBuffer;
	private var VAO:GLVertexArrayObject;
	private var verticesData:RenderedDataBufferArray;
	private var indicesData:UInt16Array;
	
	private var dirtyObjects:MinAllocArray<IBatchable>;
	private var atlases:Map<String, Int>;
	
	public var lightGroupChanged:Bool;
	private var utilFloatArray:Float32Array;
	private var utilUIntArray:UInt16Array;
	private	var pointer:Int;
	private	var indicesPerObject:Int;
	private var renderer:Renderer;
	private var drawCount:Int = 0;

	public function new() 
	{
	
	}
	
	public function Init( batchData:BatchRenderingData):Void
	{
		renderer = Renderer.Get();
		drawMode = batchData.drawMode;
		needUpdate = false;
		indicesPerObject = 0;
		verticesData = new RenderedDataBufferArray(batchData.vertexStride, batchData.vertexPerObject);
		bufferIndices = new Array<BufferIndexData>();
		z = batchData.z;	
		
		
		dirtyObjects = new MinAllocArray<IBatchable>();
		cameras = new List();
		
		
		cameras.add(StringLibrary.DEFAULT);
		
		trace(batchData.shader);
		shader = Shader.GetShader(batchData.shader);
		shader.Use();
		
		InitVertices(batchData.vertices, batchData.indices);
		InitBuffers(batchData.vertexAttributes, batchData.vertexStride);
		
		
		
		for (camera in cameras)
		{
			shader.SetMatrix4fv(StringLibrary.PROJECTION, BeardGame.Get().cameras[camera].projection);
			shader.SetMatrix4fv(StringLibrary.VIEW, BeardGame.Get().cameras[camera].view);
		}
		
		atlases = new Map();
		lightGroup = batchData.lightGroup;
	}
	
	public function InitVertices(vertices: Array<Float> , indices:Array<Int> = null):Void
	{
		
		indicesData = new UInt16Array(indices);
		this.indices = Vector.fromArrayCopy(indices);
		indicesPerObject = (indices != null? indices.length : 0);
		//trace(indices);
		this.vertices = Vector.fromArrayCopy(vertices);
	
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
				GL.bindAttribLocation(shader.program, attribute.index, attribute.name);
				stride+= attribute.size;
			}
			
		}
		else{
			vertexAttributes = new Vector(1);
			GL.enableVertexAttribArray(0);
			GL.vertexAttribPointer(0, 3, GL.FLOAT, false, 3 * Float32Array.BYTES_PER_ELEMENT, 0);
			GL.bindAttribLocation(shader.program, 0, "pos");
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
	
	public function OrderVerticesData():Void
	{
				
	}
	
	public inline function HasCamera(camera:String):Bool
	{
		var result:Bool = false;
		
		for (name in cameras)
			if (name == camera)
			{
				result = true;
				break;
			}
		
		return result;
		
	}
	
	public function CleanRenderedData(index:Int):Void
	{
		if (index >= 0)
		{
			
	
			var attIndex:Int = 0;
			var visIndex:Int = bufferIndices[index].bufferIndex *verticesData.objectStride;
				
			
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
		
			GL.bufferSubData(GL.ARRAY_BUFFER, bufferIndices[index].bufferIndex * utilFloatArray.byteLength, utilFloatArray.byteLength, utilFloatArray); 
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
		
		dataIndex = bufferIndices[index].bufferIndex * verticesData.objectStride;
		
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
	
	public function AllocateBufferIndex(index:Int = -1):Int
	{
	
		
		var length:Int = bufferIndices.length;
		
		if (index > -1 ){
			
			if (index < bufferIndices.length)	bufferIndices[index].used = true;
			else return -1;
		}
		else
		{
			for (i in 0...length)
				if (bufferIndices[i].used == false)
				{
					bufferIndices[i].used = true;
					index = i;
					break;
				}
		
			if (index == -1)
			{
				bufferIndices.push({used:true, bufferIndex:length});
				index = length;
			}
			
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
			if (bufferIndices[i].used == false)
			{
				bufferIndices[i].used = true;
				indices.push(i);
				count--;
				
				if (count == 0) break;
			}
		
		while (count-- > 0)
		{
			bufferIndices.push({used:true, bufferIndex:length});
			indices.push(length);
			length++;
		}
		
		return indices;
		
	}
	
	public function GetFreeBufferIndex():Int
	{
		var index:Int = -1;
		var length:Int = bufferIndices.length;
		
		for (i in 0...length)
			if (bufferIndices[i].used == false)
			{
				index = i;
				break;
			}
		
		return index;
		
	}
	
	public inline function FreeBufferIndex(index:Int):Int
	{
		
		if (index < bufferIndices.length && index >= 0){
			
			bufferIndices[index].used = false;
			CleanRenderedData(index);
			
		}
			
		return -1;
		
	}
	
	public inline function FreeAllBufferIndices():Void
	{
		for (i in 0...bufferIndices.length)
			bufferIndices[i].used = false;
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
	
	public function ToString():String
	{
		var visu:Array<Float> = [];
			for (i in 0...verticesData.data.length)
				visu.push(verticesData.data[i]);
			
		return visu.toString();
		
	}
	
	public inline function AddDirtyObject(object:IBatchable):Void
	{
		if (dirtyObjects.IndexOf(object) == -1)
		{
			dirtyObjects.Push(object);
			needUpdate = true;
		}
	}
	
	public function RemoveDirtyObject(object:IBatchable):Void
	{
		dirtyObjects.Remove(object);
	}
	
	public function Render(camera:Camera):Int
	{
		
	
		drawCount = 0;
		
		if (needUpdate) UpdateRenderedData();
		
		shader.Use();
	
		GL.bindBuffer(GL.ARRAY_BUFFER, VBO);
		renderer.boundBuffer = VBO;
		
		var stride:Int = 0;
		for (attribute in vertexAttributes)
		{
			pointer = GL.getAttribLocation(shader.program, attribute.name);
			GL.enableVertexAttribArray(pointer);
			GL.vertexAttribPointer(pointer, attribute.size, GL.FLOAT, false, verticesData.vertexStride * Float32Array.BYTES_PER_ELEMENT, stride* Float32Array.BYTES_PER_ELEMENT);
			stride += attribute.size;
		}
					
		if (indicesPerObject > 0){
			GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, EBO);
			GL.bufferData(GL.ELEMENT_ARRAY_BUFFER, indicesData.byteLength, indicesData, GL.DYNAMIC_DRAW);
		}
		
		LightManager.Get().CompileLights(shader, lightGroup, lightGroupChanged);
			
		lightGroupChanged = false;
	
	
		shader.SetMatrix4fv(StringLibrary.PROJECTION, camera.projection);
		shader.SetMatrix4fv(StringLibrary.VIEW, camera.view);
			
			
		if (indicesPerObject > 0) GL.drawElements(drawMode, indicesData.length, GL.UNSIGNED_SHORT, 0);
		else GL.drawArrays(drawMode, 0, verticesData.activeDataCount*verticesData.vertexPerObject);
		
	
		drawCount++;
		
		GLU.ShowErrors();
		
		
			
		//GL.bindVertexArray(0);
		
		return drawCount;
	}
	
	
	public function CastShadow(light:Light, camera:Camera):Void
	{
		
	
		//drawCount = 0;
		
		//if (needUpdate) UpdateRenderedData();
		
		var usedShader:Shader = LightManager.Get().shadowShader;
		
		usedShader.Use();
		
		usedShader.SetInt("useModel", 0);
	
		
		usedShader.Set3Float("lightPos", light.x, light.y, light.z);
		usedShader.SetFloat("groundY", 100);
		usedShader.SetFloat("groundAngle", 10);
		
		GL.bindBuffer(GL.ARRAY_BUFFER, VBO);
		renderer.boundBuffer = VBO;
		
		
		var attribute = vertexAttributes[0];
		pointer = GL.getAttribLocation(shader.program, attribute.name);
		GL.enableVertexAttribArray(pointer);
		GL.vertexAttribPointer(pointer, attribute.size, GL.FLOAT, false, verticesData.vertexStride * Float32Array.BYTES_PER_ELEMENT, 0);
			
					
		if (indicesPerObject > 0){
			GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, EBO);
			GL.bufferData(GL.ELEMENT_ARRAY_BUFFER, indicesData.byteLength, indicesData, GL.DYNAMIC_DRAW);
		}
		
		//LightManager.Get().CompileLights(shader, lightGroup, lightGroupChanged);
			
		//lightGroupChanged = false;
	
	
		usedShader.SetMatrix4fv(StringLibrary.PROJECTION, camera.projection);
		usedShader.SetMatrix4fv(StringLibrary.VIEW, camera.view);
			
			
		if (indicesPerObject > 0) GL.drawElements(drawMode, indicesData.length, GL.UNSIGNED_SHORT, 0);
		else GL.drawArrays(drawMode, 0, verticesData.activeDataCount*verticesData.vertexPerObject);
		
	
		//drawCount++;
		
		GLU.ShowErrors();
		
		
			
		//GL.bindVertexArray(0);
		
		//return drawCount;
	}
	
	/* INTERFACE beardFramework.interfaces.IBatch */
	
	public function IsEmpty():Bool 
	{
		return !readyForRendering;
	}
	
	
	/* INTERFACE beardFramework.interfaces.IBatch */
	
	public function AddAtlas(atlas:String):Void 
	{
		if (atlases[atlas] == null) atlases[atlas] = 0;
		atlases[atlas]++;
	}
	
	public function RemoveAtlas(atlas:String):Void 
	{
		if (atlases[atlas] != null)
		{
			if (atlases[atlas] > 0) atlases[atlas]--;
			if (atlases[atlas] == 0) atlases.remove(atlas);
			
		}
		
		
	}
	
	
	
	
	public function Destroy():Void 
	{
		
	}
	
	
	/* INTERFACE beardFramework.interfaces.IBatch */
	
	@:isVar public var group(get, set):String;
	
	function get_group():String 
	{
		return group;
	}
	
	function set_group(value:String):String 
	{
		return group = value;
	}
	
	
	/* INTERFACE beardFramework.interfaces.IBatch */
	
	@:isVar public var depth(get, set):Float;
	
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
	
	
	
	function set_lightGroup(value:String):String 
	{
		if (lightGroup != value) lightGroupChanged = true;
		return lightGroup = value;
	}
	
	inline function get_name():String 
	{
		return name;
	}
	
	inline function set_name(value:String):String 
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
	
	function get_readyForRendering():Bool 
	{
		return verticesData.activeDataCount != 0;
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

typedef BufferIndexData =
{
	public var used:Bool;
	public var bufferIndex:Int;
}