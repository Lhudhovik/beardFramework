package beardFramework.graphics.rendering;
import beardFramework.core.BeardGame;
import beardFramework.resources.assets.AssetManager;
import beardFramework.utils.graphics.TextureU;
import lime.graphics.opengl.GL;
import lime.graphics.opengl.GLFramebuffer;
import lime.graphics.opengl.GLRenderbuffer;
import lime.graphics.opengl.GLTexture;

/**
 * ...
 * @author Ludovic
 */
class Framebuffer 
{
	private var nativeBuffer:GLFramebuffer;
	public var textures:Map<String,GLTexture>;
	public var renderbuffers:Map<String, GLRenderbuffer>;
	public var samplerIndex:Int;
	public var quad:FrameBufferQuad;
	public function new() 
	{
		nativeBuffer = GL.createFramebuffer();
		textures = new Map();
		renderbuffers = new Map();
		quad = new FrameBufferQuad();
		
	}
	
	public inline function Bind(target:Int):Void
	{
		GL.bindFramebuffer(target, nativeBuffer);
	}
	public inline function UnBind(target:Int):Void
	{
		GL.bindFramebuffer(target, 0);
	}
	
	
	public function CreateTexture(name:String, width:Int, height:Int, internalFormat:Int, format:Int, type:Int, attachment:Int, applyToQuad:Bool= false):Void
	{
		if (textures[name] == null)
		{
			samplerIndex = AssetManager.Get().GetFreeTextureUnit();
	
			var texture:GLTexture = GL.createTexture();
			GL.activeTexture(GL.TEXTURE0 + samplerIndex);
			GL.bindTexture(GL.TEXTURE_2D, texture);
			
			GL.texImage2D(GL.TEXTURE_2D, 0,internalFormat, width, height, 0,format,type, 0);
			
			GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.LINEAR);
			GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.LINEAR);
			GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.REPEAT);
			GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.REPEAT);
			
			GL.framebufferTexture2D(GL.FRAMEBUFFER, attachment, GL.TEXTURE_2D, texture, 0);
			
			textures[name] = texture;
			
			if (applyToQuad)
			{
				
				quad.texture = texture;
				
			}
		}
		
	}
	
	public function CreateRenderBuffer(name:String, target:Int, internalFormat:Int, width:Int, height:Int, attachment:Int):Void
	{
		
		if (renderbuffers[name] == null)
		{
			
			var buffer:GLRenderbuffer = GL.createRenderbuffer();
			GL.bindRenderbuffer(GL.RENDERBUFFER, buffer);
			GL.renderbufferStorage(target, internalFormat, width, height);
			GL.framebufferRenderbuffer(GL.FRAMEBUFFER, attachment, GL.RENDERBUFFER, buffer);
			renderbuffers[name] = buffer;		
			
			
		}
		
	}
	
	public function UpdateTextureSize(name:String, width:Int, height:Int):Void
	{
		GL.tex
	}
	
	public function CheckStatus():Void
	{
		if (GL.checkFramebufferStatus(GL.FRAMEBUFFER) != GL.FRAMEBUFFER_COMPLETE)
			trace("Framebuffer is not complete");
	}
	
}