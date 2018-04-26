package beardFramework.core.system.thread;

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
	
	override private function Proceed():Void 
	{
		var time:Float =Sys.preciseTime();
		var individualTime :Float = this.timeLimitPerFrame / threadDetails.length;
		var detail:AbstractThreadDetail;
		
		while (threadDetails.length > 0)
		{
		
			if ((detail = threadDetails.first()) != null){
			
				detail.startTime = Sys.preciseTime();
				detail.timeLimit = individualTime;
				
				if( detail.Call()){
					threadDetails.pop().Clear();
					progressed.dispatch(this);
				}
				else
				{
					threadDetails.add(threadDetails.pop());
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