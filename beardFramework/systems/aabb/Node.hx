package beardFramework.systems.aabb;
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
	
	public function new() 
	{
		children = new Vector<Node>(2);
		aabbFat = new AABB();
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
				
	}
	
	public function GetSibling():Node
	{
		return (this == parent.children[0] ? parent.children[1] : parent.children[0]); 
	}
	
}