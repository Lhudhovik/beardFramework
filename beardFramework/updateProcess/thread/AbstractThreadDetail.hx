package beardFramework.updateProcess.thread;

/**
 * ...
 * @author Ludo
 */
class AbstractThreadDetail 
{

	public var timeLimit:Float;
	public var startTime:Float;
	public var progression:Float=0;
	public var length:Int = 100;

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