package beardFramework.updateProcess.sequence;

/**
 * ...
 * @author Ludo
 */
@:generic
class MultipleStep<T> extends AbstractStep
{
	public var parameters(get, null):List<T>;
	var action:T->Void;

	public function new(name:String, action:T-> Void, parameters:Array<T> = null) 
	{
		super(name);
		
		this.parameters = new List<T>();
		this.action = action;
		if (parameters != null) for (element in parameters)	this.parameters.add(element);

	}
	
	override public function Proceed():Bool 
	{
		
		action(parameters.first());
		parameters.pop();
		
		return parameters.length == 0;
		
		
	}
	
	override function Clear():Void 
	{
		super.Clear();
		parameters.clear();
		action = null;
		
	}
	
	function get_parameters():List<T> 
	{
		return parameters;
	}
	
	
	
}