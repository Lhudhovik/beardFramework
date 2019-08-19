package beardFramework.interfaces;
import beardFramework.graphics.cameras.Camera;


/**
 * @author Ludo
 */
interface ICameraDependent extends ISpatialized
{
  
	
	public var restrictedCameras(default, null):Array<String>;
	public var cameras:List<String>;
	public function AuthorizeCamera(addedCameraID : String):Void;
	public function ForbidCamera(forbiddenCameraID : String):Void;
	//public function RenderThroughCamera(camera : Camera):Void;
	//public function RenderMaskThroughCamera(camera : Camera):Void;
	
}