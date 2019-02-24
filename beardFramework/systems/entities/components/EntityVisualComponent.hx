package beardFramework.systems.entities.components;
import beardFramework.core.BeardGame;
import beardFramework.graphics.core.Visual;
import beardFramework.resources.save.data.StructDataComponent;
import haxe.Json;
import beardFramework.systems.entities.GameEntity;
import beardFramework.interfaces.IEntityVisual;

/**
 * ...
 * @author Ludo
 */
class EntityVisualComponent extends Visual implements IEntityVisual
{

	public function new(texture:String, atlas:String, name:String ="" ) 
	{
		super(texture, atlas,name);
		
	}
	
	
	/* INTERFACE beardFramework.interfaces.IEntityVisual */
	
	
	
	public function Register():Void 
	{
		BeardGame.Get().GetContentLayer().Add(this);	
	}
	
	public function UnRegister():Void 
	{
		BeardGame.Get().GetContentLayer().Remove(this);		
	}
	
	public var parentEntity:GameEntity;
	
	public function Update():Void 
	{
		this.x = parentEntity.x;
		this.y = parentEntity.y;
	}
	
	public function ToData():StructDataComponent 
	{
		var data:StructDataComponent = 
		{
			name:this.name,
			type:Type.getClassName(EntityVisualComponent),
			update:true,
			position: -1,
			additionalData: ""
		}
	
		return data;
	}
	
	public function ParseData(data:StructDataComponent):Void 
	{
		
	}
	
	public function Dispose():Void 
	{
		
	}
	
}