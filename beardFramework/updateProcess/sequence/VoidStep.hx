package beardFramework.updateProcess.sequence;

/**
 * ...
 * @author Ludo
 */
class VoidStep extends AbstractStep 
{

	var action:Void->Void;

	public function new( name:String, action: Void-> Void) 
	{
		super(name);
		this.action = action;
	
	}
		
	override public function Proceed():Bool
	{
		action();
		return true;
	}
	
	override function Clear():Void 
	{
		super.Clear();
		action = null;
	}
}