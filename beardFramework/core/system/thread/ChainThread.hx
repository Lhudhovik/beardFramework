package beardFramework.core.system.thread;

/**
 * ...
 * @author Ludo
 */
class ChainThread<T> extends CrossThread<T>
{

	public function new(timeLimit:Float) 
	{
		super(timeLimit);
		
	}
	
	override public function Proceed():Void 
	{
		if (threadedMethods.length > 0 && threadedMethods[0] != null){
			
			threadedMethods[0].allowedTime = allowedTime;
			
			if( threadedMethods[0].action(threadedMethods[0])){
				threadedMethods.remove(threadedMethods[0]);
			}
			
			if (threadedMethods.length == 0) completed.dispatch();
			
		}
		
	}
	
}