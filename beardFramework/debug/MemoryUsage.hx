package beardFramework.debug;
import beardFramework.core.BeardGame;
import beardFramework.graphics.text.TextField;
import haxe.Timer;
import lime.system.System;

using beardFramework.utils.SysPreciseTime;

/**
 * FPS class extension to display memory usage.
 * @author Kirill Poletaev
 */
class MemoryUsage extends TextField
{
	private var times:Array<Float>;
	private var memPeak:Float = 0;

	public function new(inX:Float = 10.0, inY:Float = 10.0, inCol:Int = 0x000000) 
	{
		super("FPS: ","",10,"FPS");
		
		x = inX;
		y = inY;
		
		times = [];
		
		width = 150;
		height = 70;
		this.color = inCol;
		alignment = Alignment.LEFT;
		autoAdjust = AutoAdjust.ADJUST_TEXT;
		
	}

	
	public function UpdateFPS():Void
	{	
		var now = untyped __global__.__time_stamp();
		times.push(now);
				
		while (times[0] < now - 1)
			times.shift();
					
		var mem:Float = Math.round(untyped __global__.__hxcpp_gc_used_bytes () / 1024 / 1024 * 100)/100;
		if (mem > memPeak) memPeak = mem;
		
		if (visible)
		{	
			//SetText( "FPS: " + times.length + "\nMEM: " + mem + " MB\nMEM peak: " + memPeak + " MB");	
		}
	}
	
}