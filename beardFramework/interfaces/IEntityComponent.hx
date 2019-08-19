package beardFramework.interfaces;
import beardFramework.systems.entities.GameEntity;
import beardFramework.resources.save.data.StructDataComponent;

/**
 * @author Ludo
 */
interface IEntityComponent extends INamed
{
	public var parentEntity:GameEntity;
	
  	public function Update():Void;
  	public function ToData():StructDataComponent;
  	public function ParseData(data:StructDataComponent):Void;
  	public function Dispose():Void;
	
	
}

