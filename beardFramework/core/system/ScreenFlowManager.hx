package beardFramework.core.system;

/**
 * ...
 * @author Ludo
 */
class ScreenFlowManager
{
	private static var instance(get, null):ScreenFlowManager;
	
	private function new() 
	{
		
	}
	public static function get_instance():ScreenFlowManager
	{
		if (instance == null)
		{
			instance = new ScreenFlowManager();
			instance.Init();
		}
		
		return instance;
	}
	
	private function Init():Void
	{
		
	}
	
}