package beardFramework.graphics.rendering;
import beardFramework.core.BeardGame;
import beardFramework.graphics.cameras.Camera;
import beardFramework.graphics.core.RenderedObject;
import beardFramework.graphics.core.Visual;
import beardFramework.graphics.rendering.batches.Batch;
import beardFramework.graphics.rendering.batches.BatchData;
import beardFramework.graphics.rendering.vertexData.RenderedDataBufferArray;
import beardFramework.graphics.text.TextField;
import beardFramework.utils.DataU;
import beardFramework.utils.MinAllocArray;
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
	#if debug	
	public var DEBUG(default, never):String = "debug";
	#end

	public var drawCount(default, null):Int = 0;
	public var projection:Matrix4;
	public var view:Matrix4;
	
	public var ready(get, null):Bool = false;
	public var model:Matrix4;
	private var batches:MinAllocArray<Batch>;
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
		
		
		#if debug
		//InitDebugBatch();
		#end
		//InitBatch(DEFAULT);
		
	}
	
	public function AddBatch(batch:Batch ):Void
	{
		for (i in 0...batches.length)
			if (batches.get(i).name == batch.name) return;
		
		batches.Push(batch);
		
		#if debug
		MoveBatchToLast(DEBUG);
		#end
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
			GL.clearColor(1, 0, 1, 1);
			GL.clear(GL.COLOR_BUFFER_BIT);
			GL.clear(GL.DEPTH_BUFFER_BIT);
			
			var batch:Batch;
			
			drawCount = 0;
			
			
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
		
	public function GetBatch(name:String):Batch
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