package beardFramework.core.system.thread;
import beardFramework.core.system.thread.Thread.MethodDetails;

/**
 * ...
 * @author Ludo
 */
class Thread 
{
	var threadedMethod:Array<MethodDetails>;
	var allowedTime:Float;
	public function new(threshold:Float) 
	{
		this.allowedTime = threshold;
		
	}
	
	public function AddToThread(method:Dynamic->Float->Bool, parameter:Dynamic):Void
	{
		if (threadedMethod == null) threadedMethod = new Array<MethodDetails>();
		var details:MethodDetails = {action:method, parameter:parameter};
		
		if (!CheckIsExisting(details)) threadedMethod.push(details);
	}
	
	
	public function Proceed():Void
	{
		var time:Float = Date.now().getTime();
		var i : Int = 0;
		while (i< threadedMethod.length)
		{
			if (threadedMethod[i] != null && threadedMethod[i].action(threadedMethod[i].parameter, allowedTime/threadedMethod.length)){
				threadedMethod.remove(threadedMethod[i]);
				i--;
			}
			//trace(threadedMethod[i].parameter);
			if ((Date.now().getTime() - time) > allowedTime) break;
		}
		
	}
	
	private inline function CheckIsExisting(checkedDetail : MethodDetails):Bool
	{
		var success:Bool = false;
		
		for (method in threadedMethod){
			
			if (success = (method.action == checkedDetail.action))
				break;
		}
		
		return success;
	}
	
	
}

typedef MethodDetails = {
	
	var action:Dynamic->Float->Bool;	
	var parameter:Dynamic;	
}