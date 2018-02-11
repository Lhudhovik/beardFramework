package beardFramework.display;

import beardFramework.core.BeardGame;
import beardFramework.gameSystem.entities.GameEntity;
import beardFramework.interfaces.IEntityVisual;
import beardFramework.display.core.BeardSprite;
import beardFramework.resources.save.data.DataComponent;


/**
 * ...
 * @author Ludo
 */
class SpriteVisual extends BeardSprite implements IEntityVisual
{
	
	public var parentEntity:GameEntity;
	
	public function new() 
	{
		super();
		
	}
	
	
	
	public function Update():Void 
	{
		
	}
	
	
	/* INTERFACE beardFramework.interfaces.IEntityVisual */
	
	public function Register():Void 
	{
		BeardGame.Get().GetContentLayer().addChild(this);
	}
	
	
	/* INTERFACE beardFramework.interfaces.IEntityVisual */
	
	public function ToData():DataComponent 
	{
		var data:DataComponent = null;
		return data;
	}
		
	override function __enterFrame(deltaTime:Int):Void 
	{
		super.__enterFrame(deltaTime);
		
		
	}
}