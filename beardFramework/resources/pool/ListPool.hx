package beardFramework.resources.pool;
import beardFramework.utils.cloner.Cloner;

/**
 * ...
 * @author 
 */
class ListPool<TClass> 
{

	private var availableInstances:List<TClass>;
	private var busyInstances:List<TClass>;
	private var fixedSize:Bool;
	
	public function new(size:Int, fixedSize:Bool = true) 
	{
	
		availableInstances = new List();
		busyInstances = new List();
		this.fixedSize = fixedSize;
	
	}
	
	public function Populate(elements:Array<TClass>):Void 
	{
		Flush();
		
		for (element in elements)
			availableInstances.add(element);
		
	}
	
	public function Extent(size:Int = 1):Void
	{
		while(size-- > 0)
			availableInstances.add(Cloner.Get().clone(availableInstances.first()));
	}
		
	public function Flush():Void
	{
		availableInstances.clear();
		busyInstances.clear();
	}
	
	public function Get():TClass
	{
		var instance:TClass = null;
		if (availableInstances.length > 0)
			instance = availableInstances.pop();
		
		
		if (instance == null && fixedSize == false){
			
			Extent();
			instance = availableInstances.pop();
		}
		
		busyInstances.add(instance);
		
		return instance;
	
	}
	
	public function Release(releasedInstance:TClass):TClass 
	{
		
		busyInstances.remove(releasedInstance);
		availableInstances.add(releasedInstance);	
		return null;
		
	}
	
	public inline function GetFreeInstancesCount():Int
	{
		return availableInstances.length;
	}
	
	public inline function GetUsedInstancesCount():Int 
	{
		
		
		return busyInstances.length;
	}
		
	public inline function HasFreeInstances():Bool
	{
		
		return availableInstances.length > 0;
	}
		
	public function Trace():Void
	{
		trace(availableInstances.toString());
		trace(busyInstances.toString());
	}
	

	
	
}