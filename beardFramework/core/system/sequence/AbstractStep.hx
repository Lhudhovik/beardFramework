package beardFramework.core.system.sequence;

/**
 * ...
 * @author Ludo
 */
@:generic
class AbstractStep<T>
{

	
	var action:T-> Void;
	
	
	private function new(action: T-> Void) 
	{
		this.action = action;
	}
	
	
	public function Proceed():Void
	{
		
	}
	
	private function Clear():Void
	{
		action = null;
	
	}
	
}