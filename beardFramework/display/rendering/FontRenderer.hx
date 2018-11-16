package beardFramework.display.rendering;
import beardFramework.core.BeardGame;
import beardFramework.display.cameras.Camera;
import beardFramework.display.core.BeardLayer;
import beardFramework.display.core.BeardLayer.BeardLayerType;
import beardFramework.display.core.TextField;
import beardFramework.display.core.Visual;
import beardFramework.display.rendering.vertexData.VisualDataBufferArray;
import beardFramework.resources.assets.AssetManager;
import beardFramework.text.FontFormat;
import beardFramework.utils.DataUtils;
import haxe.ds.Vector;
import lime.app.Application;
import lime.graphics.Image;
import lime.graphics.opengl.GL;
import lime.graphics.opengl.GLBuffer;
import lime.graphics.opengl.GLProgram;
import lime.graphics.opengl.GLShader;
import lime.graphics.opengl.GLTexture;
import lime.graphics.opengl.GLVertexArrayObject;
import lime.math.Matrix4;
import lime.math.Vector4;
import lime.text.Font;
import lime.text.Glyph;
import lime.text.GlyphMetrics;
import lime.utils.Float32Array;
import lime.utils.UInt16Array;
import openfl.display.BitmapData;

@:access(lime.graphics.opengl.GL)
	
/**
 * ...
 * @author 
 */
class FontRenderer extends DefaultRenderer
{

	private static var instance:FontRenderer;
	
	public function new() 
	{
		super();
	}
	
	override function Init():Void 
	{
		//super.Init();
		fragmentShader = "fontFragmentShader";
		
	}
	
	
	
	public static inline function Get():FontRenderer
	{
		if (instance == null)
		{
			instance = new FontRenderer();
			instance.Init();
		}
		
		return instance;
	}
	
	override public function Start():Void 
	{
		super.Start();
	}
}