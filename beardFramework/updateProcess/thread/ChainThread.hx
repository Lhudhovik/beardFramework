package beardFramework.updateProcess.thread;

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
	
	override public function Proceed():Void 
	{
		var time:Float = Sys.preciseTime();
		var detail:AbstractThreadDetail;
	
		while ((detail = threadDetails.first()) != null)
		{
			detail.startTime = Sys.preciseTime();
			detail.timeLimit = timePerUpdate;
			
			if ( detail.Call()){
				progression += detail.progression/length;
				threadDetails.pop().Clear();
				detail = null;
				progressed.dispatch();
			}
			
			else 
				progression += detail.progression/length;
			
			if (timePerUpdate == 0 || (Sys.preciseTime() - time) > timePerUpdate) break;
			
		}

		if (threadDetails.length == 0){
				completed.dispatch();
				Clear();
		}
		
	}
	
}