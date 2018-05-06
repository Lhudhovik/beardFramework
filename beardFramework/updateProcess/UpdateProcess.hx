package beardFramework.updateProcess;
import msignal.Signal;

/**
 * ...
 * @author Ludo
 */
class UpdateProcess 
{
	
	private var length:Int = 0;
	private var timePerUpdate:Float;
	private var running:Bool = false;
	
	public var name(get, null):String;
	public var progression(get, null):Float;
	public var completed(get, null):Signal0;
	public var started(get, null):Signal0;
	public var progressed(get, null):Signal0;
	
	public function new(name:String, timePerUpdate:Float) 
	{
		this.name = name;
		this.timePerUpdate = timePerUpdate;
		
		completed = new Signal0();
		started = new Signal0();
		progressed = new Signal0();
		
	}
	
	public function Start():Void 
	{
		running = true;
		UpdateProcessesManager.Get().AddUpdateProcess(this); 
		started.dispatch();
	}
	
	public function Proceed():Void 
	{}
	
	public function Clear():Void
	{ 
		running = false; 
		UpdateProcessesManager.Get().RemoveUpdateProcess(this.name); 
	}
		
	function get_name():String 
	{
		return name;
	}
	
	function get_completed():Signal0
	{
		return completed;
	}
	
	function get_started():Signal0
	{
		return started;
	}
	
	function get_progressed():Signal0
	{
		return progressed;
	}
	
	function get_progression():Float 
	{
		return 0;
	}
	
	
}