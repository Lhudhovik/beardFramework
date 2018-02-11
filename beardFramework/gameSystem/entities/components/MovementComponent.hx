package beardFramework.gameSystem.entities.components;

import beardFramework.gameSystem.entities.GameEntity;
import beardFramework.input.InputManager;
import beardFramework.interfaces.IEntityComponent;
import beardFramework.resources.save.data.DataComponent;

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
		InputManager.Get().BindToAction("HorizontalMove", HorizontalMove);
		InputManager.Get().BindToAction("VerticalMove", VerticalMove);
	}
	
	private function HorizontalMove(value:Float):Void
	{
		if(Math.abs(value) >= InputManager.GAMEPAD_AXIS_MOVEMENT_CEIL)
		horizontalMovement += value*2;
	
		
	}
	private function VerticalMove(value:Float):Void
	{
		if(Math.abs(value) >= InputManager.GAMEPAD_AXIS_MOVEMENT_CEIL)
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
	
	
	/* INTERFACE beardFramework.interfaces.IEntityComponent */
	
	public function ToData():DataComponent 
	{
		var data:DataComponent = 
		{
			name:this.name,
			type:Type.getClassName(MovementComponent)
			
			
		}
		return data;
	}
	
}