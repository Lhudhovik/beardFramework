package beardFramework.updateProcess;
import beardFramework.graphics.screens.ScreenFlowManager;
import beardFramework.resources.MinAllocArray;
import beardFramework.updateProcess.UpdateProcess;

/**
 * ...
 * @author Ludo
 */
class UpdateProcessesManager 
{

	private static var instance(default, null):UpdateProcessesManager;
	private var updateProcesses:MinAllocArray<UpdateProcess>;
	
	
	public static inline function Get():UpdateProcessesManager
	{
		if (instance == null)
		{
			instance = new UpdateProcessesManager();
			instance.Init();
		}
		
		return instance;
	}
	
	private function new() 
	{
		
	}
	
	private function Init():Void
	{
		updateProcesses = new MinAllocArray<UpdateProcess>();
	}
	
	public function Update():Void
	{
		for (i in 0...updateProcesses.length){
			if(updateProcesses.get(i) != null)	updateProcesses.get(i).Proceed();
		}
	}
	
	public function AddUpdateProcess(updateProcess:UpdateProcess):Void
	{
		updateProcesses.UniquePush(updateProcess);

		
	}
	
	public function RemoveUpdateProcess(name:String):Void
	{
		
		for (i in 0...updateProcesses.length)
		{
			if (updateProcesses.get(i).name == name){
				updateProcesses.Remove(updateProcesses.get(i));
				break;				
			}
		}
	}
		
	public function GetUpdateProcess(name:String):UpdateProcess
	{
		
		var updateProcess:UpdateProcess = null;
		for (i in 0...updateProcesses.length)
		{
			if (updateProcesses.get(i).name == name){
				updateProcess = updateProcesses.get(i);
				break;
			}
		}
		
		return updateProcess;
	}
	
	public inline function IsEmpty():Bool
	{
		return updateProcesses.length == 0;
	}
}