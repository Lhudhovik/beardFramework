package beardFramework.systems.aabb;
import beardFramework.core.BeardGame;
import beardFramework.debug.DebugDraw;
import beardFramework.utils.graphics.Color;
import beardFramework.utils.math.MathU;
import beardFramework.resources.MinAllocArray;
import beardFramework.utils.Tags;
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
	
	public function new(margin:Float) 
	{
		combined = new AABB();
		hitAABBs = new MinAllocArray<AABB>();
		pairs = new MinAllocArray<CollisionPair>();
		invalidNodes = new MinAllocArray<Node>();
		this.margin = margin;
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
	
	public function UpdateTree():Void
	{
		
		if (root != null)
		{
			if (root.IsLeaf())
				root.UpdateAABB(margin);
			else
			{
				invalidNodes.Clean();
				var nodeList:List<Node> = new List<Node>();
				var node:Node;
				nodeList.add(root);
					
				while (nodeList.length > 0)
				{
					node = nodeList.first();
					if (node.IsLeaf())
					{

						if (node.aabbLeaf.needUpdate && !node.aabbFat.Contains(node.aabbLeaf)){
							node.aabbLeaf.needUpdate = false;
							invalidNodes.Push(node);
						}
					}
					else
					{
						nodeList.add(node.children[0]);
						nodeList.add(node.children[1]);
					}
					
					nodeList.remove(node);
				}
				
				var parent:Node;
				var sibling:Node;
				
				for (i in 0...invalidNodes.length)
				{
					parent = invalidNodes.get(i).parent;
					sibling = invalidNodes.get(i).GetSibling();
					if (parent == root) root = sibling;
					else{
						sibling.parent = parent.parent;
						if (parent == parent.parent.children[0]) parent.parent.children[0] = sibling;
						else parent.parent.children[1] = sibling;
					}
					
					parent.Dispose();
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
				
				if (node.IsLeaf()){
					
					if(node.aabbLeaf.Hit(x,y))
						hitAABBs.Push(node.aabbLeaf);
				}
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
		var currentResult:RayCastResult = {hit:false, collider:null, hitPos:{x:0, y:0}, normal:{x:0, y:0}, fraction:MathU.MAX	}
		var bestResult:RayCastResult = {hit:false, collider:null, hitPos:{x:0, y:0}, normal:{x:0, y:0}, fraction:MathU.MAX	}
		
		if (root != null)
		{
			nodes.add(root);
			
			while (nodes.length > 0)
			{
				
				currentResult.fraction =  MathU.MAX;
				
				node = nodes.pop();
								
				if (node.IsLeaf())
				{
					
					
					if ((ray.filterTags == 0 || Tags.HasTag(ray.filterTags, node.aabbLeaf.tags)) && node.aabbLeaf.Raycast(ray, currentResult))
					{
						if (MathU.Abs(currentResult.fraction)< MathU.Abs(bestResult.fraction))
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
						
						if (MathU.Abs(currentResult.fraction)< MathU.Abs(bestResult.fraction))
						{
							nodes.add(node.children[0]);
							nodes.add(node.children[1]);
						}						
					}
					
				}				
			}			
		}
		if (ray.callback != null && bestResult.hit) ray.callback( bestResult);
			
		#if debug
		if (bestResult.hit == true)
		{
			//trace(bestResult.fraction);
			var end:SVec2 = {x: ray.start.x + ray.dir.x * ray.length, y :ray.start.y + ray.dir.y * ray.length};
			//trace(end);
			//trace({x: ray.start.x + ray.dir.x * ray.length * 0.9, y :ray.start.y + ray.dir.y * ray.length*0.9});
			DebugDraw.DrawLine(ray.start, bestResult.hitPos, Color.RED);
			DebugDraw.DrawLine({x: bestResult.hitPos.x, y:bestResult.hitPos.y + 3} , {x: ray.start.x + ray.dir.x * ray.length, y :ray.start.y + ray.dir.y * ray.length + 3} , Color.GREEN);
		
		}
		else
		{
			var end:SVec2 = {x: ray.start.x + (ray.dir.x * ray.length), y :ray.start.y + (ray.dir.y * ray.length)};
			DebugDraw.DrawLine(ray.start, end, Color.RED);
		}

		
		
		
		#end
		
		
		
		return bestResult;		
	}
	
	public function RayCastMultiple(ray:Ray):Array<RayCastResult>
	{
		var nodes:List<Node> = new List();
		var node: Node;
		var currentResult:RayCastResult = {hit:false, collider:null, hitPos:{x:0, y:0}, normal:{x:0, y:0}, fraction:MathU.MAX	}
		//var bestResult:RayCastResult = {hit:false, collider:null, hitPos:{x:0, y:0}, normal:{x:0, y:0}, fraction:MathU.MAX	}
		var results:Array<RayCastResult>= [];
		if (root != null)
		{
			nodes.add(root);
			
			while (nodes.length > 0)
			{
				
				currentResult.fraction =  MathU.MAX;
				
				node = nodes.pop();
								
				if (node.IsLeaf())
				{
					if ((ray.filterTags == 0 || Tags.HasTag(ray.filterTags, node.aabbLeaf.tags)) && node.aabbLeaf.Raycast(ray, currentResult))
						results.push(  {hit:true, collider:node.aabbLeaf, hitPos:{x:currentResult.hitPos.x, y:currentResult.hitPos.y}, normal:{x:currentResult.normal.x, y:currentResult.normal.y}, fraction:currentResult.fraction});
					
				}
				else
				{
					if (node.aabbFat.Raycast(ray, currentResult))
					{
						
						nodes.add(node.children[0]);
						nodes.add(node.children[1]);
					
					}
					
				}				
			}			
		}
		
		results.sort(OrderRayCastResults);
		if (ray.callback != null && results.length > 0) ray.callback( results[0]);
			
		#if debug
		if (results.length > 0)
		{
			for (i in 0...results.length)
			{
				var end:SVec2 = {x: ray.start.x + ray.dir.x * ray.length, y :ray.start.y + ray.dir.y * ray.length};
				//trace(end);
				//trace({x: ray.start.x + ray.dir.x * ray.length * 0.9, y :ray.start.y + ray.dir.y * ray.length*0.9});
				DebugDraw.DrawLine(ray.start, results[i].hitPos, Color.RED);
				DebugDraw.DrawLine({x: results[i].hitPos.x, y:results[i].hitPos.y + i*3} , {x: ray.start.x + ray.dir.x * ray.length, y :ray.start.y + ray.dir.y * ray.length + i*3} , Color.GREEN);
		
				
			}
			
		}
		else
		{
			var end:SVec2 = {x: ray.start.x + (ray.dir.x * ray.length), y :ray.start.y + (ray.dir.y * ray.length)};
			DebugDraw.DrawLine(ray.start, end, Color.RED);
		}

		
		
		
		#end
		
		
		
		return results;		
	}
	
	private inline function OrderRayCastResults(result1:RayCastResult, result2:RayCastResult):Int
	{
		
		return result1.fraction < result2.fraction ? 1 : (result1.fraction > result2.fraction ? -1 : 0);
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
				newParent.SetBranch(node, parent);
			}
			else
			{
				newParent.SetBranch(node, parent);
				root = newParent;
			}
			
			
			
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
	
	public inline function IsEmpty():Bool
	{
		return root == null;
	}
	
	
}