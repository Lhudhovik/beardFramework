package beardFramework.utils;
import haxe.ds.Vector;

/**
 * ...
 * @author 
 */
class MinAllocArray<T>
{
	public var length(default, null):Int = 0;
	
	private var data:Vector<Null<T>>;

	private var utilInt:Int = 0;
	
	public function new(?base:Array<Null<T>>, ?size:Int) 
	{
		if (base != null){
			
			data = Vector.fromArrayCopy(base);
			length = data.length;
		}
		else if (size != null)
		{
			data = new Vector<Null<T>>(size);
		}
		else
		{
			data = new Vector<Null<T>>(0);
			
		}
	}
	
	public function Remove(element:Null<T>):Bool{
		
		utilInt = 0;
		for (i in 0...data.length)
		{
			if (utilInt != 0){
				data[i - 1] = data[i];
				if (i == length) data[i] = null;
			}				
			else if (data[i] == element)
			{
				utilInt = i;
				data[i] = null;
				length--;
				trace(data);
			}
		}
		trace(data);
		return utilInt != 0;
		
	}
	
	public function Push(element:Null<T>):Void
	{
		
		if (length == data.length)
		{
			var temp:Vector<Null<T>> = new Vector<Null<T>>(length + 1);
			for (i in 0...data.length)
				temp[i] = data[i];
			
			data = temp;			
		}
		
		data[length++] = element;
		//trace(data);
	}
	
	public inline function get(index:Int):Null<T>
	{
		return data[index];
	}
	

	public inline function set(index:Int, value:Null<T>):Null<T>
	{
		data[index] = value;
		return value;
	}
	
	
	public inline function Clean():Void
	{
		
		for (i in 0...data.length)
			data[i] = null;
		
		length = 0;	
		
	}
	public inline function IndexOf(value:Null<T>):Int
	{
		var index:Int = -1;
		
		for (i in 0...length)
			if (data[i] == value){
				index = i;
				break;
			}
		
		
		return index;
		
	}
	
	
	
	
	
	
	
	
}