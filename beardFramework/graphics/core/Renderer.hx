package beardFramework.graphics.core;
import beardFramework.graphics.core.Framebuffer;
import beardFramework.graphics.screens.BeardLayer;
import beardFramework.graphics.objects.CameraQuad;
import beardFramework.graphics.objects.Visual;
import beardFramework.graphics.lights.Light;
import beardFramework.core.BeardGame;
import beardFramework.graphics.cameras.Camera;
import beardFramework.graphics.objects.RenderedObject;
import beardFramework.graphics.core.BatchedVisual;
import beardFramework.graphics.batches.Batch;
import beardFramework.graphics.batches.BatchRenderingData;
import beardFramework.graphics.lights.LightManager;
import beardFramework.graphics.shaders.RenderedDataBufferArray;
import beardFramework.graphics.shaders.Shader;
import beardFramework.graphics.text.BatchedTextField;
import beardFramework.graphics.text.TextField;
import beardFramework.graphics.ui.UIManager;
import beardFramework.interfaces.IBatch;
import beardFramework.interfaces.IRenderable;
import beardFramework.resources.assets.AssetManager;
import beardFramework.resources.options.GraphicSettings;
import beardFramework.utils.data.DataU;
import beardFramework.resources.MinAllocArray;
import beardFramework.utils.graphics.Color;
import beardFramework.utils.graphics.GLU;
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
	public var projection:Matrix4;
	public var rotationAxis(default,null):Vector4;
	public var boundBuffer:GLBuffer;
	public var ready(get, null):Bool = false;
	
	private var VAOCOUNT:Int = 1;
	private var BUFFERCOUNT:Int = 1;
	private var ATTRIBUTEPOINTER:Int = 0;
	private var renderables:MinAllocArray<IRenderable>;
	private var cameraQuads:MinAllocArray<CameraQuad>;
	private	var pointer:Int;
	private var blurFrameBufferH:Framebuffer;
	private var blurFrameBufferV:Framebuffer;
	private var blurShader:Shader;
	
	
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
				
		GL.enable(GL.DEPTH_TEST);
		GL.enable(GL.BLEND);
		
		GL.blendFunc(GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA);
		GL.enable(GL.SCISSOR_TEST);
		
		GL.viewport(0, 0, Application.current.window.width, Application.current.window.height);
		
		
		AssetManager.Get().AddTextureFromImage(StringLibrary.DEFAULT, new Image(null, 0, 0, 256, 256, Color.PURPLE), AssetManager.Get().AllocateFreeTextureIndex());
		
		renderables = new MinAllocArray();
		cameraQuads = new MinAllocArray();
		
		model = new Matrix4();
		projection = new Matrix4();
		projection.createOrtho( 0,BeardGame.Get().window.width, BeardGame.Get().window.height, 0, Renderer.Get().VISIBLEDEPTHLIMIT, -Renderer.Get().VISIBLEDEPTHLIMIT);
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

	public function AddRenderable(renderable:IRenderable, quick:Bool = false ):Void
	{
		for (i in 0...renderables.length)
			if (renderables.get(i).name == renderable.name) return;
		
		renderables.Push(renderable);
		
		#if debug
		MoveRenderableToLast(StringLibrary.DEBUG);
		#end
		if(!quick)
			MoveRenderableToLast(StringLibrary.UI);
	}
	
	public function AddCameraQuad(name:String, camera:String = null):CameraQuad
	{
		var existing:Bool = false;
		
		var quad: CameraQuad =null;
		
		
		for (i in 0...cameraQuads.length)
		{
			if (existing = (cameraQuads.get(i).name == name)){
				quad = 	cameraQuads.get(i);
				break;
			}
					
		}
	
		if (!existing)
		{
			quad = new CameraQuad(name);
			quad.camera = camera;
			cameraQuads.Push(quad);
		}
		
		return quad;
			
	}
	
	public function GetCameraQuad(name:String):CameraQuad
	{
		var quad:CameraQuad = null;
		
		for (i in 0...cameraQuads.length)
		{
			if (cameraQuads.get(i).name == name){
				quad = cameraQuads.get(i);
				break;
			}
				
		}
		
		return quad;
	}
	
	public function RemoveCameraQuad(name:String):Void
	{
				
		for (i in 0...cameraQuads.length)
		{
			if (cameraQuads.get(i).name == name){
				cameraQuads.RemoveByIndex(i);
				break;
			}
				
		}
		
	}
	
	inline public function RemoveRenderable(renderable:IRenderable, quick:Bool = false ):Void
	{
		
		renderables.Remove(renderable);
					
		#if debug
		MoveRenderableToLast(StringLibrary.DEBUG);
		#end
		if(!quick)
			MoveRenderableToLast(StringLibrary.UI);
	}
	
	public function Start():Void
	{
		ready = true;
		
		blurFrameBufferH = new Framebuffer("blurHorizontal");
		blurFrameBufferH.Bind();
		blurFrameBufferH.CreateTexture(StringLibrary.COLOR, BeardGame.Get().window.width, BeardGame.Get().window.height, GL.RGBA16F, GL.RGBA, GL.FLOAT, GL.COLOR_ATTACHMENT0);
		blurFrameBufferH.CheckStatus("blur1");
		blurFrameBufferH.UnBind();
	
		blurFrameBufferV = new Framebuffer("blurVertical");
		blurFrameBufferV.Bind();
		blurFrameBufferV.CreateTexture(StringLibrary.COLOR, BeardGame.Get().window.width, BeardGame.Get().window.height, GL.RGBA16F, GL.RGBA, GL.FLOAT, GL.COLOR_ATTACHMENT0);
		blurFrameBufferH.CheckStatus("blur2");
		blurFrameBufferV.UnBind();
		
		blurShader = Shader.GetShader(StringLibrary.BLUR);
		
		
		OnResize(Application.current.window.width, Application.current.window.height);
		
		
	}
	
	public function Render():Void
	{
		
		if (ready)
		{
	
			
			var renderable:IRenderable;
			drawCount = 0;
						
			var layer:BeardLayer;
			
			// 2D SHADOWS
			for (i in 0...BeardGame.Get().GetLayersCount())
			{
					layer = BeardGame.Get().GetLayer(i);
					
					for (light in LightManager.Get().lights)
					{
						for (object in layer.renderedObjects)
						{
							if(object.shadowCaster) object.CastShadow(light);
						}
				
					}
	
			}
			
			DepthSorting();
			
			// OBJECTS RENDER
			for (camera in BeardGame.Get().cameras)
			{
				
				camera.framebuffer.Bind();
				GL.enable(GL.DEPTH_TEST);
				GL.clearColor(camera.clearColor.getRedf(),camera.clearColor.getGreenf(), camera.clearColor.getBluef(),1);
				GL.clear(GL.COLOR_BUFFER_BIT | GL.DEPTH_BUFFER_BIT | GL.STENCIL_BUFFER_BIT);
				GL.viewport(0, 0, BeardGame.Get().window.width, BeardGame.Get().window.height);
				//GL.viewport(0, - Math.round(BeardGame.Get().window.height - camera.GetHeight()) , BeardGame.Get().window.width, BeardGame.Get().window.height);
								
				
				for (i in 0...renderables.length)
				{
					renderable = renderables.get(i);
								
					if (!renderable.readyForRendering || !renderable.HasCamera(camera.name) ) continue;

					drawCount += renderable.Render(camera);
				}
					
			}
		
			LightManager.Get().CleanLightStates();
			
			// BLUR
			var quad:CameraQuad;
			var framebuffer:Framebuffer;
			var horizontal:Bool = true;
			var firstTime:Bool = true;
			for (i in 0...cameraQuads.length)
			{
				blurFrameBufferH.Bind();
				GL.clearColor(1, 1, 1,0);
				GL.clear(GL.COLOR_BUFFER_BIT);
				blurFrameBufferV.Bind();
				GL.clearColor(1, 1, 1,0);
				GL.clear(GL.COLOR_BUFFER_BIT);
				
				quad = cameraQuads.get(i);
				quad.shader = blurShader;
				quad.shader.Use();
				framebuffer = blurFrameBufferH;
				for (i in 0...GraphicSettings.bloomIntensity)
				{
					framebuffer.Bind();
					quad.shader.SetInt(StringLibrary.HORIZONTAL, horizontal == true ? 1 : 0 );
					if (firstTime)
					{
						firstTime = false;
						quad.texture = BeardGame.Get().cameras[quad.camera].framebuffer.textures[StringLibrary.COLOR+1].texture;
					}	
					else{
						
						if(horizontal)
							quad.texture = blurFrameBufferV.textures[StringLibrary.COLOR].texture;
						else quad.texture = blurFrameBufferH.textures[StringLibrary.COLOR].texture;
					}
					quad.Render();
				
					horizontal = !horizontal;
					//
					if (framebuffer == blurFrameBufferH)
						framebuffer = blurFrameBufferV;
					else
						framebuffer = blurFrameBufferH;
					
				}
				
				quad.shader = Shader.GetShader(StringLibrary.CAMERA_QUAD);
				quad.texture =  BeardGame.Get().cameras[quad.camera].framebuffer.textures[StringLibrary.COLOR].texture;
				quad.bloom =  blurFrameBufferH.textures[StringLibrary.COLOR].texture;
			
				
			}
			
			// FINAL RENDER
			GL.bindFramebuffer(GL.FRAMEBUFFER, 0);
			GL.disable(GL.DEPTH_TEST);
			GL.clearColor(1, 1, 1,0);
			GL.clear(GL.COLOR_BUFFER_BIT);
			
			GL.viewport(0, 0, BeardGame.Get().window.width, BeardGame.Get().window.height);
			
			for (i in 0...cameraQuads.length)
			{
				cameraQuads.get(i).Render();
				
			}
			//TextField.quad.Render();

		}
		

			
	}
	
	public function OnResize(width:Int, height:Int):Void
	{
		GL.clearColor(0, 0, 0, 0);
		GL.viewport(0, 0, width, height);
		GL.scissor(0, 0, width, height);
		projection.createOrtho( 0,width, height, 0, Renderer.Get().VISIBLEDEPTHLIMIT, -Renderer.Get().VISIBLEDEPTHLIMIT);
		
		
		blurFrameBufferH.Bind();
		blurFrameBufferH.UpdateTextureSize("", width, height);
		blurFrameBufferH.UnBind();
		
		blurFrameBufferV.Bind();
		blurFrameBufferV.UpdateTextureSize("", width, height);
		blurFrameBufferV.UnBind();
		for (camera in BeardGame.Get().cameras)
			camera.AdjustResize();
		for (i in 0...cameraQuads.length)
		{
			cameraQuads.get(i).AdjustResize();
			
		}
			
		for (i in 0...renderables.length)
		{
						
			for (camera in renderables.get(i).cameras)
			{				
				renderables.get(i).shader.Use();
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
		if (renderable1 == null) result = 1;
		else if (renderable2 == null) result = -1;
		else if (renderable1.z < renderable2.z) result = 1;
		else if (renderable1.z > renderable2.z) result = -1;
		
		return result;	
	}
	
	
	function get_ready():Bool 
	{
		return ready;
	}
	
	
		
		
	
}

