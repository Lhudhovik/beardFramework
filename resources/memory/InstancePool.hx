package beardFramework.resources.memory;
import haxe.ds.Vector;

/**
 * ...
 * @author Ludo
 */
class InstancePool<TClass>
{

	private var _instances:Vector<TClass>;
	public function new(length:Int) 
	{
		_instances = new Vector<TClass>(length);
		
	}
	
	
	
}