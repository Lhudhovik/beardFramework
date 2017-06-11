package beardFramework.resources.memory;
import cpp.Void;
import haxe.ds.Vector;


/**
 * ...
 * @author Ludo
 */
class InstancePool<TClass>
{

	private var instances:Vector<TClass>;
	private var freeIndex:Int;
	private var fixeSize:Bool;
	//private var UsedInstances:Vector<TClass>;
	
	public function new(size:Int, populate:Bool = true) 
	{
	
		instances = new Vector<TClass>(size);
		//freeInstances = new Vector<TClass>(size);
		freeIndex = size-1;
		if (populate)
		{
			
		}
	}
	public function Populate(elements:Array<TClass>):Void 
	{
		Flush();
		instances
	
	}
	public function Flush():Void
	{
		for (index in 0...instances.length)
			instances[index] = null;
	}
	
	public function GetFreeInstance():TClass{
		if (freeIndex >= 0)
			return instances[freeIndex--];
		
		
		
	}
	
	
	
}