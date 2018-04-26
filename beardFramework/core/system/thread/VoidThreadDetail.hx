package beardFramework.core.system.thread;

/**
 * ...
 * @author Ludo
 */
class VoidThreadDetail extends AbstractThreadDetail 
{
	public var action:Void->Bool;
	public function new(action:Void->Bool) 
	{
		super();
		this.action = action;
	}
	
	override public inline function Call():Bool 
	{
		return action();
	}
	
	override public function Clear():Void
	{
		action = null;
	}
	
	
	
}