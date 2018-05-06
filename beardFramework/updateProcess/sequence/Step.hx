package beardFramework.updateProcess.sequence;

/**
 * ...
 * @author Ludo
 */
@:generic
class Step<T> extends AbstractStep
{
	
	var parameter:T;
	var action:T->Void;

	public function new( name:String, action: T-> Void, parameter:T) 
	{
		super(name);
		this.action = action;
		this.parameter = parameter;
	
	}
		
	override public function Proceed():Bool
	{
		action(parameter);
		return true;
	}
	
	override function Clear():Void 
	{
		super.Clear();
		parameter = null;
		action = null;
	}
}


