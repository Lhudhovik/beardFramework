package beardFramework.gameSystem.entities.components;

import beardFramework.gameSystem.entities.GameEntity;
import beardFramework.input.InputManager;
import beardFramework.interfaces.IEntityComponent;

/**
 * ...
 * @author Ludo
 */
class MovementComponent implements IEntityComponent 
{
	var horizontalMovement:Int = 0;
	var verticalMovement:Int = 0;
	
	public function new() 
	{
		InputManager.get_instance().RegisterActionCallback("MoveLeft", Left);
		InputManager.get_instance().RegisterActionCallback("MoveRight", Right);
	}
	
	private function Left(value:Float):Void
	{
		horizontalMovement -= 1;
		trace("Left");
		
	}
	private function Right(value:Float):Void
	{
		horizontalMovement += 1;
		trace("Right");
	}
	
	/* INTERFACE beardFramework.interfaces.IEntityComponent */
	
	@:isVar public var name(get, set):String;
	
	function get_name():String 
	{
		return name;
	}
	
	function set_name(value:String):String 
	{
		return name = value;
	}
	
	public var parentEntity:GameEntity;
	
	public function Update():Void 
	{
		parentEntity.x += horizontalMovement;
		parentEntity.y += verticalMovement;
		
		horizontalMovement = 0;
		verticalMovement = 0;
		
	}
	
}