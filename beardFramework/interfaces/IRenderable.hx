package beardFramework.interfaces;
import lime.graphics.opengl.GLProgram;

/**
 * @author 
 */
interface IRenderable 
{
	public var name(get, set):String;
	public var z(get, set):Float;
	public var readyForRendering(get, null):Bool;
	public var shaderProgram(default, null):GLProgram;
	public var cameras:List<String>;
	public function Render():Int;


}