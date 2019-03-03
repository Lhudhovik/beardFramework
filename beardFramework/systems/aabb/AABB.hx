package beardFramework.systems.aabb;
import beardFramework.utils.math.MathU;
import beardFramework.utils.Tags;
import beardFramework.utils.simpleDataStruct.SVec2;
import lime.math.Vector2;

/**
 * ...
 * @author 
 */
class AABB 
{
	static private var center:SVec2 = {x:0, y:0};
	
	public var topLeft:SVec2;
	public var bottomRight:SVec2;
	public var owner:String;
	public var layer:Int;
	public var node:Node;
	public var tags:UInt;
	public var needUpdate:Bool;
	
	public function new() 
	{
		topLeft = {x:0, y:0};
		bottomRight = {x:0, y:0};
		owner = "";
		layer = -1;
		node = null;
		tags = 0;
		needUpdate = false;
	}
	
	public function GetCenter():SVec2
	{
		center.x = (topLeft.x + bottomRight.x) / 2;
		center.y = (topLeft.y + bottomRight.y) / 2;
		return center;
	}
	
	public function Contains(aabb:AABB):Bool
	{
		return ((topLeft.x <= aabb.topLeft.x) && (topLeft.y <= aabb.topLeft.y) && (bottomRight.x >= aabb.bottomRight.x) && (bottomRight.y >= aabb.bottomRight.y));
	}
	
	public inline function Hit(x:Float, y:Float):Bool
	{
		return ((topLeft.x <= x) && (topLeft.y <= y) && (bottomRight.x >= x) && (bottomRight.y >= y));
	}
	
	public function Raycast(ray:Ray, result:RayCastResult):Bool
	{
		var tmin:Float = -MathU.MAX;
		var tmax:Float = MathU.MAX;
		
		var pX:Float = ray.start.x;
		var pY:Float = ray.start.y;
		var dX:Float = ray.dir.x * MathU.Abs(ray.length);
		var dY:Float = ray.dir.y * MathU.Abs(ray.length);
		var absDX:Float = MathU.Abs(dX);
		var absDY:Float = MathU.Abs(dY);
				
		var inv_d:Float;
		var t1:Float;
		var t2:Float;
		var t3:Float;
		var s:Float;
				
		if (pX > topLeft.x && pX < bottomRight.x && pY > topLeft.y && pY < bottomRight.y)
		{
			
			tmin = 0;
			result.normal.x = 0;
			result.normal.y = 0;
			
		}
		else{
			
			if (absDX < MathU.MIN)
			{
				if (pX < topLeft.x || bottomRight.x < pX)
					return false;
			}
			else
			{
				inv_d = 1.0 / dX;
				t1 = (topLeft.x - pX) * inv_d;
				t2 = (bottomRight.x - pX) * inv_d;
				s = -1.0;
				
				
		
				if (t1 > t2)
				{
					t3 = t1;
					t1 = t2;
					t2 = t3;
					s = 1.0;
				}
				
				
				if (t1 > tmin)
				{
					result.normal.x = s;
					result.normal.y = 0;
					tmin = t1;
				}
							
				tmax = MathU.Min(tmax, t2);
								
				if (tmin > tmax)
					return false;
			}
	
			if (absDY < MathU.MIN)
			{
					if (pY < topLeft.y || bottomRight.y < pY)
					return false;
			}
			else
			{
				inv_d = 1.0 / dY;
				t1 = (topLeft.y - pY) * inv_d;
				t2 = (bottomRight.y - pY) * inv_d;
				s = -1.0;
				
				if (t1 > t2)
				{
					t3 = t1;
					t1 = t2;
					t2 = t3;
					s = 1.0;
				}
				
				if (t1 > tmin)
				{
					result.normal.y = s;
					result.normal.x = 0;
					tmin = t1;
				}
					
				tmax = MathU.Min(tmax, t2);
				
				if (tmin > tmax)
					return false;
			}
			
			if (ray.length > 0)
			{
				
				if (MathU.Abs(tmin) > 1) return false;
				else if (tmin < 0 && ( pX < topLeft.x || pX> bottomRight.x || pY < topLeft.y || pY > bottomRight.y ) )
					return false;
				
			}
			else if(tmin < 0) tmin = tmax;
		}
		
		
		
		
		
		result.hitPos.x = pX + tmin * dX;
		result.hitPos.y = pY + tmin * dY;
		result.fraction = tmin;
		result.hit = true;
		result.collider = this;
		
		return true;
		
	}
	public inline function Overlaps(aabb:AABB):Bool
	{
		return !(topLeft.x > aabb.bottomRight.x || aabb.topLeft.x > bottomRight.x || topLeft.y > aabb.bottomRight.y || aabb.topLeft.y > bottomRight.y);
	}
	public function Combine(aabb1:AABB, aabb2:AABB):Void
	{
		
		topLeft.x = (aabb1.topLeft.x < aabb2.topLeft.x ?  aabb1.topLeft.x : aabb2.topLeft.x);
		topLeft.y = (aabb1.topLeft.y < aabb2.topLeft.y ?  aabb1.topLeft.y : aabb2.topLeft.y);
		bottomRight.x = (aabb1.bottomRight.x > aabb2.bottomRight.x ?  aabb1.bottomRight.x : aabb2.bottomRight.x);
		bottomRight.y = (aabb1.bottomRight.y > aabb2.bottomRight.y ?  aabb1.bottomRight.y : aabb2.bottomRight.y);
		
	}
	public inline function Surface():Float
	{
		return (bottomRight.x - topLeft.x) * (bottomRight.y - topLeft.y);
	}
	
	public inline function ToString():String
	{
		
		return "x : " + topLeft.x + " y : " + topLeft.y + " width : " + (bottomRight.x - topLeft.x) + " height : " + (bottomRight.y - topLeft.y);
		
	}
}