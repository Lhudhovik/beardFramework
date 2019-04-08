package beardFramework.interfaces;
import beardFramework.graphics.rendering.shaders.Shader;
import lime.graphics.opengl.GLProgram;

/**
 * @author 
 */
interface IRenderable 
{
	public var name(get, set):String;
	public var z(get, set):Float;
	public var readyForRendering(get, null):Bool;
	public var shader(default, null):Shader;
	public var cameras:List<String>;
	public var lightGroup(default, set):String;
	public function Render():Int;
	


}