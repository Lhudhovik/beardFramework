package beardFramework.resources.memory;
import beardFramework.interfaces.IPool;

/**
 * ...
 * @author Ludo
 */
class InstanceManager
{

	private static var instance:InstanceManager;
	
	private var pools:Map<String, InstancePool<Dynamic>>;
	
	private function new() 
	{
		
	}
	public static inline function Get():InstanceManager
	{
		if (instance == null)
		{
			instance = new InstanceManager();
			instance.Init();
		}
		
		return instance;
	}
	private function Init():Void
	{
		pools = new Map<String, InstancePool<Dynamic>>();
			
	}
	
	public function CreatePool<T>(name:String, size:Int, elements:Array<T> = null):Void
	{
		
		if (pools[name] == null){
			
			pools[name] = new InstancePool<T>(size);
			
			pools[name].Populate(elements);
			
		}
		
	}
		
	public function GetFreeInstance(poolName : String):Dynamic
	{
		if (pools[poolName] != null)
			return pools[poolName].Get();
		return null;
	}
	
	public function ReleaseInstance<T>(poolName : String, instance:T ):T
	{
		if (pools[poolName] != null)
			return pools[poolName].Release(instance);
		return null;
	}
	
}