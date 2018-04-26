package beardFramework.core.system.thread;

/**
 * ...
 * @author Ludo
 */
@:generic
class ParamThreadDetail<T> extends AbstractThreadDetail 
{
	public var action:ParamThreadDetail<T>->Bool;
	public var parameter:Null<T>;
	public function new(action:ParamThreadDetail<T>->Bool, parameter:T) 
	{
		super();
		this.action = action;
		this.parameter = parameter;
		
	}
	
	override public inline function Call():Bool 
	{
		return action(this);
	}
	
	override public function Clear():Void 
	{
		action = null;
		parameter = null;
	}
	
	
}