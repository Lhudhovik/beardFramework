package beardFramework.graphics.screens.regions;
import beardFramework.core.BeardGame;
import beardFramework.graphics.core.RenderedObject;
import beardFramework.graphics.rendering.Renderer;
import beardFramework.resources.MinAllocArray;
import beardFramework.utils.libraries.StringLibrary;
import haxe.ds.Vector;
import lime.graphics.opengl.GL;

/**
 * ...
 * @author 
 */
class RegionGrid 
{
	private var maxLevel:Int;
	private var width:Int; //to obtain the size of a cell : width/(2^level)
	private var height:Int;
	private var regions:MinAllocArray<Region>;
	private var gridObjects:Map<String, GridObject>;
	
	private var widthLevel:Int;
	private	var heightLevel:Int;
	private	var objectLevel : Int;
	private	var minCellX:Int;
	private	var minCellY:Int;
	private	var maxCellX:Int;
	private	var maxCellY:Int;
	private var cellsWidth:Vector<Int>;
	private var cellsHeight:Vector<Int>;
	
	private var log2:Float;
	private var utilGridObject:GridObject;
	
	public function new(width:Int, height:Int, maxLevel:Int =5 ) 
	{
		this.width = width;
		this.height = height;
		this.maxLevel = maxLevel;
		cellsWidth = new Vector(maxLevel+1);
		cellsHeight = new Vector(maxLevel+1);
		gridObjects = new Map();
		regions = new MinAllocArray(Math.round((Math.pow(4,maxLevel+1)-1)/3));
		regions.set(0,new Region(this.width, this.height,0,0, 0));
		cellsWidth[0] = this.width;
		cellsHeight[0] = this.height;
		log2 = Math.log(2);
		
		//#if debug
		//for (i in 0...maxLevel+1)
			//Renderer.Get().InitBatch("grid" + i,"", [{name:"vertexShader", type:GL.VERTEX_SHADER}, {name:"fragmentShader", type:GL.FRAGMENT_SHADER}]);
			//
			//
		//#end
		GenerateRegionChildren(regions.get(0));
		
	}
	
	public function Resize(newWidth:Int, newHeight:Int):Void
	{
		
		this.width = newWidth;
		this.height = newHeight;
		regions.Clean();
		regions.set(0, new Region(this.width, this.height, 0, 0, 0));
		GenerateRegionChildren(regions.get(0));
		
		for (object in BeardGame.Get().GetContentLayer().renderedObjects)	AddObject(object);
		for (object in BeardGame.Get().GetUILayer().renderedObjects)		AddObject(object);
		
		//for (i in 0...regions.length)
			//trace("index : " + i + regions.get(i));
			
	 
	}
	
	public function GenerateRegionChildren(region:Region):Void
	{
		if (region.level < maxLevel)
		{
			
			var x:Float;
			var y:Float;
			var createdRegion:Region;
			
			cellsWidth[region.level + 1] = Std.int(region.width * 0.5);
			cellsHeight[region.level + 1] = Std.int(region.height * 0.5);
			
			for (i in 0...4)
			{			
				if (i % 2 == 0)			x = region.x;
				else x = region.x + region.width * 0.5;
				
				if (i < 2) y = region.y;
				else y = region.y + region.height * 0.5;
				
				createdRegion = new Region(region.width * 0.5, region.height * 0.5, x, y, region.level+1);
				
				regions.set(GetCellIndex(GetCloserCellX(createdRegion.x, createdRegion.level), GetCloserCellY(createdRegion.y, createdRegion.level),createdRegion.level), createdRegion);
				region.regionChildren.set(i,createdRegion);
				GenerateRegionChildren(createdRegion);
			}
			
			
			
		
		}
				
		
		
		
		
	}
	
	
	
	public function AddObject(renderedObject:RenderedObject):Void
	{
		//First select the level
		//#if debug
		//if (renderedObject.renderingBatch.substr(0,4) == "grid") return;
		//#end
		widthLevel =  Std.int( Math.log(width/renderedObject.width)/log2);
		heightLevel = Std.int(Math.log(height / renderedObject.height)/log2);
				
		objectLevel = heightLevel > widthLevel ? widthLevel : heightLevel;
		if (objectLevel > maxLevel) objectLevel = maxLevel;
		
		minCellX = GetCloserCellX(renderedObject.x,objectLevel);
		minCellY = GetCloserCellY(renderedObject.y,objectLevel);
		maxCellX = GetCloserCellX(renderedObject.x + renderedObject.width,objectLevel);
		maxCellY = GetCloserCellY(renderedObject.y + renderedObject.height,objectLevel);
		
		if (gridObjects[renderedObject.name] == null){
			gridObjects[renderedObject.name] = {layer:renderedObject.layer.id, cells:new MinAllocArray(4), level:objectLevel};
		}
		var index:Int;
		for (i in minCellX...maxCellX+1)
			for (j in minCellY...maxCellY + 1){
				index = GetCellIndex(i, j, objectLevel);
				regions.get(GetCellIndex(i, j, objectLevel)).stockedObjects.Push(renderedObject.name);
				gridObjects[renderedObject.name].cells.UniquePush(index);
			}
		
		
	}
	
	public function MoveObject(renderedObject:RenderedObject):Void
	{
		
		widthLevel =  Std.int( Math.log(width/renderedObject.width)/log2);
		heightLevel = Std.int(Math.log(height / renderedObject.height)/log2);
				
		objectLevel = heightLevel > widthLevel ? widthLevel : heightLevel;
		if (objectLevel > maxLevel) objectLevel = maxLevel;
		
		minCellX = GetCloserCellX(renderedObject.x,objectLevel);
		minCellY = GetCloserCellY(renderedObject.y,objectLevel);
		maxCellX = GetCloserCellX(renderedObject.x + renderedObject.width,objectLevel);
		maxCellY = GetCloserCellY(renderedObject.y + renderedObject.height,objectLevel);
		
		if (gridObjects[renderedObject.name] != null)
		{
			if (gridObjects[renderedObject.name].level != objectLevel)
				gridObjects[renderedObject.name].cells.Clean();
			
		}
	
		
		
	}
	
	
	public function RemoveObject(renderedObject:RenderedObject):Void
	{
		
		if (gridObjects.exists(renderedObject.name))
		{
			var i : Int = 0;
			while (i++ < gridObjects[renderedObject.name].cells.length)
			{
				regions.get(gridObjects[renderedObject.name].cells.get(i)).stockedObjects.Remove(renderedObject.name);
			}
		
			gridObjects[renderedObject.name].cells.Clean();
			
			
		}
		
		
	}
	
	private inline function GetCloserCellX(x:Float, level:Int):Int
	{
		
		return Std.int(x / cellsWidth[level]);
	}
	
	private inline function GetCloserCellY(y:Float, level:Int):Int
	{
		return  Std.int(y / cellsHeight [level]);
	}
	
	private inline function GetCellIndex(column:Int, row:Int, level:Int):Int
	{
		return Std.int(GetArrayOffset(level) + column + row * (this.width/cellsWidth[level]));
	}
	
	private inline function GetArrayOffset(level:Int):Int
	{
		var offset:Float = 0;
		if (level > 0)
		{
			for (i in 0...level)
			{
				offset += Math.pow(4, i);
				
			}
		}
		
		return Math.floor(offset);
		
	}
	
	public function TestPointCollision(x:Int, y:Int):RenderedObject
	{
		var returnedObject:RenderedObject = null;
		var testedObject:RenderedObject;
			
		for (i in 0.../*maxLevel +*/ 1)
		{
			minCellX = GetCloserCellX(x, maxLevel-i);
			minCellY = GetCloserCellY(y, maxLevel-i);
			//trace("number of regions : " + regions.length + " minCellX " +minCellX + " minCellY" + minCellY + "index : " + GetCellIndex(minCellX, minCellY, maxLevel - i));
			minCellX = GetCellIndex(minCellX, minCellY, maxLevel - i);
		
			if (minCellX > regions.length || minCellX<0 ||regions.get(minCellX) == null ) continue;
			
			for (i in 0...regions.get(minCellX).stockedObjects.length){
				
				StringLibrary.utilString = regions.get(minCellX).stockedObjects.get(i);
				testedObject = BeardGame.Get().GetLayer(gridObjects[StringLibrary.utilString].layer).renderedObjects[StringLibrary.utilString];
				if ((x > testedObject.x) && (x < testedObject.x + testedObject.width) && (y > testedObject.y) && (y < testedObject.y + testedObject.height) && (returnedObject == null || returnedObject.z > testedObject.z))
				{
					returnedObject = testedObject;
				}
			}
			
			//if (returnedObject != null) break;
			
		}
				
		return returnedObject;
		
	}
	
	public function ToString():String
	{
		var string:String = "";
		
		for (i in 0...regions.length)
		{
		
			if (regions.get(i) == null || regions.get(i).stockedObjects == null) continue;
			string += "Region " + i + " ";
		
			for (j in 0...regions.get(i).stockedObjects.length)
				string += regions.get(i).stockedObjects.get(j) + "  ";
			
		}
		
		string += "\n";
		
		return string;
	}
	//
	//public function TestCollisionBetween(object1:RenderedObject, object2:RenderedObject):Bool
	//{
		//
	//}
	//
	//public function GetCollidingObjectsWith(object:RenderedObject):Array<StockedObject>
	//{
		//
	//}
	//
	//
}