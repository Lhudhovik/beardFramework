package beardFramework.display;

import beardFramework.display.core.BeardBitmap;
import interfaces.IEntityVisual;
import openfl.display.BitmapData;
import openfl.display.PixelSnapping;

/**
 * ...
 * @author Ludo
 */
class BitmapEntityVisual extends BeardBitmap implements IEntityVisual
{

	public function new(bitmapData:BitmapData=null, pixelSnapping:PixelSnapping=null, smoothing:Bool=false) 
	{
		super(bitmapData, pixelSnapping, smoothing);
		
	}
	
}