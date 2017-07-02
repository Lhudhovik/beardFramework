package beardFramework.interfaces;

/**
 * @author Ludo
 */
interface ICameraDependent 
{
  
	
	public var restrictedCameras(default, null):Array<String>;
	public function AuthorizeCamera(addedCameraID : String):Void;
	public function ForbidCamera(forbiddenCameraID : String):Void;
	
}