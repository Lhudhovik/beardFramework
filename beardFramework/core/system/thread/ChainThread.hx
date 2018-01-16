package beardFramework.core.system.thread;

/**
 * ...
 * @author Ludo
 */
class ChainThread<T> extends Thread<T>
{

	public function new(timeLimit:Float) 
	{
		super(timeLimit);
		
	}
	
	override public function Proceed():Void 
	{
		if (individualThreads.length > 0 && individualThreads[0] != null){
			
			individualThreads[0].allowedTime = allowedTime;
			
			if( individualThreads[0].action(individualThreads[0])){
				individualThreads.remove(individualThreads[0]);
			}
			
			if (individualThreads.length == 0) completed.dispatch();
			
		}
		
	}
	
}