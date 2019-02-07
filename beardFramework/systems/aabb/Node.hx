package beardFramework.systems.aabb;
import beardFramework.debug.DebugDraw;
import beardFramework.utils.ColorU;
import haxe.ds.Vector;

/**
 * ...
 * @author 
 */
class Node 
{

	public var parent:Node;
	public var children:Vector<Node>;
	public var childrenCrossed:Bool;
	public var aabbFat:AABB;
	public var aabbLeaf:AABB;
	#if debug
	private var debugFat:Int;
	private var debugLeaf:Int;
	
	#end
	public function new() 
	{
		children = new Vector<Node>(2);
		aabbFat = new AABB();
		debugFat = -1;
		debugLeaf = -1;
	}
	
	public inline function IsLeaf():Bool
	{
		return children[0] == null;
	}
	
	public function SetBranch(child1:Node, child2:Node):Void
	{
		child1.parent = this;
		child2.parent = this;
		
		children[0] = child1;
		children[1] = child2;
	}
	
	public function SetLeaf(aabb:AABB):Void
	{
		
		children[0] = null;
		children[1] = null;
			
		aabbLeaf = aabb;
		
		if (debugLeaf >= 0)
		{
			DebugDraw.RemoveWireFrameRectangle(debugLeaf);
			
		}
		
		
		debugLeaf = DebugDraw.DrawWireFrameRectangle(aabbLeaf.topLeft.x, aabbLeaf.topLeft.y, aabbLeaf.bottomRight.x - aabbLeaf.topLeft.x, aabbLeaf.bottomRight.y - aabbLeaf.topLeft.y,ColorU.BLUE );
		
		
	}
	
	public function UpdateAABB(margin:Float):Void
	{
		if (IsLeaf())
		{
			aabbFat.topLeft.x = aabbLeaf.topLeft.x - margin;
			aabbFat.topLeft.y = aabbLeaf.topLeft.y - margin;
			aabbFat.bottomRight.x = aabbLeaf.bottomRight.x + margin;
			aabbFat.bottomRight.y = aabbLeaf.bottomRight.y + margin;
		}
		else
			aabbFat.Combine(children[0].aabbFat , children[0].aabbFat);
		
			
		if (debugFat >= 0)
		{
			DebugDraw.RemoveWireFrameRectangle(debugFat);
			
		}
		
		
		debugFat = DebugDraw.DrawWireFrameRectangle(aabbFat.topLeft.x, aabbFat.topLeft.y, aabbFat.bottomRight.x - aabbFat.topLeft.x, aabbFat.bottomRight.y - aabbFat.topLeft.y,ColorU.RED );
		
	}
	
	public function GetSibling():Node
	{
		return (this == parent.children[0] ? parent.children[1] : parent.children[0]); 
	}
	
}