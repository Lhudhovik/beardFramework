package beardFramework.interfaces;
import beardFramework.display.cameras.Camera;
import openfl._internal.renderer.RenderSession;

/**
 * @author Ludo
 */
interface ICameraDependent 
{
  
	
	public var x(get,set):Float;
	public var y(get, set):Float;
	public var width(get,set):Float;
	public var height(get,set):Float;
	
	public var restrictedCameras(default, null):Array<String>;
	public var displayingCameras(default, null):List<String>;
	public function AuthorizeCamera(addedCameraID : String):Void;
	public function ForbidCamera(forbiddenCameraID : String):Void;
	public function RenderThroughCamera(camera : Camera, renderSession:RenderSession):Void;
	public function RenderMaskThroughCamera(camera : Camera, renderSession:RenderSession):Void;
	
}