package beardFramework.display;

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
		
	override function __enterFrame(deltaTime:Int):Void 
	{
		super.__enterFrame(deltaTime);
		
		
	}
}