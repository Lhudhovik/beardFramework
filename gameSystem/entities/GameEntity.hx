package beardFramework.gameSystem.entities;
import beardFramework.displaySystem.GameEntityVisual;

/**
 * ...
 * @author Ludo
 */
class GameEntity
{

	private var x:Float;
	private var y:Float;
	private var visual:GameEntityVisual;
	
	public function new(x:Float = 0, y:Float = 0) 
	{
		this.x = x;
		this.y = y;	
	}
		
	public function Virtualize():Void{
		//clear visual
		
	}
	
	public function Devirtualize():Void{
		//create visual
	}
	
}