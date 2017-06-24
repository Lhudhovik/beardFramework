package beardFramework.displaySystem.ui.components;

import beardFramework.interfaces.IUIComponent;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.PixelSnapping;

/**
 * ...
 * @author Ludo
 */
class UIBitmapComponent extends Bitmap implements IUIComponent
{
	public function new(bitmapData:BitmapData=null, pixelSnapping:PixelSnapping=null, smoothing:Bool=false) 
	{
		super(bitmapData, pixelSnapping, smoothing);
		keepRatio = true;
	}
	
	
	/* INTERFACE beardFramework.interfaces.IUIComponent */
	
	public var vAlign:UInt;
	
	public var hAlign:UInt;
	
	public var fillPart:Float;
	
	public var keepRatio:Bool;
	
}