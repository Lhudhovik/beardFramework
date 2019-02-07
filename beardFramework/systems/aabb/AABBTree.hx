package beardFramework.systems.aabb;
import beardFramework.utils.MathU;
import beardFramework.utils.MinAllocArray;
import beardFramework.utils.simpleDataStruct.SVec2;

/**
 * ...
 * @author 
 */
class AABBTree 
{

	private var invalidNodes:MinAllocArray<Node>;
	private var root:Node;
	private var margin:Float;
	private var pairs:MinAllocArray<CollisionPair>;
	private var hitAABBs:MinAllocArray<AABB>;
	private var combined:AABB;
	
	public function new() 
	{
		combined = new AABB();
		hitAABBs = new MinAllocArray<AABB>();
		pairs = new MinAllocArray<CollisionPair>();
	}
	public function Add(aabb:AABB):Void
	{
	
		if (root != null)
		{
			var node:Node = new Node();
			node.SetLeaf(aabb);
			node.UpdateAABB(margin);
			InsertNode(node, root);
		}
		else
		{
			root = new Node();
			root.SetLeaf(aabb);
			root.UpdateAABB(margin);
			
		}
	}
	public function Remove(aabb:AABB):Void
	{
		if (aabb.node != null)
		{
			aabb.node.aabbLeaf = null;
			RemoveNode(aabb.node);
		}
	}
	public function Update():Void
	{
		if (root != null)
		{
			if (root.IsLeaf())
				root.UpdateAABB(margin);
			else
			{
				invalidNodes.Clean();
				UpdateNodeHelper(root);
				
				var parent:Node;
				var sibling:Node;
				
				for (i in 0...invalidNodes.length)
				{
					parent = invalidNodes.get(i).parent;
					sibling = invalidNodes.get(i).GetSibling();
					sibling.parent = parent.parent;
					
					parent = null;
					invalidNodes.get(i).parent = null;
					
					invalidNodes.get(i).UpdateAABB(margin);
					InsertNode(invalidNodes.get(i),root)	;							
					
				}
				invalidNodes.Clean();
				
			}
		}		
	}
	public function ComputePairs():MinAllocArray<CollisionPair>
	{
		pairs.Clean();
		
		if (root == null || root.IsLeaf()) return pairs;
		
		ClearChildrenCrossFlagHelper(root);
		
		//ComputePairsHelper(root.children[0], root.children[1]);
				
		var nodeList1:List<Node> = new List();
		var nodeList2:List<Node> = new List();
		
		var node1:Node;
		var node2:Node;
		
		nodeList1.add(root.children[0]);
		nodeList2.add(root.children[1]);
		
		while (nodeList1.length > 0)
		{
			
			node1 = nodeList1.pop();
			node2 = nodeList2.pop();
			
			
			if (node1.IsLeaf())
			{
			
				if (node2.IsLeaf())
				{
					if (node1.aabbLeaf.Overlaps(node2.aabbLeaf))
						pairs.Push({ collider1: node1.aabbLeaf, collider2: node2.aabbLeaf});
				}
				else 
				{
					if (!node2.childrenCrossed){
						
						nodeList1.add(node2.children[0]);
						nodeList2.add(node2.children[1]);
						node2.childrenCrossed = true;
						
					}
					
					if (node1.aabbLeaf.Overlaps(node2.aabbFat))
					{
						//"computePairs" 
						nodeList1.add(node1);
						nodeList2.add(node2.children[0]);
					
						nodeList1.add(node1);
						nodeList2.add(node2.children[1]);
						
					}
					
					
				}
			}
			else
			{
				
				if (node2.IsLeaf())
				{
					if (!node1.childrenCrossed){
						
						nodeList1.add(node1.children[0]);
						nodeList2.add(node1.children[1]);
						node1.childrenCrossed = true;
						
					}
					
					if (node2.aabbLeaf.Overlaps(node1.aabbFat))
					{
						//"computePairs" 
						nodeList1.add(node2);
						nodeList2.add(node1.children[0]);
					
						nodeList1.add(node2);
						nodeList2.add(node1.children[1]);
						
					}
					
				}
				else
				{
					if (!node1.childrenCrossed){
						
						nodeList1.add(node1.children[0]);
						nodeList2.add(node1.children[1]);
						node1.childrenCrossed = true;
						
					}
					
					if (!node2.childrenCrossed){
						
						nodeList1.add(node2.children[0]);
						nodeList2.add(node2.children[1]);
						node2.childrenCrossed = true;
						
					}
					
					
					nodeList1.add(node1.children[0]);
					nodeList2.add(node2.children[0]);
					
					nodeList1.add(node1.children[0]);
					nodeList2.add(node2.children[1]);
					
					nodeList1.add(node1.children[1]);
					nodeList2.add(node2.children[0]);
					
					nodeList1.add(node1.children[1]);
					nodeList2.add(node2.children[1]);
									
				}
				
			}
			
		}
		
		
		
		
		
		return pairs;
		
		
	}
	public function Hit(x:Float, y:Float):MinAllocArray<AABB>
	{
		var nodes:List<Node> = new List();
		var node: Node;
		hitAABBs.Clean();
		
		if (root != null){
			
			nodes.add(root);
			
			while (nodes.length > 0)
			{
				
				node = nodes.pop();
				
				if (node.IsLeaf())
					if(node.aabbLeaf.Hit(x,y))
						hitAABBs.Push(node.aabbLeaf);
				else if (node.aabbFat.Hit(x, y))
				{
					nodes.add(node.children[0]);
					nodes.add(node.children[1]);
				}
				
			}
		}
		
		return hitAABBs;
	}
	public function RayCast(ray:Ray):RayCastResult
	{
		var nodes:List<Node> = new List();
		var node: Node;
		var currentResult:RayCastResult = {hit:false, collider:null, hitPos:{x:0, y:0}, normal:{x:0, y:0}, fraction:-1	}
		var bestResult:RayCastResult = {hit:false, collider:null, hitPos:{x:0, y:0}, normal:{x:0, y:0}, fraction:MathU.MAX	}
		
		if (root != null)
		{
			nodes.add(root);
			
			while (nodes.length > 0)
			{
				
				currentResult.hit = false;
				
				node = nodes.pop();
								
				if (node.IsLeaf())
				{
					if (node.aabbLeaf.Raycast(ray, currentResult))
					{
						if (currentResult.fraction < bestResult.fraction)
						{
							bestResult.hit = true;
							bestResult.collider = node.aabbLeaf;
							bestResult.hitPos = currentResult.hitPos;
							bestResult.normal = currentResult.normal;
							bestResult.fraction = currentResult.fraction;					
							
						}						
					}
				}
				else
				{
					if (node.aabbFat.Raycast(ray, currentResult))
					{
						
						if (currentResult.fraction < bestResult.fraction)
						{
							nodes.add(node.children[0]);
							nodes.add(node.children[1]);
						}						
					}
					
				}				
			}			
		}
			
		#if debug
		
		
		
		
		#end
		
		
		
		return bestResult;		
	}
	public function Query(aabb:AABB):MinAllocArray<AABB>
	{
		var nodes:List<Node> = new List();
		var node: Node;
		if (root != null)
			nodes.add(root);
		
		hitAABBs.Clean();
			
		while (nodes.length > 0)
		{
			
			node = nodes.pop();
			
			if (node.IsLeaf())
				if (node.aabbLeaf != aabb && aabb.Overlaps(node.aabbLeaf) )
					hitAABBs.Push(node.aabbLeaf);
			else if (node.aabbFat.Overlaps(aabb))
			{
				nodes.add(node.children[0]);
				nodes.add(node.children[1]);
			}
			
		}
		
		return hitAABBs;
		
		
		
	}
	private function UpdateNodeHelper(startNode:Node):Void
	{
		var nodeList:List<Node> = new List<Node>();
		var node:Node;
		nodeList.add(startNode);
			
		while (nodeList.length > 0)
		{
			node = nodeList.first();
			if (node.IsLeaf())
			{
				if (!node.aabbFat.Contains(node.aabbLeaf))
					invalidNodes.Push(node);
			}
			else
			{
				nodeList.add(node.children[0]);
				nodeList.add(node.children[1]);
			}
			
			nodeList.remove(node);
		}
	
	}
	private function InsertNode(node:Node, parent:Node):Void
	{
		
		var insertionParent : Node = parent;
		
		if (parent.IsLeaf())
		{
			var newParent:Node = new Node();
			
			if (parent != root)
			{
				newParent.parent = parent.parent;
				if (parent == newParent.parent.children[0]) newParent.parent.children[0] = newParent;
				else  newParent.parent.children[1] = newParent;
			}
			newParent.SetBranch(node, parent);
			
			insertionParent = newParent;
		}
		else
		{
			
			
			combined.Combine(parent.children[0].aabbFat,node.aabbFat);
			var surfaceDiff0 : Float = combined.Surface() - parent.children[0].aabbFat.Surface();
		
			combined.Combine(parent.children[1].aabbFat, node.aabbFat);
			var surfaceDiff1 : Float = combined.Surface() - parent.children[1].aabbFat.Surface();
			
			if (surfaceDiff0 < surfaceDiff1) InsertNode(node, parent.children[0]);
			else InsertNode(node, parent.children[1]);
			
		}
		
		insertionParent.UpdateAABB(margin);
		
	}
	private function RemoveNode(node:Node):Void
	{
		
		if (node.parent != null)
		{
			var parent:Node = node.parent;
			var sibling:Node = node.GetSibling();
			if (parent.parent != null)
			{
				sibling.parent = parent.parent;
				if (parent == parent.parent.children[0])
					parent.parent.children[0] = sibling;
				else 
					parent.parent.children[1] = sibling;				
			}
			else
			{
				root = sibling;
				sibling.parent = null;
			}
			
			node.aabbFat = null;
			node.parent = null;
			node = null;			
		}
		else
		{
			root = null;
		}
		
	}
	private function ClearChildrenCrossFlagHelper(node:Node):Void
	{
		node.childrenCrossed = false;
		
		if (!node.IsLeaf())
		{
			ClearChildrenCrossFlagHelper(node.children[0]);
			ClearChildrenCrossFlagHelper(node.children[1]);
		}
		
		
	}
	private function ComputePairsHelper(node1:Node, node2:Node):Void
	{
		
		if (node1.IsLeaf())
		{
			
			if (node2.IsLeaf())
			{
				if (node1.aabbLeaf.Overlaps(node2.aabbLeaf))
					pairs.Push({ collider1: node1.aabbLeaf, collider2: node2.aabbLeaf});
			}
			else 
			{
				CrossChildren(node2);
				ComputePairsHelper(node1, node2.children[0]);
				ComputePairsHelper(node1, node2.children[1]);
			}
		}
		else
		{
			
			if (node2.IsLeaf())
			{
				CrossChildren(node1);
				ComputePairsHelper(node1.children[0], node2);
				ComputePairsHelper(node1.children[1], node2);
				
			}
			else
			{
				CrossChildren(node1);
				CrossChildren(node2);
				ComputePairsHelper(node1.children[0], node2.children[0]);
				ComputePairsHelper(node1.children[0], node2.children[1]);
				ComputePairsHelper(node1.children[1], node2.children[0]);
				ComputePairsHelper(node1.children[1], node2.children[1]);
			
			}
			
		}
		
	}
	private function CrossChildren(node:Node):Void
	{
		if (!node.childrenCrossed)
		{
			ComputePairsHelper(node.children[0], node.children[1]);
			node.childrenCrossed = true;
		}
	}
	
	
	
}