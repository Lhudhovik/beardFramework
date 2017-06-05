package beardFramework.resources.memory 
{
	/**
	 * ...
	 * @author Ludo
	 */
	public class InstancePool 
	{
		private var _objects : Vector.<*>;
		private var _count:int;
		private var _firstNullIndex:int=-1;
		
		
		public function InstancePool(type:Class, size:int, fixed:Boolean = false) 
		{
			_objects = new Vector.<type>(size, fixed);
			
			if (fixed)
			{
				_count = size;
				_firstNullIndex = 0;
			}
			
			
		}
		
			<
		public function push(addedObject:*):Boolean
		{
			var result : Boolean = false;
			
			if (_objects.indexOf(addedObject) == -1)
			{				
				if (!_objects.fixed)
				{
					_objects.push(addedObject);
					_count++;
					result = true;
				}
				else if (_firstNullIndex < _count);
				{
					trace("Previous Null index : " + _firstNullIndex);
					_objects[_firstNullIndex++] = addedObject;
					trace("Object index : " + _objects.indexOf(addedObject));
					trace("Next Null index : " + _firstNullIndex);
					result = true;
				}
			}
			
			return result;
			
		}
		
		public function get full():Boolean
		{
			return _objects.fixed && _objects.indexOf(null) == -1 ;
		}
		
		public function getFreeObject():*
		{
			var freeObject : * ;
			
			if (hasUnusedObject)
			{
				if (_objects.fixed){
					
					var tempObject : Object = _objects[0];
					
					_objects[0] = _objects[_firstNullIndex - 1];
					_objects[_firstNullIndex - 1] = tempObject;
					
					
				}
				_objects.unshift(_objects.pop());
				freeObject = _objects[0];
				freeObject.free = false;
			}	
		
			return freeObject;
			
		}
			
		public function get count():int
		{
			return _count;
		}
		
		public function get hasUnusedObject():Boolean
		{
			
			var result : Boolean;
			
			if (_objects.fixed)
			else result = _count > 0  ? _objects[_count - 1].free : false;
			
			
			
			return  
			
		}
	}

}