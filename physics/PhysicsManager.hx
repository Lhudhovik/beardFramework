package beardFramework.physics;
import nape.geom.Vec2;
import nape.space.Space;

/**
 * ...
 * @author Ludo
 */
class PhysicsManager
{
	private static var instance(get, null):PhysicsManager;
	
	private var space(get,null):Space;
	private var GRAVITY(get, null):Vec2;
		
	public function new() 
	{
		
	}
	
	public static function get_instance():PhysicsManager
	{
		if (instance == null)
		{
			instance = new PhysicsManager();
		}
		
		return instance;
	}

	public function InitSpace(spaceOptions:Xml):Void
	{
		GRAVITY = Vec2.get(Std.parseFloat(spaceOptions.get("gravityX")),Std.parseFloat(spaceOptions.get("gravityY")));
		space = new Space(GRAVITY);
	}
	
	public inline function Step(deltaTime:Float):Void
	{
		space.step(deltaTime);
	}
	
	public inline function get_space():Space return space;
	public inline function get_GRAVITY():Vec2
	{
		return Vec2.get(GRAVITY.x, GRAVITY.y, true);
	}
	
}