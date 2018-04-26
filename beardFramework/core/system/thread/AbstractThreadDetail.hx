package beardFramework.core.system.thread;

/**
 * ...
 * @author Ludo
 */
class AbstractThreadDetail 
{

	public var timeLimit:Float;
	public var startTime:Float;
	public var progression:Float;

	private function new() 
	{
		
	}
	
	public inline function TimeExpired():Bool
	{
		return (Date.now().getTime() - startTime >= timeLimit);
		
	}
	
	public function Call():Bool
	{
		return true;
	}
	
	public function Clear():Void
	{
		
	}
	
	
}