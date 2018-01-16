package beardFramework.display;

import beardFramework.core.BeardGame;
import beardFramework.gameSystem.entities.GameEntity;
import beardFramework.interfaces.IEntityVisual;
import beardFramework.display.core.BeardSprite;


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
		BeardGame.Game().GetContentLayer().addChild(this);
	}
		
	override function __enterFrame(deltaTime:Int):Void 
	{
		super.__enterFrame(deltaTime);
		
		
	}
}