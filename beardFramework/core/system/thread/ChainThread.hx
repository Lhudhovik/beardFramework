package beardFramework.core.system.thread;

using beardFramework.utils.SysPreciseTime;
/**
 * ...
 * @author Ludo
 */
class ChainThread extends Thread
{

	public function new(name:String, timeLimit:Float = 10) 
	{
		super(name,timeLimit);
		
	}
	
	override private function Proceed():Void 
	{
		var time:Float = Sys.preciseTime();
		var detail:AbstractThreadDetail;
	
		while (threadDetails.length > 0)
		{
			if ((detail = threadDetails.first())  != null){
				
				detail.startTime = Sys.preciseTime();
				detail.timeLimit = timeLimitPerFrame;
				
				if( detail.Call()){
					threadDetails.pop().Clear();
					progressed.dispatch(this);
				}
			}
			if ((Date.now().getTime() - time) > timeLimitPerFrame) break;
			
		}

		if (threadDetails.length == 0){
				completed.dispatch(this);
				Clear();
		}
		
	}
	
}