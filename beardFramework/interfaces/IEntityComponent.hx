package beardFramework.interfaces;
import beardFramework.gameSystem.entities.GameEntity;

/**
 * @author Ludo
 */
interface IEntityComponent 
{
	public var name(get, set):String;
	public var parentEntity:GameEntity;
	
  	public function Update():Void;
	
	
}