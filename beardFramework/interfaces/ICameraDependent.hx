package beardFramework.interfaces;
import beardFramework.display.cameras.Camera;
import openfl._internal.renderer.RenderSession;

/**
 * @author Ludo
 */
interface ICameraDependent 
{
  
	
	public var restrictedCameras(default, null):Array<String>;
	public function AuthorizeCamera(addedCameraID : String):Void;
	public function ForbidCamera(forbiddenCameraID : String):Void;
	public function RenderThroughCamera(camera : Camera, renderSession:RenderSession):Void;
	
}