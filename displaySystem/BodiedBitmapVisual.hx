package beardFramework.displaySystem;

import nape.phys.Body;
import openfl.display.BitmapData;
import openfl.display.PixelSnapping;

/**
 * ...
 * @author Ludo
 */
class BodiedBitmapVisual extends BitmapVisual
{

	private var body:Body;
	public function new(bitmapData:BitmapData=null, pixelSnapping:PixelSnapping=null, smoothing:Bool=false) 
	{
		super(bitmapData, pixelSnapping, smoothing);
		
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