package beardFramework.core.system.thread;

/**
 * ...
 * @author Ludo
 */
class CrossThread<T> extends Thread<T>
{
	var currentIndex:Int;
	public function new(timeLimit:Float) 
	{
		super(timeLimit);
		currentIndex = 0;
	}
	
	override public function Proceed():Void 
	{
		if (individualThreads.length > 0 && currentIndex < individualThreads.length && individualThreads[currentIndex] != null){
			
			individualThreads[currentIndex].allowedTime = allowedTime;
			
			if( individualThreads[currentIndex].action(individualThreads[currentIndex])){
				individualThreads.remove(individualThreads[currentIndex]);
				currentIndex--;
			}
			
			if (individualThreads.length == 0) completed.dispatch();
			
		}
		if (++currentIndex >= individualThreads.length) currentIndex = 0;
		
	}
	
}