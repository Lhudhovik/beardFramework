package beardFramework.core.system.thread;
import msignal.Signal.Signal1;

using beardFramework.utils.SysPreciseTime;
/**
 * ...
 * @author Ludo
 */
class Thread 
{

	private var threadDetails:List<AbstractThreadDetail>;
	private var timeLimitPerFrame:Float;
	private var length:Int;
	
	public var name:String;
	public var completed(get, null):Signal1<Thread>;
	public var started(get, null):Signal1<Thread>;
	public var progressed(get, null):Signal1<Thread>;
	
	public function new(name:String, timeLimit:Float = 10) 
	{
		this.name = name;
		this.timeLimitPerFrame = timeLimit;
		completed = new Signal1(Thread);
		progressed = new Signal1(Thread);
		started = new Signal1(Thread);
	}
	
	private function Proceed():Void
	{
		var time:Float =Sys.preciseTime();
		var individualTime :Float = this.timeLimitPerFrame / threadDetails.length;
		var detail:AbstractThreadDetail;
		
		
		while (threadDetails.length>0)
		{
			if ((detail = threadDetails.first()) != null){
				
				detail.startTime =Sys.preciseTime();
				detail.timeLimit = individualTime;
				
				
				//if (detail.action(detail)){
				if (detail.Call()){
					
					detail.Clear();
					detail = null;
					threadDetails.pop() ;
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
	
	public function Add(detail:AbstractThreadDetail):Void
	{
		
		if (threadDetails == null) threadDetails = new List<AbstractThreadDetail>();
		
		var exist:Bool = false;
		
		for (existingDetail in threadDetails)
			if (existingDetail == detail){
				exist = true;
				break;
			}
			
		if (!exist)	threadDetails.add(detail);
		
	}
	
	public inline function ThreadedProceed():Bool
	{
		Proceed();
		//detail.progression = this.progression();
		return isEmpty();		
	}
	
	public function Start():Void
	{
		length = threadDetails.length;
		BeardGame.Get().AddUpdateProcess(name, Proceed);
		started.dispatch(this);
	}
	
	public function Clear():Void
	{
		
		if (threadDetails != null){
			
			for (detail in threadDetails){
				
				detail.Clear();
			}
			
		}
		threadDetails.clear();
		completed.removeAll();
		BeardGame.Get().RemoveUpdateProcess(name);
	}
	
	public inline function isEmpty():Bool 
	{
		return (threadDetails == null || threadDetails.length==0);
	}
	
	public inline function  get_started():Signal1<Thread> 
	{
		return started;
	}
	
	public inline function  get_progressed():Signal1<Thread>  
	{
		return progressed;
	}
	
	public inline function  get_completed():Signal1<Thread>  
	{
		return completed;
	}
	
	public inline function progression():Float
	{
		
		return threadDetails.length * 100 / length;
		
	}
	
	
	
}

