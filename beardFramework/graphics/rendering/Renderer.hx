package beardFramework.graphics.rendering;
import beardFramework.graphics.core.Visual;
import beardFramework.graphics.rendering.lights.Light;
import beardFramework.core.BeardGame;
import beardFramework.graphics.cameras.Camera;
import beardFramework.graphics.core.RenderedObject;
import beardFramework.graphics.core.BatchedVisual;
import beardFramework.graphics.rendering.batches.Batch;
import beardFramework.graphics.rendering.batches.BatchRenderingData;
import beardFramework.graphics.rendering.lights.LightManager;
import beardFramework.graphics.rendering.vertexData.RenderedDataBufferArray;
import beardFramework.graphics.text.BatchedTextField;
import beardFramework.graphics.ui.UIManager;
import beardFramework.interfaces.IBatch;
import beardFramework.interfaces.IRenderable;
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
	private static var FREETEXTUREUNIT:Int = 0;
	private static var ATTRIBUTEPOINTER:Int = 0;
	private static var instance:Renderer;

	
	public var DEFAULT(default, never):String = "default";
	public var UI(default, never):String = "UI";
	public var VISIBLEDEPTHLIMIT(default, never):Int = 10;
	#if debug	
	public var DEBUG(default, never):String = "debug";
	#end

	public var drawCount(default, null):Int = 0;
	public var projection:Matrix4;
	public var view:Matrix4;
	public var boundBuffer:GLBuffer;
	
	public var ready(get, null):Bool = false;
	public var model:Matrix4;
	
	private var renderables:MinAllocArray<IRenderable>;
	private var batchTemplates:Map<String, BatchRenderingData>;
	private	var pointer:Int;
	
	public var atlasTextureUnits:Map<String, Int>;
	
	
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
		
		Visual.InitSharedGraphics();
		
		renderables = new MinAllocArray();
		batchTemplates = new Map();
		atlasTextureUnits = new Map();

		
		
		
	}
	public function CreateBatch(name:String, template:String = "default" , needOrdering:Bool = false, addToBatchList:Bool = true):IBatch
	{
		var batch:IBatch = null;
		if (batchTemplates[template] != null)
		{
			batch = cast Type.createInstance(Type.resolveClass("beardFramework.graphics.rendering.batches."+batchTemplates[template].type), []);
			if (batch != null)
			{
				batch.Init(batchTemplates[template]);
				batch.name = name;
				batch.needOrdering = needOrdering;
				if (addToBatchList) AddRenderable(batch);
				var unit:Int = 0;
				for (atlas in atlasTextureUnits.keys())
				{
					GL.activeTexture(GL.TEXTURE0 + atlasTextureUnits[atlas]);
					GL.useProgram(batch.shaderProgram);
					if (GL.getUniformLocation(batch.shaderProgram, "atlas[" + atlasTextureUnits[atlas] + "]") >= 0)
						GL.uniform1i(GL.getUniformLocation(batch.shaderProgram, "atlas[" + atlasTextureUnits[atlas] + "]"), atlasTextureUnits[atlas]);
				}
			
			}
			
			
		}
		
		return batch;
		
	}

	public function AddRenderable(renderable:IRenderable ):Void
	{
		for (i in 0...renderables.length)
			if (renderables.get(i).name == renderable.name) return;
		
		renderables.Push(renderable);
		
		#if debug
		MoveRenderableToLast(DEBUG);
		#end
		MoveRenderableToLast(UI);
	}
	
	public inline function AddTemplate(templateData:BatchRenderingData):Void
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
			DepthSorting();
			
			GL.scissor(0,0, BeardGame.Get().window.width, BeardGame.Get().window.height);
			GL.clearColor(0, 0, 0,0);
			GL.clear(GL.COLOR_BUFFER_BIT);
			GL.clear(GL.DEPTH_BUFFER_BIT);
			
			var renderable:IRenderable;
						
			drawCount = 0;
			
			//trace(batches.toString());
			for (i in 0...renderables.length)
			{
			
				
				renderable = renderables.get(i);
							
				if (!renderable.readyForRendering) continue;
		
				//trace("go to render " + batch + " " +renderedData[batch].activeDataCount  );
				
				drawCount+= renderable.Render();
			
			}
			
			LightManager.Get().CleanLightStates();
			
			//trace(drawCount);
		}
		

			
	}
	
	
	
	public function OnResize(width:Int, height:Int):Void
	{
		GL.viewport(0, 0, Application.current.window.width, Application.current.window.height);
		
	
		for (i in 0...renderables.length)
		{
			
			for (camera in renderables.get(i).cameras)
			{
				
				GL.useProgram(renderables.get(i).shaderProgram);
				BeardGame.Get().cameras[camera].projection.identity();
				BeardGame.Get().cameras[camera].projection.createOrtho( 0,Application.current.window.width, Application.current.window.height, 0, 10, -10);
				GL.uniformMatrix4fv(GL.getUniformLocation(renderables.get(i).shaderProgram, "projection"), 1, false, BeardGame.Get().cameras[camera].projection);
			}
			
		}
		
		
	}
	
	public function GetFreeTextureUnit():Int
	{
		return FREETEXTUREUNIT;
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
		
		return FREETEXTUREUNIT++;
	}
	
	public function UpdateTextureUnits(atlas:String, index:Int = 0):Void
	{
		atlasTextureUnits[atlas] = index;
		
		for (i in 0...renderables.length){
			GL.useProgram(renderables.get(i).shaderProgram);
			if (GL.getUniformLocation(renderables.get(i).shaderProgram, "atlas[" + index + "]") >= 0)
				GL.uniform1i(GL.getUniformLocation(renderables.get(i).shaderProgram, "atlas[" + index + "]"), index);
		}
		
		
	}
	
	public function MoveRenderableToFirst(renderable:String):Void
	{
			
		for (i in 0...renderables.length)
		{
			if (renderables.get(i).name == renderable)
			{
				renderables.MoveByIndex(i, 0);
				break;
			}
		}
		
	}
	
	public function MoveRenderableToLast(renderable:String):Void
	{
		for (i in 0...renderables.length)
		{
			if (renderables.get(i).name == renderable)
			{
				renderables.MoveByIndex(i, renderables.length - 1);
				//trace("moved");
				break;
			}
		}
	}
	
	public function MoveRenderableUp(renderable:String):Void
	{
		
		for (i in 0...renderables.length)
		{
			if (renderables.get(i).name == renderable && i < renderables.length-1)
			{
				renderables.MoveByIndex(i, i+1);
				break;
			}
		}
		
	}
	
	public function MoveRenderableDown(renderable:String):Void
	{
		for (i in 0...renderables.length)
		{
			if (renderables.get(i).name == renderable && i > 0)
			{
				renderables.MoveByIndex(i, i-1);
				break;
			}
		}
		
	}
		
	public function GetRenderable(name:String):IRenderable
	{
		for (i in 0...renderables.length)
			if (renderables.get(i).name == name) return renderables.get(i);
			
		return null;
	}
	
	public function GetTemplate(name:String):BatchRenderingData
	{
		return batchTemplates[name];
	}
	
	public function DepthSorting():Void
	{
		renderables.Sort(DepthSortingFunction);
	}
	
	private function DepthSortingFunction(renderable1:IRenderable, renderable2:IRenderable):Int
	{
		var result:Int = 0;
		if (renderable1.z < renderable2.z) result = 1;
		else if (renderable1.z > renderable2.z) result = -1;
		else result = 0;
		
		return result;	
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