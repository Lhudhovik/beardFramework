package beardFramework.updateProcess.sequence;
import beardFramework.updateProcess.UpdateProcess;
import msignal.Signal.Signal1;

using beardFramework.utils.SysPreciseTime;
/**
 * ...
 * @author Ludo
 */
class Sequence extends UpdateProcess
{
	private var prevTime:Float;
	private var steps:List<AbstractStep>;
	private var conditions:Map<String,Bool>;
		
	
	public function new(name:String = "default", timerStep:Float = 0) 
	{
		super(name, timerStep);
		steps = new List<AbstractStep>();
		conditions = new Map<String,Bool>();
		prevTime = 0;
		
	}
	
	public inline function AddStep(step:AbstractStep, needCondition:Bool = false):Void
	{
		steps.add(step);	
	
		if (needCondition) conditions[step.name] = false;
		
	}
	
	public inline function Remove(step:AbstractStep):Void
	{
		steps.remove(step);
		conditions.remove(step.name);
	}
	
	override public function Start():Void
	{
	
		super.Start();
		
		length = steps.length;
	}
	
	override public function Proceed():Void 
	{
		if (timePerUpdate > Sys.preciseTime() - prevTime ) return;
		
		var step:AbstractStep = steps.first();
		
		if (conditions[step.name] == null || conditions[step.name])
		{
			if (step.Proceed()){
				steps.pop();
				step.Clear();
			}
		
			progressed.dispatch();
			
			if (steps.length == 0){
				completed.dispatch();
				Clear();
			}
			
			prevTime = Sys.preciseTime();
		}
		
		
	}
	
	public inline function SetCondition(step:String, canProceed:Bool):Void
	{
		conditions[step] = canProceed;
	}
	
	override public function Clear():Void
	{
		super.Clear();
		steps.clear();
		
	}
	
	
	
	override public function get_progression():Float
	{
		
		return steps.length * 100 / length;
		
	}
	
	
}