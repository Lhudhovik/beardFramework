package beardFramework.graphics.rendering;
import beardFramework.core.BeardGame;
import beardFramework.graphics.cameras.Camera;
import beardFramework.graphics.rendering.shaders.Shader;
import beardFramework.resources.assets.AssetManager;
import beardFramework.resources.options.GraphicSettings;
import beardFramework.utils.graphics.GLU;
import beardFramework.utils.graphics.Alignment;
import beardFramework.utils.graphics.RatioAdjust;
import beardFramework.utils.libraries.StringLibrary;
import beardFramework.utils.math.MathU;
import beardFramework.utils.simpleDataStruct.SRect;
import beardFramework.utils.simpleDataStruct.SVec2;
import lime.graphics.opengl.GL;
import lime.graphics.opengl.GLBuffer;
import lime.graphics.opengl.GLTexture;
import lime.graphics.opengl.GLVertexArrayObject;
import lime.utils.Float32Array;
import lime.utils.UInt16Array;

/**
 * ...
 * @author 
 */
class CameraQuad 
{

	public var x(default, set):Float;
	public var y(default, set):Float;
	public var z:Float;
	public var name:String;
	public var width(get, set):Int;
	public var height(get, set):Int;
	public var scaleX:Float;
	public var scaleY:Float;
	public var rotation:Float;
	public var renderer:Renderer;
	public var drawMode:Int = GL.TRIANGLES;
	public var texture:GLTexture;
	public var shader:Shader;
	public var camera(default, set):String;
	public var uvsAlignment(default, set):Alignment;
	public var uvs:SRect;
	public var fullCamera(default, set):Bool = true;
	public var ratioAdjust(default, set):RatioAdjust = RatioAdjust.NONE;
	private var needUVUpdate:Bool = false;
	private var screenRatio:SRect;
	private var baseWidth:Int;
	private var baseHeight:Int;
	private var dimensionsRatio:Float;
	
	
	private static var verticesData:Float32Array; //overide with local variable if necessary
	private static var indices:UInt16Array;
	private static var VBO:GLBuffer;
	private static var EBO:GLBuffer;
	private static var VAO:GLVertexArrayObject;
	
	public function new(name:String) 
	{
		x = 0;
		y = 0;
		z = 0;
		scaleX = 1;
		scaleY = 1;
		screenRatio = {x:0, y:0, width: 1, height:1};
		baseWidth = BeardGame.Get().window.width;
		baseHeight =  BeardGame.Get().window.height;
		dimensionsRatio = 1;
		this.name = name;
		renderer = Renderer.Get();
		shader = Shader.GetShader(StringLibrary.CAMERA_QUAD);
		shader.Use();
		shader.SetMatrix4fv(StringLibrary.PROJECTION, renderer.projection);
		uvs = {x:0, y:0, width:1, height:1};
		if (VAO == null || VBO == null)
		{
			VAO = Renderer.Get().GenerateVAO();
		
			GL.bindVertexArray(VAO);
			
			VBO = Renderer.Get().GenerateBuffer();
			GL.bindBuffer(GL.ARRAY_BUFFER, VBO);
				
			GL.enableVertexAttribArray(0);
			GL.vertexAttribPointer(0, 3, GL.FLOAT, false, 3 * Float32Array.BYTES_PER_ELEMENT, 0);
			//----------------------------  x   y  z  
			verticesData = new Float32Array([0, 1, 0,
											1, 1, 0,
											1, 0, 0,
											0, 0, 0]);
			
			GL.bufferData(GL.ARRAY_BUFFER, verticesData.byteLength, verticesData, GL.DYNAMIC_DRAW);
			
			indices = new UInt16Array([0, 1, 2, 2, 3, 0]);
			
			EBO  = Renderer.Get().GenerateBuffer();
			
			GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, EBO);
			GL.bufferData(GL.ELEMENT_ARRAY_BUFFER, indices.byteLength, indices, GL.DYNAMIC_DRAW);
			
			
			GL.bindBuffer(GL.ARRAY_BUFFER, 0);
			GL.bindVertexArray(0);
			
			camera = StringLibrary.DEFAULT;
			uvsAlignment = Alignment.TOP_LEFT;
		}
		
		
		
		
		
	
		
	}
	
	public function AdjustResize():Void
	{
		switch(ratioAdjust)
		{
			
			case RatioAdjust.NONE :
								
			case RatioAdjust.KEEP_RATIO :
				
				var smallestWidth:Bool = BeardGame.Get().scaleX < BeardGame.Get().scaleY;
				var smallestScale:Float = smallestWidth ? BeardGame.Get().scaleX:BeardGame.Get().scaleY;
				
				if (smallestWidth){
					scaleY = screenRatio.width * BeardGame.Get().scaleX; 
					scaleX = screenRatio.height * BeardGame.Get().scaleY;
				}
				else{
					scaleX  = screenRatio.height * BeardGame.Get().scaleY;
					scaleY = screenRatio.width * BeardGame.Get().scaleX; 
				}
				dimensionsRatio = scaleY / scaleX;
			
			case RatioAdjust.KEEP_SIZE :
				scaleX =  screenRatio.width / BeardGame.Get().scaleX;
				scaleY =  screenRatio.height / BeardGame.Get().scaleY;
		
		}
			
		UpdateUVs();
	}
	
	public function UpdateUVs():Void
	{
		
		if (fullCamera)
		{
			uvs.x = 0;
			uvs.y = 0;
			uvs.width = uvs.height = 1;
			
		}
		else
		{
			uvs.width = width / BeardGame.Get().window.width;
			uvs.height = height / BeardGame.Get().window.height;		
			switch(uvsAlignment)
			{
				
				case TOP_LEFT: 
					uvs.x = 0;
					uvs.y = 0;
				case TOP:
					uvs.x = (1 -uvs.width ) *0.5;
					uvs.y = 0;
				case TOP_RIGHT: 
					uvs.x = 1 -uvs.width ;
					uvs.y = 0;
				case LEFT:
					uvs.x = 0;
					uvs.y = (1 -uvs.height ) *0.5;
				case CENTER: 
					uvs.x = (1 -uvs.width ) *0.5;
					uvs.y = (1 -uvs.height ) *0.5;
				case RIGHT: 
					uvs.x = 1 -uvs.width ;
					uvs.y = (1 -uvs.height ) *0.5;
				case BOTTOM_LEFT: 
					uvs.x = 0;
					uvs.y = 1 -uvs.height;
				case BOTTOM:
					uvs.x = (1 -uvs.width ) *0.5;
					uvs.y = 1 -uvs.height;
				
				case BOTTOM_RIGHT: 
					uvs.x = 1 -uvs.width ;
					uvs.y = 1 -uvs.height;
					
				case CUSTOM:	
			}		
		}
		
	}
	
	public function SetUVs(x:Float, y:Float, width:Float, height:Float):Void
	{
		uvsAlignment = Alignment.CUSTOM;
		uvs.x =MathU.Max( MathU.Abs(x), 1);		
		uvs.y =MathU.Max( MathU.Abs(y), 1);		
		uvs.width =MathU.Max( MathU.Abs(width), 1);		
		uvs.height = MathU.Max( MathU.Abs(height), 1);		
		needUVUpdate = true;
		
	}
	
	public function Render():Void 
	{
			//trace("render");
			if (needUVUpdate) UpdateUVs();
			//trace(uvs);
			if (shader == null) return;
			
			
			shader.Use();
			
			renderer.model.identity();
			renderer.model.appendScale(width, this.height, 1.0);
			renderer.model.appendTranslation(this.x, this.y,1);
			renderer.model.appendRotation(this.rotation, renderer.rotationAxis);
			shader.SetMatrix4fv(StringLibrary.MODEL, renderer.model);
			shader.SetFloat(StringLibrary.EXPOSURE, GraphicSettings.exposure);
			shader.SetFloat(StringLibrary.GAMMA, GraphicSettings.gamma);
			
			if (renderer.boundBuffer != VBO){
			
				shader.Use();
				
				GL.bindBuffer(GL.ARRAY_BUFFER, VBO);
				renderer.boundBuffer = VBO;
				
				GL.enableVertexAttribArray(0);
				GL.vertexAttribPointer(0, 3, GL.FLOAT, false, 3 * Float32Array.BYTES_PER_ELEMENT, 0);
						
				GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, EBO);
				GL.bufferData(GL.ELEMENT_ARRAY_BUFFER, indices.byteLength, indices, GL.DYNAMIC_DRAW);
			}
			
			if (texture != null){
				GL.activeTexture( GL.TEXTURE0 + AssetManager.Get().GetFreeTextureUnit());
				shader.SetInt("sampler", AssetManager.Get().GetFreeTextureUnit());	
				//GL.bindTexture(GL.TEXTURE_2D, texture);
				GL.bindTexture(GL.TEXTURE_2D, AssetManager.Get().GetTexture(StringLibrary.DEFAULT).glTexture);
				
				shader.Set4Float(StringLibrary.UVS, uvs.x, uvs.y, uvs.width, uvs.height);
			}

			GL.drawElements(drawMode, indices.length, GL.UNSIGNED_SHORT, 0);
			GLU.ShowErrors();
			
		}
	
	function set_camera(value:String):String 
	{
		if (value != camera)
		{
			var camera:Camera = BeardGame.Get().cameras[value];
			
			if ( camera != null)
			{
				texture = camera.framebuffer.textures[StringLibrary.COLOR].texture;
			}
			this.camera = value;
		}

		return camera;
	}
	
	function set_uvsAlignment(value:Alignment):Alignment 
	{
		if (value != uvsAlignment)
		{
			needUVUpdate = true;
		}
		return uvsAlignment = value;
	}
	
	function get_width():Int 
	{
		return Math.round(baseWidth * scaleX);
	}

	function get_height():Int 
	{
		return Math.round(baseHeight * scaleY);
	}
	
	function set_width(value:Int):Int 
	{
		if (value != width)
		{
			scaleX = value / baseWidth;
			needUVUpdate = true;
			screenRatio.width = value / BeardGame.Get().window.width;
			
			if (ratioAdjust == RatioAdjust.KEEP_RATIO)				
				scaleY = scaleX * dimensionsRatio;
			else
				dimensionsRatio = scaleY / scaleX;
			
		}
		return width;
	}
	
	function set_height(value:Int):Int 
	{
		if (value != height)
		{
			scaleY = value / baseHeight;
			needUVUpdate = true;
			screenRatio.height = value / BeardGame.Get().window.height;
			if (ratioAdjust == RatioAdjust.KEEP_RATIO)
				scaleX = scaleY / dimensionsRatio;
			else
				dimensionsRatio = scaleY / scaleX;
		}
		return height;
	}
	
	function set_fullCamera(value:Bool):Bool 
	{
		if (value != fullCamera )
		{
			fullCamera = value;
			UpdateUVs();
		}
		return fullCamera;
	}
	
	function set_x(value:Float):Float 
	{
		if (value != x)
		{
			x = value;
			screenRatio.x = x / BeardGame.Get().window.width;
		}
		return x;
	}
	
	function set_y(value:Float):Float 
	{
		if (value != y)
		{
			y = value;
			screenRatio.y = y / BeardGame.Get().window.height;
		}
		return y;
	}
	
	function set_ratioAdjust(value:RatioAdjust):RatioAdjust 
	{
		if (value != ratioAdjust && value == RatioAdjust.KEEP_RATIO)
			dimensionsRatio = scaleY / scaleX;
			
		
		return ratioAdjust = value;
	}
	
}
