package beardFramework.resources.memory;
import haxe.ds.Vector;
import beardFramework.interfaces.IPool;
import openfl.display.Bitmap;


/**
 * ...
 * @author Ludo
 */
class InstancePool<TClass>
{

	private var instances:Vector<TClass>;
	private var states:Vector<Bool>;
	private var freeIndex:Int;
	private var fixeSize:Bool;
	//private var UsedInstances:Vector<TClass>;
	
	public function new(size:Int) 
	{
	
		instances = new Vector<TClass>(size);
		states = new Vector<Bool>(size);
		//freeInstances = new Vector<TClass>(size);
		freeIndex = size-1;
	
	}
	public function Populate(elements:Array<TClass>):Void 
	{
		Flush();
		instances = Vector.fromArrayCopy(elements);
		freeIndex = elements.length -1;
		
		for (i in 0...freeIndex +1)
			states[i] = true;
	}
	public function Flush():Void
	{
		for (index in 0...instances.length)
			instances[index] = null;
	}
	
	public function Get():TClass{
		
		if (freeIndex >= 0){
			states[freeIndex] = false;
			return instances[freeIndex--];
		}
		else return null;
	
	}
	

	public function Release(releasedInstance:TClass):TClass 
	{
		var i: Int = 0;
		for ( element in instances){
			
			if (element == releasedInstance) break;
		
			i++;
		}
		
		if (freeIndex + 1  < instances.length){
			
			
			states[i] = false;
			instances.set(i, instances.get(++freeIndex));
			instances.set(freeIndex, releasedInstance);
			states[freeIndex] = true;
			
		}
		
		return null;
		
	}
	
	
	public inline function GetFreeInstancesCount():Int return freeIndex + 1;
	
	
	public inline function GetUsedInstancesCount():Int return instances.length - (freeIndex + 1);
	
	
	public inline function HasFreeInstances():Bool return freeIndex >= 0;
		
	public function Trace():Void
	{
		var names : Array<String> = [for (element in instances) cast(element, Bitmap).name ];
		trace(names);
		trace(states);
	}
	

	
	
	
}