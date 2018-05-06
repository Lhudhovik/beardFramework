package beardFramework.updateProcess.thread;

/**
 * ...
 * @author Ludo
 */
class ThreadDetail extends AbstractThreadDetail
{

	public var action:ThreadDetail->Bool;
	
	public function new(action:ThreadDetail->Bool) 
	{
		super();
		this.action = action;
	}
	
	override public inline function Call():Bool 
	{
		
		return action(this);
	}
	
	override public function Clear():Void
	{
		action = null;
	}
	
	
}