package beardFramework.resources.memory;

/**
 * ...
 * @author Ludo
 */
class InstanceManager
{

	private static var instance:InstanceManager;
	private function new() 
	{
		
	}
	public static function get_instance():InstanceManager
	{
		if (instance == null)
		{
			instance = new InstanceManager();
			instance.Init();
		}
		
		return instance;
	}
	private function Init():Void
		{
			_pool = new Dictionary();
			
		}
	
	
	
}