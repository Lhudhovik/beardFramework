package beardFramework.utils;
import beardFramework.core.BeardGame;
import beardFramework.graphics.core.RenderedObject;
import beardFramework.utils.GeomUtils.SimplePoint;
import haxe.ds.Vector;

/**
 * ...
 * @author 
 */
class ScreenRegion 
{
	private var position:SimplePoint;
	private var width:Int;
	private var height:Int;
	private var objects:MinAllocArray<RegionObject>;
	private var subRegions:Vector<ScreenRegion>;
	
	public function new(width:Int, height:Int, x:Float = 0, y:Float = 0) 
	{
		position = {x:x, y:y};
		this.width = width;
		this.height = height;
		objects = new MinAllocArray();
	}
	
	public function Divide():Void
	{
		subRegions = new Vector(4);
		subRegions.set(0, new ScreenRegion(this.width * 0.5, this.height * 0.5, this.position.x, this.position.y);
		subRegions.set(1, new ScreenRegion(this.width * 0.5, this.height * 0.5, this.position.x + this.width*0.5, this.position.y);
		subRegions.set(2, new ScreenRegion(this.width * 0.5, this.height * 0.5, this.position.x, this.position.y+this.height*0.5);
		subRegions.set(3, new ScreenRegion(this.width * 0.5, this.height * 0.5, this.position.x+this.width*0.5, this.position.y+this.height*0.5);
		
		var object:RegionObject;
		for (region in subRegions)
		{
			for (i in 0...objects.length)
			{
				object = objects.get(i);
				if (region.ContainsObject(BeardGame.Get().GetLayer(object.layer).renderedObjects.get(object.object)))
					region.Insert(BeardGame.Get().GetLayer(object.layer).renderedObjects[object.object]);
			
			}
			
		}
		
	}
	
	public inline function ContainsObject(object:RenderedObject):Bool
	{
		return ((object.x + object.width >= position.x) && (object.y + object.height >= position.y) && (object.x < position.x + width) && (object.y < position.y + height));
	}
	
	public inline function ContainsPoint(point:SimplePoint):Bool{
		return  ((point.x >= position.x) && (point.y >= position.y) && (point.x  < position.x + width) && (point.y < position.y + height))
	}
	
	public function Insert(object:RenderedObject):Void
	{
		
		for (region in subRegions)
		{
			for (i in 0...objects.length)
			{
				object = objects.get(i);
				if (region.ContainsObject(object)
					region.Insert(object);
			
			}
			
		}
		
		objects.Push({layer:object.layer.id, object:object.stockageID});
		
	}
}

typedef RegionObject =
{
	public var layer:Int;
	public var object:Int;
	
}