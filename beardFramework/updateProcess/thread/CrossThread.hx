package beardFramework.updateProcess.thread;

using beardFramework.utils.SysPreciseTime;
/**
 * ...
 * @author Ludo
 */
class CrossThread extends Thread
{
	
	public function new(name:String, timeLimit:Float = 10) 
	{
		super(name,timeLimit);
		
	}
	
	override public function Proceed():Void 
	{
		var time:Float =Sys.preciseTime();
		var individualTime :Float = this.timePerUpdate / threadDetails.length;
		var detail:AbstractThreadDetail;
		
		while ((detail = threadDetails.first()) != null)
		{
		
			detail.startTime = Sys.preciseTime();
			detail.timeLimit = individualTime;
			
			if ( detail.Call()){
				progression += detail.progression/length;
				threadDetails.pop().Clear();
				progressed.dispatch();
			}
			else
			{
				progression += detail.progression/length;
				threadDetails.add(threadDetails.pop());
			}
		
			
			if ((Sys.preciseTime() - time) > timePerUpdate) break;
			
		}
		
		
		if (threadDetails.length == 0){
				completed.dispatch();
				Clear();
		}
	}
	
}