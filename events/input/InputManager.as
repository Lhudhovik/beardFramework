package BeardFramework.Events 
{
	
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	import org.osflash.signals.Signal;
	import starling.events.TouchEvent;
	/**
	 * ...
	 * @author Ludo
	 */
	public class InputManager 
	{
		
		private static var _instance:InputManager;
		
		private var _actions:Dictionary;
		private var _inputs:Dictionary;
		
		public static function getInstance():InputManager
		{
			if (!_instance)
			{
				_instance = new InputManager(new InputManagerSingleton());
				_instance.init();
			}
			
			return _instance;
		}
		
		public function InputManager(singleton:InputManagerSingleton) 
		{
			
		}
		
		private function init():void
		{
			
			_inputs = new Dictionary();
			_actions = new Dictionary();
			
		}
		
		public function parseInputSettings(data:XML):void{
			//add keys when parsing settings
		}
		
		public function registerActionInput(actionID : String, inputID:String):void 
		{
			if (!_actions[actionID])
				_actions[actionID] = new Signal();
			
			if (!_inputs[inputID])
				_inputs[inputID] = new Vector.<String>();
				
			if (_inputs[inputID].indexOf(actionID) == -1)
				_inputs[inputID].push(actionID);
			
		}
		
		public function activeCallback(actionID : String, callback:Function, active :Boolean = true):void
		{
			if (_actions[actionID] && callback != null)
				active ? _actions[actionID].add(callback) : _actions[actionID].remove(callback);

		}
		
		
		
		public function onMouseEvent(e:MouseEvent):void
		{
			var i:int;
			
			if (_inputs[e.type]){
				
				i = _inputs[e.type].length-1;
				
				for (i; i >= 0; i--){
					trace(_inputs[e.type][int(i)]);
					_actions[_inputs[e.type][int(i)]].dispatch();
				}
			}
			
			
		}
		
		public function onKeyboardEvent(e:KeyboardEvent):void
		{
			var i:int;
			
			if (_inputs[e.keyCode]){
				
				i = _inputs[e.keyCode].length-1;
				
				for (i; i >= 0; i--){
					trace(_inputs[e.keyCode][int(i)]);
					_actions[_inputs[e.keyCode][int(i)]].dispatch();
				}
			}
			
			
			
		}
		
		public function onTouchEvent(e:TouchEvent):void
		{
		//TO DO
		}
		
		
	}

}
internal class InputManagerSingleton{
		
		
	
}
