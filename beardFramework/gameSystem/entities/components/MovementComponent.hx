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
	var horizontalMovement:Float = 0;
	var verticalMovement:Float = 0;
	
	public function new() 
	{
		InputManager.get_instance().BindAction("HorizontalMove", HorizontalMove);
		InputManager.get_instance().BindAction("VerticalMove", VerticalMove);
	}
	
	private function HorizontalMove(value:Float):Void
	{
		horizontalMovement += value*2;
	
		
	}
	private function VerticalMove(value:Float):Void
	{
		verticalMovement += value*2;
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