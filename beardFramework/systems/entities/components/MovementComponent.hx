package beardFramework.systems.entities.components;

import beardFramework.core.BeardGame;
import beardFramework.systems.entities.GameEntity;
import beardFramework.input.InputManager;
import beardFramework.interfaces.IEntityComponent;
import beardFramework.resources.save.SaveManager;
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
		InputManager.Get().BindToAction("Save", SaveState);
		
	}
	
	
	private function SaveState(value:Float):Void
	{
		//trace("save");
		//SaveManager.Get().CreateSave("Test");
		//SaveManager.Get().Load("Test");
		//if (SaveManager.Get().currentSave.gameData.length > 0)
		//{
			//var index:Int = 0;
			//for (data in SaveManager.Get().currentSave.gameData)
			//{
				//if (data.name == BeardGame.Get().currentScreen.name){
					//index = SaveManager.Get().currentSave.gameData.indexOf(data);
					//break;
				//}
							//
			//}
			//
			//SaveManager.Get().currentSave.gameData[index] = BeardGame.Get().currentScreen.ToData(true);
		//}
		//else
		//SaveManager.Get().currentSave.gameData.push(BeardGame.Get().currentScreen.ToData(true));
		//
		//SaveManager.Get().Save("Test", SaveManager.Get().currentSave);
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
			type:Type.getClassName(MovementComponent),
			update:false,
			position: -1,
			additionalData:""
			
		}
		return data;
	}
	
	
	/* INTERFACE beardFramework.interfaces.IEntityComponent */
	
	public function ParseData(data:DataComponent):Void 
	{
		
	}
	
	
	/* INTERFACE beardFramework.interfaces.IEntityComponent */
	
	public function Dispose():Void 
	{
		
	}
	
}