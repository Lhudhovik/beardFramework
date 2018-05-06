package beardFramework.gameSystem.entities.components;
import beardFramework.core.BeardGame;
import beardFramework.resources.save.data.DataComponent;
import haxe.Json;

import beardFramework.display.core.BeardVisual;
import beardFramework.gameSystem.entities.GameEntity;
import beardFramework.interfaces.IEntityVisual;

/**
 * ...
 * @author Ludo
 */
class EntityVisualComponent extends BeardVisual implements IEntityVisual
{

	public function new(texture:String, atlas:String) 
	{
		super(texture, atlas);
		
	}
	
	
	/* INTERFACE beardFramework.interfaces.IEntityVisual */
	
	
	
	public function Register():Void 
	{
		BeardGame.Get().GetContentLayer().AddVisual(this);	
	}
	
	public function UnRegister():Void 
	{
		BeardGame.Get().GetContentLayer().RemoveVisual(this);		
	}
	
	public var parentEntity:GameEntity;
	
	public function Update():Void 
	{
		this.x = parentEntity.x;
		this.y = parentEntity.y;
	}
	
	public function ToData():DataComponent 
	{
		var data:DataComponent = 
		{
			name:this.name,
			type:Type.getClassName(EntityVisualComponent),
			update:true,
			position: -1,
			additionalData: ""
		}
	
		return data;
	}
	
	public function ParseData(data:DataComponent):Void 
	{
		
	}
	
	public function Dispose():Void 
	{
		
	}
	
}