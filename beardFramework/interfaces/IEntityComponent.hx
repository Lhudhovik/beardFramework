package beardFramework.interfaces;
import beardFramework.gameSystem.entities.GameEntity;
import beardFramework.resources.save.data.DataComponent;

/**
 * @author Ludo
 */
interface IEntityComponent 
{
	public var name(get, set):String;
	public var parentEntity:GameEntity;
	
  	public function Update():Void;
  	public function ToData():DataComponent;
  	public function ParseData(data:DataComponent):Void;
	
	
}

