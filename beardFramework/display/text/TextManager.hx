package beardFramework.display.text;

/**
 * ...
 * @author 
 */
class TextManager 
{
	
	private static var instance(default, null):TextManager;
	
	public function new() 
	{
		
	}
	
	public static inline function Get():TextManager
	{
		if (instance == null)
		{
			instance = new TextManager();
			instance.Init();
		}
		
		return instance;
	}
	
	private function Init():Void
	{
		
		
		
	}
	
}