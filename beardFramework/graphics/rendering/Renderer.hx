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
import beardFramework.graphics.rendering.shaders.RenderedDataBufferArray;
import beardFramework.graphics.rendering.shaders.Shader;
import beardFramework.graphics.text.BatchedTextField;
import beardFramework.graphics.ui.UIManager;
import beardFramework.interfaces.IBatch;
import beardFramework.interfaces.IRenderable;
import beardFramework.resources.assets.AssetManager;
import beardFramework.utils.data.DataU;
import beardFramework.resources.MinAllocArray;
import beardFramework.utils.graphics.Color;
import beardFramework.utils.graphics.TextureU;
import beardFramework.utils.libraries.StringLibrary;
import beardFramework.utils.simpleDataStruct.SVec2;
import beardFramework.utils.simpleDataStruct.SVec3;
import lime.app.Application;
import lime.graphics.Image;
import lime.graphics.opengl.GL;
import lime.graphics.opengl.GLBuffer;
import lime.graphics.opengl.GLProgram;
import lime.graphics.opengl.GLQuery;
import lime.graphics.opengl.GLShader;
import lime.graphics.opengl.GLTexture;
import lime.graphics.opengl.GLVertexArrayObject;
import lime.math.Matrix4;
import lime.math.Vector2;
import lime.math.Vector4;
import lime.utils.Float32Array;
import lime.utils.UInt16Array;


@:access(lime.graphics.opengl.GL.GLObject)
/**
 * ...
 * @author 
 */
class Renderer 
{
	private static var instance:Renderer;
	
	
	
	public var VISIBLEDEPTHLIMIT(default, never):Int = 10;
	public var drawCount(default, null):Int = 0;
	public var model:Matrix4;
	public var rotationAxis(default,null):Vector4;
	public var boundBuffer:GLBuffer;
	public var ready(get, null):Bool = false;
	
	private var VAOCOUNT:Int = 1;
	private var BUFFERCOUNT:Int = 1;
	private var ATTRIBUTEPOINTER:Int = 0;
	private var renderables:MinAllocArray<IRenderable>;
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
		
		
		
		AssetManager.Get().AddTexture(StringLibrary.DEFAULT, new Image(null, 0, 0, 256, 256, Color.WHITE), AssetManager.Get().AllocateFreeTextureIndex());
		
		renderables = new MinAllocArray();
		
		model = new Matrix4();
		rotationAxis = new Vector4(0, 0, 1);
	}
	
	public function CreateBatch(name:String, template:String = "default" , needOrdering:Bool = false, addToBatchList:Bool = true):IBatch
	{
		var batch:IBatch = null;
		var template:BatchRenderingData = AssetManager.Get().GetTemplate(template);
		if (template != null)
		{
			batch = cast Type.createInstance(Type.resolveClass("beardFramework.graphics.rendering.batches."+template.type), []);
			if (batch != null)
			{
				batch.Init(template);
				batch.name = name;
				batch.needOrdering = needOrdering;
				if (addToBatchList) AddRenderable(batch);
				var unit:Int = 0;
				for (i in 0...AssetManager.Get().GetFreeTextureUnit())
				{
					GL.activeTexture(GL.TEXTURE0 + i);
					batch.shader.Use();
					if (GL.getUniformLocation(batch.shader.program, "atlas[" + i + "]") >= 0)
						batch.shader.SetInt("atlas[" +i + "]", i);
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
		MoveRenderableToLast(StringLibrary.DEBUG);
		#end
		MoveRenderableToLast(StringLibrary.UI);
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
			
			var renderable:IRenderable;
			drawCount = 0;
			
			for (camera in BeardGame.Get().cameras)
			{
				
				camera.framebuffer.Bind(GL.FRAMEBUFFER);
				GL.enable(GL.DEPTH_TEST);
				GL.clearColor(0, 0, 0,0);
				GL.clear(GL.COLOR_BUFFER_BIT);
				GL.clear(GL.DEPTH_BUFFER_BIT);
				GL.scissor(camera.viewport.x,BeardGame.Get().window.height - camera.viewport.y - camera.viewport.height, camera.viewport.width, camera.viewport.height);
				
				for (i in 0...renderables.length)
				{
					renderable = renderables.get(i);
								
					if (!renderable.readyForRendering || !renderable.HasCamera(camera.name) ) continue;
			
					drawCount+= renderable.Render(camera);
			
				}
			
				
				
				
			}
		
			LightManager.Get().CleanLightStates();
			
			GL.bindFramebuffer(GL.FRAMEBUFFER, 0);
			GL.disable(GL.DEPTH_TEST);
			GL.clearColor(1, 1, 1,0);
			GL.clear(GL.COLOR_BUFFER_BIT);
			GL.scissor(0,0, BeardGame.Get().window.width, BeardGame.Get().window.height);
			
			
			for (camera in BeardGame.Get().cameras)
			{
				if (camera.framebuffer != null && camera.framebuffer.quad != null)
				{
					camera.framebuffer.quad.x = camera.viewportX;
					camera.framebuffer.quad.y = camera.viewportY;
					camera.framebuffer.quad.width = camera.viewport.width;
					camera.framebuffer.quad.height = camera.viewport.height;
					camera.framebuffer.quad.Render();
					trace(camera.viewportWidth);
				}
				
			}
			
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
				
				renderables.get(i).shader.Use();
				BeardGame.Get().cameras[camera].projection.identity();
				BeardGame.Get().cameras[camera].projection.createOrtho( 0,Application.current.window.width, Application.current.window.height, 0, 10, -10);
				renderables.get(i).shader.SetMatrix4fv(StringLibrary.PROJECTION , BeardGame.Get().cameras[camera].projection);
			}
			
		}
		
		
	}
	
	public inline function GenerateVAO():GLVertexArrayObject
	{
		return  GLObject.fromInt(GLObjectType.VERTEX_ARRAY_OBJECT, VAOCOUNT++);
	}
	
	public inline function GenerateBuffer():GLBuffer
	{
		return GLObject.fromInt(GLObjectType.VERTEX_ARRAY_OBJECT, BUFFERCOUNT++);
		
	}
	
	
	public function UpdateAtlasTextureUnits(index:Int = 0):Void
	{
		for (i in 0...renderables.length){
			renderables.get(i).shader.Use();
			if (GL.getUniformLocation(renderables.get(i).shader.program, "atlas[" + index + "]") >= 0)
				renderables.get(i).shader.SetInt("atlas[" + index + "]", index);
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