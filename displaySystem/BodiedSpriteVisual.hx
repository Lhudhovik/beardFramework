package beardFramework.displaySystem;

import beardFramework.displaySystem.SpriteVisual;
import nape.phys.Body;

/**
 * ...
 * @author Ludo
 */
class BodiedSpriteVisual extends SpriteVisual 
{

	private var body:Body;
	public function new() 
	{
		super();
		
	}
	
	override function __enterFrame(deltaTime:Int):Void 
	{
		super.__enterFrame(deltaTime);
		
		if (body != null){
			this.x = body.position.x;
			this.y = body.position.y;
		}
	}
		
	
}