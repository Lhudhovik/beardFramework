package beardFramework.graphics.screens.regions;
import beardFramework.core.BeardGame;
import beardFramework.graphics.core.RenderedObject;
import beardFramework.graphics.core.Visual;
import beardFramework.graphics.rendering.Renderer;
import beardFramework.utils.MinAllocArray;

/**
 * ...
 * @author 
 */
class Region 
{
	
	public var stockedObjects:MinAllocArray<String>;
	public var level:Int;
	public var width:Float;
	public var height:Float;
	public var x:Float;
	public var y:Float;
	public var regionChildren:MinAllocArray<Region>;
	#if debug
	public var visual:Visual;
	#end
	
	public function new(width:Float, height:Float, x:Float, y:Float, level:Int) 
	{
		this.width = width;
		this.height = height;
		this.level = level;
		this.x = x;
		this.y = y;
		stockedObjects = new MinAllocArray();
		regionChildren = new MinAllocArray(4);
		#if debug
		//if(level >= 1){
		//visual = new Visual("objectiv_button_play_freeround_over_hd","menuHD" );
		//visual.x = this.x;
		//visual.y = this.y;
		//visual.width = this.width;
		//visual.height = this.height;
		////visual.renderingBatch = "grid" + level;
		//BeardGame.Get().GetLayer(BeardGame.Get().CONTENTLAYER).Add(visual);
		//visual.z = -level;
		//
		//}
		#end
	}
	
	public function toString():String
	{
		return "width : " + width + " height : " +height + " x : " +x + " y : " + y + " level : " +level + stockedObjects.toString();
	}
	
}