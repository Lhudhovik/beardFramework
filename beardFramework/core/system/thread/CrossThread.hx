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
		if (threadedMethods.length > 0 && currentIndex < threadedMethods.length && threadedMethods[currentIndex] != null){
			
			threadedMethods[currentIndex].allowedTime = allowedTime;
			
			if( threadedMethods[currentIndex].action(threadedMethods[currentIndex])){
				threadedMethods.remove(threadedMethods[currentIndex]);
				currentIndex--;
			}
			
			if (threadedMethods.length == 0) completed.dispatch();
			
		}
		if (++currentIndex >= threadedMethods.length) currentIndex = 0;
		
	}
	
}