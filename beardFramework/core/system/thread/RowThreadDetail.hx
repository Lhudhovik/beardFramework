package beardFramework.core.system.thread;

/**
 * ...
 * @author Ludo
 */
class RowThreadDetail<T> extends AbstractThreadDetail
{
	public var action:RowThreadDetail<T>->Bool;
	public var parameter:Null<T>;
	public var parameters:List<Null<T>>;
	
	public function new(action:RowThreadDetail<T> -> Bool, parameters:Array<T>) 
	{
		super();
		
		this.action = action;
		this.parameters = new List();
		
		if (parameters != null)
		{
			for (param in parameters)
			{
				var nullParam:Null<T> = param;
				this.parameters.add(nullParam);
			}
		
			this.parameter = this.parameters.first();
		
		}
		
	}
	
	override public inline function Call():Bool 
	{
			
		if (action(this))
		{
			parameters.pop();
			parameter = null;
			parameter = parameters.first();
		}
							
		return parameters.isEmpty();
	}
	
	override public function Clear():Void 
	{
		super.Clear();
		
		for (param in parameters)
		{
			param = null;
		}
		
		parameters.clear();
		//parameters = null;
		
	}
		
	
	
}