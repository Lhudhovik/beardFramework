package beardFramework.resources.pool;
import beardFramework.resources.MinAllocArray;
import beardFramework.utils.cloner.Cloner;
import haxe.ds.Vector;
import beardFramework.interfaces.IPool;
import openfl.display.Bitmap;


/**
 * ...
 * @author Ludo
 */
class ArrayPool<TClass>
{

	private var instances:MinAllocArray<TClass>;
	private var availableStates:MinAllocArray<Bool>;
	private var fixedSize:Bool;
	
	public function new(size:Int, fixedSize:Bool = true) 
	{
	
		instances = new MinAllocArray<TClass>(size);
		availableStates = new MinAllocArray<Bool>(size);
		this.fixedSize = fixedSize;
	
	}
	
	public function Populate(elements:Array<TClass>):Void 
	{
		Flush();
		
		for (i in 0...instances.length){
			
			instances.set(i, elements[i]);
			availableStates.set(i, true);
		}
		
	}
	
	public function Extent(size:Int = 1):Void
	{
	
		while(size-- > 0)
		{
			
			instances.Push(Cloner.Get().clone(instances.get(0)));
			availableStates.Push(true);
			
		}
	}
		
	public function Flush():Void
	{
		for (index in 0...instances.length){
			instances.set(index, null);
			availableStates.set(index, false);
		}
	}
	
	public function Get():TClass
	{
		var instance:TClass = null;
		for (i in 0...instances.length)
		{
			if (availableStates.get(i)){
				instance = instances.get(i);
				break;
			}
			
		}
		
		if (instance == null && fixedSize == false){
			
			Extent();
			instance = Get();
		}
		
		return instance;
	
	}
	
	public function Release(releasedInstance:TClass):TClass 
	{
	
		for ( i in 0...instances.length ){
			if (instances.get(i) == releasedInstance){
				availableStates.set(i, true);
				break;
			}
				
		}
		
		return null;
		
	}
	
	public inline function GetFreeInstancesCount():Int
	{
		var count:Int = 0;
		
		for (i in 0...instances.length)
			if (availableStates.get(i)) count++;
		
		return count;
	}
	
	public inline function GetUsedInstancesCount():Int 
	{
		var count:Int = 0;
		
		for (i in 0...instances.length)
			if (availableStates.get(i) == false) count++;
		
		return count;
	}
		
	public inline function HasFreeInstances():Bool
	{
		
		var result:Bool = false ;
		for (i in 0...instances.length)
			if (availableStates.get(i)) {
				result = true;
				break;
			}
		return result;
	}
		
	public function Trace():Void
	{
		trace(instances.toString());
		trace(availableStates.toString());
	}
	

	
	
	
}