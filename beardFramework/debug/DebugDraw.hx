package beardFramework.debug;
import beardFramework.graphics.core.Renderer;
import beardFramework.graphics.batches.Batch;
import beardFramework.graphics.batches.LineBatch;
import beardFramework.resources.options.OptionsManager;
import beardFramework.utils.graphics.Color;
import beardFramework.resources.MinAllocArray;
import beardFramework.utils.simpleDataStruct.SRect;
import beardFramework.utils.simpleDataStruct.SVec2;
import beardFramework.utils.simpleDataStruct.SVec3;
import haxe.ds.Vector;

/**
 * ...
 * @author 
 */
class DebugDraw 
{
	static var linesBatch:Batch;
	static var rectsBatch:Batch;
	static var lines:List<Int>;
	static var rects:List<Int>;
	static var wireFrameRects:Map<Int, Vector<Int>>;
	
	
	public function new() 
	{
		
	}
	
	public static function DrawLine(start:SVec2, end:SVec2, color: Color = 0x000000ff/*persistent:Bool = false*/):Int
	{
		if (linesBatch == null){
			linesBatch = cast Renderer.Get().GetRenderable("debugLine");
			lines = new List();
		}
		
		var index:Int;
		
		var data:Vector<Float> =  Vector.fromArrayCopy([start.x, start.y, 0, color.getRedf(),color.getGreenf(),color.getBluef(),color.getAlphaf(), end.x, end.y, 0,color.getRedf(),color.getGreenf(),color.getBluef(),color.getAlphaf()]);
		
		index = linesBatch.AddData(data);
		lines.add(index);
		
		return index;
		
	}
	
	public static function DrawFullRectangle(x:Float, y:Float, width:Float, height:Float, color:Color = 0x000000ff):Int
	{
		
		if (rectsBatch == null){
			rectsBatch = cast Renderer.Get().GetRenderable("debugRect");
			rects = new List();
		}
	
		var data:Vector<Float> = Vector.fromArrayCopy([
		
		0*width + x, 1*height + y, 0,color.getRedf(),color.getGreenf(),color.getBluef(),color.getAlphaf(),
		1*width + x, 1*height + y, 0,color.getRedf(),color.getGreenf(),color.getBluef(),color.getAlphaf(),
		1*width + x, 0*height + y, 0,color.getRedf(),color.getGreenf(),color.getBluef(),color.getAlphaf(),
		0*width + x, 0*height + y, 0,color.getRedf(),color.getGreenf(),color.getBluef(),color.getAlphaf()
		
		]);
		
		
		var index:Int;
		
		index = rectsBatch.AddData(data);
		rects.add(index);
		
		return index;
		
	}
	
	public static function DrawWireFrameRectangle(x:Float, y:Float, width:Float, height:Float, color:UInt = 0x000000ff):Int
	{
	
		if (linesBatch == null){
			linesBatch = cast Renderer.Get().GetRenderable("debugLine");
			lines = new List();
		}
		if( wireFrameRects == null) wireFrameRects = new Map();
		//var data:Vector<Float> = Vector.fromArrayCopy([
			//x, y, 0, ColorU.getRed(color),ColorU.getGreen(color),ColorU.getBlue(color),ColorU.getAlpha(color), x+width, y, 0,ColorU.getRed(color),ColorU.getGreen(color),ColorU.getBlue(color),ColorU.getAlpha(color),
			//x+width, y, 0, ColorU.getRed(color),ColorU.getGreen(color),ColorU.getBlue(color),ColorU.getAlpha(color), x+width, y+height, 0,ColorU.getRed(color),ColorU.getGreen(color),ColorU.getBlue(color),ColorU.getAlpha(color),
			//x, y+height, 0, ColorU.getRed(color),ColorU.getGreen(color),ColorU.getBlue(color),ColorU.getAlpha(color), x+width, y+height, 0,ColorU.getRed(color),ColorU.getGreen(color),ColorU.getBlue(color),ColorU.getAlpha(color),
			//x, y, 0, ColorU.getRed(color),ColorU.getGreen(color),ColorU.getBlue(color),ColorU.getAlpha(color), x, y+height, 0,ColorU.getRed(color),ColorU.getGreen(color),ColorU.getBlue(color),ColorU.getAlpha(color)
		//]);
		//
		//var indices:Array<Int> = linesBatch.AddMultipleData(data);
		//
		//wireFrameRects[indices[0]] = Vector.fromArrayCopy(indices);
		//
		//
		
		//
	//
		var firstIndex:Int = DrawLine({x:x , y :y}, {x: x + width, y :y}, color);
		
		wireFrameRects[firstIndex] = new Vector(4);
		wireFrameRects[firstIndex][0] = firstIndex;
		wireFrameRects[firstIndex][1] = DrawLine({x:x+width , y :y}, {x: x+width, y :y+height}, color);
		wireFrameRects[firstIndex][2] = DrawLine({x: x, y :y}, {x:x , y :y+height}, color);
		wireFrameRects[firstIndex][3] = DrawLine({x:x , y :y+height}, {x: x+width, y :y+height}, color);
		
		
		
		
		//return indices[0];		
		return firstIndex;		
		
	}
	
	public static function Flush():Void
	{
		if(linesBatch != null)	linesBatch.Flush();
		if(rectsBatch != null) rectsBatch.Flush();
			
	}
	
	public static function RemoveLine(id:Int):Void
	{
		
		if (linesBatch != null)
		{
			linesBatch.FreeBufferIndex(id);
			lines.remove(id);
			
		}
		
	}
	
	public static function RemoveFullRectangle(id:Int):Void
	{
		
		if (rectsBatch != null)
		{
			rectsBatch.FreeBufferIndex(id);
			rects.remove(id);
			
		}
		
	}
	
	public static function RemoveWireFrameRectangle(id:Int):Void
	{
		
		if (linesBatch != null)
		{
			for (i in 0...4)
				RemoveLine(wireFrameRects[id][i]);
			wireFrameRects[id] = null;
			
		}
		
	}
	
}
