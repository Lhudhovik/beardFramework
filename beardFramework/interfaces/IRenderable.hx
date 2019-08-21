package beardFramework.interfaces;
import beardFramework.graphics.cameras.Camera;
import beardFramework.graphics.lights.Light;
import beardFramework.graphics.shaders.Shader;
import lime.graphics.opengl.GLProgram;

/**
 * @author 
 */
interface IRenderable extends IBeardyObject
{
	public var depth(get, set):Float;
	public var canRender(get, set):Bool;
	public var shader(get, set):Shader;
	public var cameras:List<String>;
	public var lightGroup(default, set):String;
	public function Render(camera:Camera):Int;
	public function HasCamera(camera:String):Bool;
	
}