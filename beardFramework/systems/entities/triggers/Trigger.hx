package systems.entities.triggers;

import beardFramework.systems.entities.GameEntity;
import beardFramework.physics.PhysicsManager;
import nape.phys.Body;
import nape.shape.Polygon;
import nape.shape.ShapeType;

/**
 * ...
 * @author Ludo
 */
class Trigger extends GameEntity 
{
	private var body:Body;
	private var width : Float;
	private var height:Float;
	public function new(x:Float = 0, y:Float = 0, width:Float = 10, height = 10 ) 
	{
		super(x, y);
		this.width = width;
		this.height = height;
	}
	override public function Devirtualize():Void 
	{
		super.Devirtualize();
		
		body = PhysicsManager.Get().GetBody();
		body.shapes.add(PhysicsManager.Get().GetPolygon().localVerts = Polygon.box(width, height);
		body.position.x = this.x;
		body.position.y = this.y;
	}
}