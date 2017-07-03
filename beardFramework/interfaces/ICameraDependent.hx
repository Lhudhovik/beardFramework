package beardFramework.interfaces;
import beardFramework.displaySystem.cameras.Camera;

/**
 * @author Ludo
 */
interface ICameraDependent 
{
  
	
	public var restrictedCameras(default, null):Array<String>;
	public function AuthorizeCamera(addedCameraID : String):Void;
	public function ForbidCamera(forbiddenCameraID : String):Void;
	public function RenderThroughCamera(camera : Camera):Void;
	
}