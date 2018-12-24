package beardFramework.updateProcess;
import beardFramework.graphics.screens.ScreenFlowManager;
import beardFramework.updateProcess.UpdateProcess;

/**
 * ...
 * @author Ludo
 */
class UpdateProcessesManager 
{

	private static var instance(default, null):UpdateProcessesManager;
	private var updateProcesses:Array<UpdateProcess>;
	
	
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
		updateProcesses = new Array<UpdateProcess>();
	}
	
	public function Update():Void
	{
		for (process in updateProcesses)
				process.Proceed();
	}
	
	public function AddUpdateProcess(updateProcess:UpdateProcess):Void
	{
		var exist:Bool = false;
		for (process in updateProcesses)
		{
			if (process.name == updateProcess.name) return;
		}
		
		
		updateProcesses.push(updateProcess);

		
	}
	
	public function RemoveUpdateProcess(name:String):Void
	{
		
		for (process in updateProcesses)
		{
			if (process.name == name){
				updateProcesses.remove(process);
				
			}
		}
	}
		
	public function GetUpdateProcess(name:String):UpdateProcess
	{
		
		var updateProcess:UpdateProcess = null;
		for (process in updateProcesses)
		{
			if (process.name == name){
				updateProcess = process;
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