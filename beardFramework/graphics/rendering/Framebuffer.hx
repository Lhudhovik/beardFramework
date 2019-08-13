package beardFramework.graphics.rendering;
import beardFramework.core.BeardGame;
import beardFramework.resources.assets.AssetManager;
import beardFramework.utils.graphics.GLU;
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
	public var textures:Map<String,FrameBufferTexture>;
	public var renderbuffers:Map<String, FrameBufferRenderBuffer>;
	public var samplerIndex:Int;
	public var name:String;
	//public var quad:Quad;
	public function new(name:String) 
	{
		nativeBuffer = GL.createFramebuffer();
		textures = new Map();
		renderbuffers = new Map();
		//quad = new Quad();
		this.name = name;
		
	}
	
	public inline function Bind(target:Int = GL.FRAMEBUFFER):Void
	{
		GL.bindFramebuffer(target, nativeBuffer);
	}
	public inline function UnBind(target:Int = GL.FRAMEBUFFER):Void
	{
		GLU.ShowErrors("Unbinding framebuffer previous");
		GL.bindFramebuffer(target, 0);
		GLU.ShowErrors("Unbinding framebuffer " + this);
	}
	
	
	public function CreateTexture(name:String, width:Int, height:Int, internalFormat:Int, format:Int, type:Int, attachment:Int):Void
	{
		if (textures[name] == null)
		{
			
			samplerIndex = AssetManager.Get().GetFreeTextureUnit();
	
			var texture:GLTexture = GL.createTexture();
			//GL.activeTexture(GL.TEXTURE0 + samplerIndex);
			GL.bindTexture(GL.TEXTURE_2D, texture);
			
			GL.texImage2D(GL.TEXTURE_2D, 0,internalFormat, width, height, 0,format,type, 0);
			
			GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.LINEAR);
			GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.LINEAR);
			GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.REPEAT);
			GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.REPEAT);
			
			GL.framebufferTexture2D(GL.FRAMEBUFFER, attachment, GL.TEXTURE_2D, texture, 0);
			GLU.ShowErrors("FrameBuffer");
			textures[name] = {
				texture:texture,
				internalFormat:internalFormat,
				format:format,
				type:type,
				attachment:attachment
			}
			
			//if (applyToQuad){
				//quad.texture = texture;
				//quad.width = width;
				//quad.height = height;
			//}

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
			renderbuffers[name] = {
				buffer:buffer,
				internalFormat:internalFormat,
				attachment:attachment	
			}
			
			
		}
		
	}
	
	public function UpdateTextureSize(name:String = "", width:Int, height:Int):Void
	{
		var frameTexture:FrameBufferTexture;
		if (name != "")
		{
			if (textures[name] != null)
			{
				frameTexture = textures[name];
				samplerIndex = AssetManager.Get().GetFreeTextureUnit();
				GL.activeTexture(GL.TEXTURE0 + samplerIndex);
				GL.bindTexture(GL.TEXTURE_2D,frameTexture.texture);
				GL.texImage2D(GL.TEXTURE_2D, 0,frameTexture.internalFormat, width, height, 0,frameTexture.format,frameTexture.type, 0);
				
			}
	
		}
		else
		{
			
			for (texture in textures)
			{
			
				samplerIndex = AssetManager.Get().GetFreeTextureUnit();
				GL.activeTexture(GL.TEXTURE0 + samplerIndex);
				GL.bindTexture(GL.TEXTURE_2D,texture.texture);
				GL.texImage2D(GL.TEXTURE_2D, 0,texture.internalFormat, width, height, 0,texture.format,texture.type, 0);
				
			}
			
		}
	}
	
	public function UpdateRenderBufferSize(name:String = "", width:Int, height:Int):Void
	{
		var buffer:GLRenderbuffer;
		if (name != "")
		{
			if (renderbuffers[name] != null)
			{
				buffer = renderbuffers[name].buffer;
				GL.bindRenderbuffer(GL.RENDERBUFFER, buffer);
				GL.renderbufferStorage(GL.RENDERBUFFER, renderbuffers[name].internalFormat, width, height);
				GL.bindRenderbuffer(GL.RENDERBUFFER, 0);
			}
	
		}
		else
		{
			
			for (renderBuffer in renderbuffers)
			{
			
				buffer = renderBuffer.buffer;
				GL.bindRenderbuffer(GL.RENDERBUFFER, buffer);
				GL.renderbufferStorage(GL.RENDERBUFFER, renderBuffer.internalFormat, width, height);
				GL.bindRenderbuffer(GL.RENDERBUFFER, 0);
				
			}
			
		}
	}
	
	
	public function CheckStatus(extraInfo:String = ""):Void
	{
		
		var status:String = extraInfo;
		switch(GL.checkFramebufferStatus(GL.FRAMEBUFFER))
		{
			case GL.FRAMEBUFFER_COMPLETE : status += "\nFramebuffer is complete";
			case GL.FRAMEBUFFER_INCOMPLETE_ATTACHMENT : status += "\nFramebuffer attachment is incomplete";
			case GL.FRAMEBUFFER_INCOMPLETE_DIMENSIONS : status += "\nFramebuffer dimensions are incomplete";
			case GL.FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT : status += "\nFramebuffer missing attachment";
			case GL.FRAMEBUFFER_INCOMPLETE_MULTISAMPLE : status += "\nFramebuffer multisample incomplete";
			case GL.FRAMEBUFFER_UNSUPPORTED : status += "\nFramebuffer is unsupported";
			case GL.FRAMEBUFFER_BINDING : status += "\nFramebuffer is binding";
			default : status += GL.checkFramebufferStatus(GL.FRAMEBUFFER);
			
		}
		trace(status);
		//if (GL.checkFramebufferStatus(GL.FRAMEBUFFER) != GL.FRAMEBUFFER_COMPLETE)
		//{
			//switch
			//trace("Framebuffer is not complete");
		//}
	}
	
}

typedef FrameBufferTexture =
{
	var texture:GLTexture;
	var internalFormat:Int;
	var format:Int;
	var type:Int;
	var attachment:Int;
	
	
}

typedef FrameBufferRenderBuffer =
{
	var buffer:GLRenderbuffer;
	var internalFormat:Int;
	var attachment:Int;
	
	
}
