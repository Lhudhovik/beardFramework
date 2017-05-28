package BeardFramework.Physics 
{
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2World;
	
	/**
	 * ...
	 * @author Ludo
	 */
	public class PhysicsManager 
	{
		private static var _instance:PhysicsManager;
		
		private var _physicsWorld : b2World;
		private var _GRAVITY:Number;
		private var _RATIO:Number;
		
		public static function get instance():PhysicsManager{
			if (_instance == null){
				_instance = new PhysicsManager(new PhysicsManagerSingleton());
			}
			
			return _instance;
		}
		
		public function PhysicsManager(Singleton:PhysicsManagerSingleton){
			
		}
		
		public function InitPhysics():void
		{
			
		}
		
		public function CreateBody():b2Body
		{
			return new b2Body(null, null);
		}
		
		public function DestroyBody():void{
			
		}
		
		public function GetPhysicWorld():b2World{
			return _physicsWorld;
		}
		
		public function get GRAVITY():Number
		{
			return _GRAVITY;
		}
		
		public function get RATIO():Number
		{
			return _RATIO;
		}
		
		
		
		
		
	}
	

}
internal class PhysicsManagerSingleton{
		
		
	
}