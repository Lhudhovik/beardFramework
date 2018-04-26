package beardFramework.core.system.sequence;
import msignal.Signal.Signal1;

/**
 * ...
 * @author Ludo
 */
class Sequence
{
	private var name:String;
	private var timeLimit:Float;
	private var calls:List<Void->Void>;
	private var length:Int=0;
	
	
	public var completed(get, null):Signal1<Sequence>;
	public var started(get, null):Signal1<Sequence>;
	public var progressed(get, null):Signal1<Sequence>;

	public function new(name:String = "default", timeLimit:Float = 3) 
	{
		this.name = name;
		this.timeLimit = timeLimit;
		calls = new List<Void->Void>();
		
		
		completed = new Signal1(Sequence);
		started = new Signal1(Sequence);
		progressed = new Signal1(Sequence);
	}
	
	
	public inline function AddCall(call:Void->Void):Void
	{
		calls.add(call);	
	}
	
	public function AddMultipleCalls(calls:List<Void->Void>):Void
	{
		for (call in calls)
			this.calls.add(call);
	}
	
	
	public inline function Remove(call:Void->Void):Void
	{
		calls.remove(call);
	}
	
	public function Start():Void
	{
	
		BeardGame.Get().AddUpdateProcess(this.name, Proceed);	
		
		length = calls.length;
		
		started.dispatch(this);
		
	}
	
	public function Proceed():Void 
	{
		var time:Float = Sys.time();
		
		while (calls.length > 0)
		{
			
			calls.first()();
			calls.pop();
			
			progressed.dispatch(this);
			
			if ((Date.now().getTime() - time) > timeLimit) break;
			
		}
		
		trace("Sequence Proceed called");
		
		if (calls.length == 0){
			completed.dispatch(this);
			BeardGame.Get().RemoveUpdateProcess(this.name);
		}
		
	}
	
	function get_completed():Signal1<Sequence>
	{
		return completed;
	}
	
	function get_started():Signal1<Sequence>
	{
		return started;
	}
	
	function get_progressed():Signal1<Sequence>
	{
		return progressed;
	}
	
	public inline function progression():Float
	{
		
		return calls.length * 100 / length;
		
	}
}