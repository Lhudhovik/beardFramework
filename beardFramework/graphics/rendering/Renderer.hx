package beardFramework.graphics.rendering;
import beardFramework.core.BeardGame;
import beardFramework.graphics.cameras.Camera;
import beardFramework.graphics.core.RenderedObject;
import beardFramework.graphics.core.BatchedVisual;
import beardFramework.graphics.rendering.Light.DirectionalLight;
import beardFramework.graphics.rendering.Light.PointLight;
import beardFramework.graphics.rendering.Light.SpotLight;
import beardFramework.graphics.rendering.batches.Batch;
import beardFramework.graphics.rendering.batches.BatchTemplateData;
import beardFramework.graphics.rendering.vertexData.RenderedDataBufferArray;
import beardFramework.graphics.text.BatchedTextField;
import beardFramework.graphics.ui.UIManager;
import beardFramework.interfaces.IBatch;
import beardFramework.utils.data.DataU;
import beardFramework.resources.MinAllocArray;
import beardFramework.utils.graphics.Color;
import beardFramework.utils.simpleDataStruct.SVec2;
import beardFramework.utils.simpleDataStruct.SVec3;
import lime.app.Application;
import lime.graphics.opengl.GL;
import lime.graphics.opengl.GLBuffer;
import lime.graphics.opengl.GLProgram;
import lime.graphics.opengl.GLQuery;
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
	public var UI(default, never):String = "UI";
	#if debug	
	public var DEBUG(default, never):String = "debug";
	#end

	public var drawCount(default, null):Int = 0;
	public var projection:Matrix4;
	public var view:Matrix4;
	
	public var ready(get, null):Bool = false;
	public var model:Matrix4;
	public var directionalLight:DirectionalLight;
	public var pointLight:PointLight;
	public var spotLight:SpotLight;
	
	private var batches:MinAllocArray<IBatch>;
	private var batchTemplates:Map<String, BatchTemplateData>;
	private	var pointer:Int;
	
	
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
	
		//GL.lineWidth(1);
		GL.enable(GL.SCISSOR_TEST);
		
		GL.viewport(0, 0, Application.current.window.width, Application.current.window.height);
		
		projection = new Matrix4();
		projection.identity();
		projection.createOrtho( 0, Application.current.window.width, Application.current.window.height, 0, 1, -1);
		view = new Matrix4();
		model = new Matrix4();
			
		batches = new MinAllocArray();
		batchTemplates = new Map();
		
		directionalLight = 
		{
			direction:{x:0, y:0, z:1},
			ambient: Color.RED,
			diffuse: Color.WHITE,
			specular: Color.BLUE
		}
		
		pointLight = 
		{
			position:{x:0, y:0, z:-50},
			ambient: Color.YELLOW,
			diffuse: Color.WHITE,
			specular: Color.WHITE,
			constant:1.0,
			linear:0.0014,
			quadratic:0.000007
			
		}
		
		spotLight = 
		{
			position:{x:0, y:0, z:-200},
			direction:{x:0, y:1, z:0},
			ambient: 0x010101ff,
			diffuse: Color.WHITE,
			specular: Color.WHITE,
			cutOff:25,
			outerCutOff:60
			
		}
		
		
		
		
	}
	public function CreateBatch(name:String, template:String = "default" , needOrdering:Bool = false, addToBatchList:Bool = true):IBatch
	{
		var batch:IBatch = null;
		if (batchTemplates[template] != null)
		{
			batch = cast Type.createInstance(Type.resolveClass("beardFramework.graphics.rendering.batches."+batchTemplates[template].type), []);
			batch.Init(batchTemplates[template]);
			batch.name = name;
			batch.needOrdering = needOrdering;
			if (addToBatchList) AddBatch(batch);
		}
		
		return batch;
		
	}

	public function AddBatch(batch:IBatch ):Void
	{
		for (i in 0...batches.length)
			if (batches.get(i).name == batch.name) return;
		
		batches.Push(batch);
		
		#if debug
		MoveBatchToLast(DEBUG);
		#end
		MoveBatchToLast(UI);
	}
	
	public inline function AddTemplate(templateData:BatchTemplateData):Void
	{
		if (templateData != null)
		{
			batchTemplates[templateData.name] = templateData;
		}
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
			GL.scissor(0,0, BeardGame.Get().window.width, BeardGame.Get().window.height);
			GL.clearColor(0, 0, 0,0);
			GL.clear(GL.COLOR_BUFFER_BIT);
			GL.clear(GL.DEPTH_BUFFER_BIT);
			
			var batch:IBatch;
			
			drawCount = 0;
			
			//trace(batches.toString());
			for (i in 0...batches.length)
			{
			
				
				batch = batches.get(i);
				
				if (batch.needUpdate) batch.UpdateRenderedData();
				if (batch.IsEmpty()) continue;
		
				//trace("go to render " + batch + " " +renderedData[batch].activeDataCount  );
				
				drawCount+= batch.Render();
			
			}
			
			//trace(drawCount);
		}
		

			
	}
	
	
	
	public function OnResize(width:Int, height:Int):Void
	{
		GL.viewport(0, 0, Application.current.window.width, Application.current.window.height);
		projection.identity();
		projection.createOrtho( 0,Application.current.window.width, Application.current.window.height, 0, 1, -1);
		
		for (i in 0...batches.length){
			GL.useProgram(batches.get(i).shaderProgram);
			GL.uniformMatrix4fv(GL.getUniformLocation(batches.get(i).shaderProgram, "projection"), 1, false, projection);
		}
		
		
	}
	
	public function GetFreeTextureIndex():Int
	{
		return FREETEXTUREINDEX;
	}
	
	public inline function GenerateVAO():GLVertexArrayObject
	{
		return  GLObject.fromInt(GLObjectType.VERTEX_ARRAY_OBJECT, VAOCOUNT++);
	}
	
	public inline function GenerateBuffer():GLBuffer
	{
		return GLObject.fromInt(GLObjectType.VERTEX_ARRAY_OBJECT, BUFFERCOUNT++);
		
	}
	
	public inline function AllocateFreeTextureIndex():Int
	{
		
		return FREETEXTUREINDEX++;
	}
	
	public function UpdateTexture(index:Int = 0):Void
	{
		for (i in 0...batches.length){
			GL.useProgram(batches.get(i).shaderProgram);
			GL.uniform1i(GL.getUniformLocation(batches.get(i).shaderProgram, "atlas[" + index + "]"), index);
		}
		
		
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
				batches.MoveByIndex(i, batches.length - 1);
				//trace("moved");
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
		
	public function GetBatch(name:String):IBatch
	{
		for (i in 0...batches.length)
			if (batches.get(i).name == name) return batches.get(i);
			
		return null;
	}
	
	function get_ready():Bool 
	{
		return ready;
	}
	
	
		
		
	
}

//typedef Batch =
//{
	//public var name:String;
	//public var needOrdering:Bool;
//}