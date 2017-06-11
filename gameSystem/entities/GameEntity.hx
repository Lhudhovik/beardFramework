package beardFramework.gameSystem.entities;
import beardFramework.interfaces.IEntityVisual;
/* ...
 * @author Ludo
 */
class GameEntity
{

	public var x(default,set):Float;
	public var y(default,set):Float;
	public var isVirtual(default,null):Bool;
	public var visual:IEntityVisual;
	
		
	public function new(x:Float = 0, y:Float = 0) 
	{
		this.x = x;
		this.y = y;
		
		isVirtual = false;
	}
	
	
	private function OnUpdate():Void
	{
		
	}
	
	public function Virtualize():Void{
		//clear visual
		//remove Listeners if needed
		
	}
	
	public function Devirtualize():Void{
		//create visual
		//re-add listeners if needed
	}
	
	public function set_x(value:Float):Float
	{
		if (visual != null)
		visual.x = value;
		return value;
	}
	
	//public function get_x():Float
	//{
		//return visual != null? visual.x : 0;
	//}
	
	public function set_y(value:Float):Float
	{
		if (visual != null)
		visual.y = value;
		return value;
	}
	
	//public function get_y():Float
	//{
		//return visual != null? visual.y : 0;
	//}
}