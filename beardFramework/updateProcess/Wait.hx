package beardFramework.updateProcess;
import beardFramework.updateProcess.UpdateProcess;

using beardFramework.utils.SysPreciseTime;
/**
 * ...
 * @author Ludo
 */
class Wait extends UpdateProcess 
{
	private static var waits:Array<Wait>;
	private var duration:Float = 0;
	
	private function new(name:String) 
	{
		super(name, 0);
		
	}
	
	public static inline function WaitFor(durationInSec:Float, onComplete:Void->Void, name:String="Wait"):Void
	{
		var wait:Wait = GetWait();
		wait.name = name;
		wait.timePerUpdate = Sys.preciseTime();
		wait.duration = durationInSec*1000;
		wait.completed.addOnce(onComplete);
		wait.Start();		
	}
	public static inline function ClearWait(name:String = "Wait"):Void
	{
		if (waits == null) waits = new Array<Wait>();
		for (wait in waits)
			if (wait.name == name)
				wait.Clear();
			
	}
	
	private static function GetWait():Wait
	{
		if (waits == null) waits = new Array<Wait>();
	
		var newWait : Wait = null;
		for (wait in waits)
			if (wait.running == false)
				newWait = wait;
		
		if (newWait == null){
			newWait = new Wait("Wait" + waits.length);
			waits.push(newWait);
		}
		
		return	newWait;
	}

	override public function Proceed():Void 
	{
		
		if (Sys.preciseTime() - timePerUpdate > duration){
			completed.dispatch();
			Clear();
		}
	}
	
}