package BeardFramework.Resources.Memory 
{
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	/**
	 * ...
	 * @author Ludo
	 */
	public class InstanceManager 
	{
		
		
		
		static private var _instance:InstanceManager;
		private var _pool :Dictionary;
		private var _currentPoolName:String;
		
		
		
		public function InstanceManager(singleton:InstanceManagerSingleton) 
		{
			
			
		}
		
		static public function getInstance():InstanceManager
		{
			if (!_instance){
				_instance = new InstanceManager(new InstanceManagerSingleton());
				_instance.init();
				
			}
			
			return _instance;
		}
		
		private function init():void
		{
			_pool = new Dictionary();
			
		}
		
		private function addPool(type:Class, size:int = 0, fixed:Boolean=false):void
		{
			_pool[getQualifiedClassName(type)] = new InstancePool(type, size, fixed);
			
		}
	
		public function createInstances(type:Class, count:uint = 1, initParams:Array=null):void
		{
			_currentPoolName = getQualifiedClassName(type);
			
			if (!_pool[_currentPoolName])_pool[_currentPoolName] = new InstancePool(type,count);
			
			while (--count >-1 && !_pool[_currentPoolName].full ){
				var newObject : * = new type();
				if(initParams && newObject.init) newObject.init.apply(newObject, initParams);
				_pool[_currentPoolName].push(new type());
				trace("added object in " + _currentPoolName + " pool");
			}
			
			
		}
		
		public function borrowObject(type:Class):*
		{
			_currentPoolName = getQualifiedClassName(type);
			
			if (!_pool[_currentPoolName] || !_pool[_currentPoolName].hasUnusedObject)
				createInstances(type);
			
			trace("borrowed object in " + _currentPoolName + " pool");
			return _pool[_currentPoolName].getFreeObject();
			
			
		}
		
		public function returnObject(returnedObject:*):void
		{
			_currentPoolName = getQualifiedClassName(returnedObject);
			
			if(_pool.get_pool[_currentPoolName]
			
			
		}
		
		
	}

}
internal class InstanceManagerSingleton{
	
}

