package beardFramework.updateProcess.thread;
import beardFramework.updateProcess.UpdateProcess;
import msignal.Signal.Signal1;

using beardFramework.utils.SysPreciseTime;
/**
 * ...
 * @author Ludo
 */
class Thread extends UpdateProcess
{

	private var threadDetails:List<AbstractThreadDetail>;
		
	public function new(name:String, timeLimit:Float = 10) 
	{
		super(name, timeLimit);
	}
	
	override public function Proceed():Void
	{
		var time:Float =Sys.preciseTime();
		var individualTime :Float = this.timePerUpdate / (threadDetails.length > 0 ? threadDetails.length : 1 );
		var detail:AbstractThreadDetail;
		
		
		while ((detail = threadDetails.first()) != null)
		{
			detail.startTime = Sys.preciseTime();
			detail.timeLimit = individualTime;
			
			
			//if (detail.action(detail)){
			if (detail.Call()){
				progression += detail.progression/(length > 0 ? length : 1 );
				detail.Clear();
				detail = null;
				threadDetails.pop() ;
			}
			else 
				progression += detail.progression/(length > 0 ? length : 1 );
	
			progressed.dispatch();

			if ((Sys.preciseTime() - time) > timePerUpdate) break;
			
		}
		
		if (threadDetails.length == 0){
			completed.dispatch();
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
	
	override public function Start():Void
	{
		super.Start();
		length = 0;
		for (detail in threadDetails)
			length += detail.length;
		
	}
	
	override public function Clear():Void
	{
		super.Clear();
		if (threadDetails != null){
			
			for (detail in threadDetails){
				detail.Clear();
			}
			threadDetails.clear();
		}
		
		completed.removeAll();
		
	}
	
	public inline function isEmpty():Bool 
	{
		return (threadDetails == null || threadDetails.length==0);
	}
	
	
	override function get_progression():Float 
	{
		return threadDetails.length * 100 / length;
	}
	
	
	
	 
	
}

