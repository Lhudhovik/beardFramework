package beardFramework.core.system.thread;


/**
 * ...
 * @author Ludo
 */
class Thread<T>
{
	private var threadedMethods:Array<ThreadDetail<T>>;
	private var allowedTime:Float;
	public var empty(get, null):Bool;
	
	public function new(timeLimit:Float) 
	{
		this.allowedTime = timeLimit;
		
	}
	
	public function AddToThread(method:ThreadDetail<T>->Bool, parameter:T):Void
	{
		if (threadedMethods == null) threadedMethods = new Array<ThreadDetail<T>>();
		var details:ThreadDetail<T> = {action:method, parameter:parameter, allowedTime:0};
		
		if (!CheckIsExisting(details)){
			threadedMethods.push(details);
			trace("thread method added");
		}
	}
	
	
	public function Proceed():Void
	{
		var time:Float = Date.now().getTime();
		var i : Int = 0;
		var individualTime :Float = this.allowedTime / threadedMethods.length;
		
		while (i< threadedMethods.length)
		{
			if (threadedMethods[i] != null){
				
				threadedMethods[i].allowedTime = individualTime;
				
				if( threadedMethods[i].action(threadedMethods[i])){
					threadedMethods.remove(threadedMethods[i]);
					i--;
				}
			}
			//trace(threadedMethod[i].parameter);
			if ((Date.now().getTime() - time) > allowedTime) break;
			
			i++;
		}
		
	}
	
	public function Clear():Void
	{
		
		if (threadedMethods != null){
			
			for (detail in threadedMethods){
				
				detail = null;
			}
			
		}
		threadedMethods = [];
	}
	
	private inline function CheckIsExisting(checkedDetail : ThreadDetail<T>):Bool
	{
		var success:Bool = false;
		
		for (method in threadedMethods){
			
			if (success = (method.action == checkedDetail.action))
				break;
		}
		
		return success;
	}
	
	public function get_empty():Bool 
	{
		return (threadedMethods == null || threadedMethods.length==0);
	}
	
	
}

typedef ThreadDetail<T> = {
	
	var action:ThreadDetail<T>->Bool;	
	var parameter:T;
	var allowedTime:Float;
	
}