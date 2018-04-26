package beardFramework.core.system.sequence;

/**
 * ...
 * @author Ludo
 */
@:generic
class Step<T> extends AbstractStep<T>
{
	
	var parameter:T;

	public function new( action: T-> Void, parameter:T) 
	{
		super(action);
		this.parameter = parameter;
	}
	
	
	override public function Proceed():Void
	{
		action(parameter);
	}
	
	override function Clear():Void 
	{
		super.Clear();
		parameter = null;
	}
}


