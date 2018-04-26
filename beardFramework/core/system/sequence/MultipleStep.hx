package beardFramework.core.system.sequence;

/**
 * ...
 * @author Ludo
 */
@:generic
class MultipleStep<T> extends AbstractStep<T> 
{
	public var parameters(get, null):List<T>;
	
	public function new(action:T-> Void, parameters:Array<T> = null) 
	{
		super(action);
		
		this.parameters = new List<T>();
		
		if (parameters != null) for (element in parameters)	this.parameters.add(element);

	}
	
	override public function Proceed():Void 
	{
		
		action(parameters.first());
		parameters.pop();
		
		//if (parameters.length == 0) 
		
	}
	
	public function ToList():List<Void->Void>
	{
		var list:List<Void->Void> = new List<Void->Void>();
		for (i in 0...parameters.length)
			list.add(Proceed);
			
		return list;
		
	}
	
	override function Clear():Void 
	{
		super.Clear();
		parameters.clear();
		
	}
	
	function get_parameters():List<T> 
	{
		return parameters;
	}
	
	
	
}