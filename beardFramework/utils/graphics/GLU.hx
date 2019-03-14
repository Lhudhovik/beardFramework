package beardFramework.utils.graphics;
import lime.graphics.opengl.GL;

/**
 * ...
 * @author 
 */
class GLU 
{

	static public function ShowErrors(location:String = "") 
	{
		
		var error:Int = GL.getError();
	
		if (error != 0)
			trace("OpenGL Error at " + location +  " " + error);
		
	}
	
}