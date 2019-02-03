package beardFramework.systems.aabb;
import beardFramework.utils.GeomUtils;
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
	
	public function new() 
	{
		topLeft = {x:0, y:0};
		bottomRight = {x:0, y:0};
		owner = "";
		layer = -1;
		node = null;
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
	
		Math.
		var tmin:Float = -B2Math.MAX_VALUE;
		var tmax:Float = B2Math.MAX_VALUE;
		
		var pX:Float = input.p1.x;
		var pY:Float = input.p1.y;
		var dX:Float = input.p2.x - input.p1.x;
		var dY:Float = input.p2.y - input.p1.y;
		var absDX:Float = Math.abs(dX);
		var absDY:Float = Math.abs(dY);
		
		var normal:B2Vec2 = output.normal;
		
		var inv_d:Float;
		var t1:Float;
		var t2:Float;
		var t3:Float;
		var s:Float;
		
		//x
		{
			if (absDX < B2Math.MIN_VALUE)
			{
				// Parallel.
				if (pX < lowerBound.x || upperBound.x < pX)
					return false;
			}
			else
			{
				inv_d = 1.0 / dX;
				t1 = (lowerBound.x - pX) * inv_d;
				t2 = (upperBound.x - pX) * inv_d;
				
				// Sign of the normal vector
				s = -1.0;
				
				if (t1 > t2)
				{
					t3 = t1;
					t1 = t2;
					t2 = t3;
					s = 1.0;
				}
				
				// Push the min up
				if (t1 > tmin)
				{
					normal.x = s;
					normal.y = 0;
					tmin = t1;
				}
				
				// Pull the max down
				tmax = Math.min(tmax, t2);
				
				if (tmin > tmax)
					return false;
			}
		}
		//y
		{
			if (absDY < B2Math.MIN_VALUE)
			{
				// Parallel.
				if (pY < lowerBound.y || upperBound.y < pY)
					return false;
			}
			else
			{
				inv_d = 1.0 / dY;
				t1 = (lowerBound.y - pY) * inv_d;
				t2 = (upperBound.y - pY) * inv_d;
				
				// Sign of the normal vector
				s = -1.0;
				
				if (t1 > t2)
				{
					t3 = t1;
					t1 = t2;
					t2 = t3;
					s = 1.0;
				}
				
				// Push the min up
				if (t1 > tmin)
				{
					normal.y = s;
					normal.x = 0;
					tmin = t1;
				}
				
				// Pull the max down
				tmax = Math.min(tmax, t2);
				
				if (tmin > tmax)
					return false;
			}
		}
		
		output.fraction = tmin;
		return true;
		
		
		var t1 = (topLeft.x - ray.start.x) / ray.dir.x;
		var t2 = (bottomRight.x - ray.start.x) / ray.dir.x;
		var t3 = (topLeft.y - ray.start.y) / ray.dir.y;
		var t4 = (bottomRight.y - ray.start.y) / ray.dir.y;
		
		var aMin = t1 < t2 ? t1 : t2;
		var bMin = t3 < t4 ? t3 : t4;
		
		var aMax = t1 > t2 ? t1 : t2;
		var bMax = t3 > t4 ? t3 : t4;
		
		var  fMin = aMin > bMin ? aMin : bMin;
		var  fMax = aMax < bMax ? aMax : bMax;
		
		var fraction = (fMax <0 || fMin > fMax) ? -1 : fMin;
		
		
		result.hitPos.x = ray.start.x + fraction * ray.dir.x * ray.length;
		result.hitPos.y = ray.start.y + fraction * ray.dir.y * ray.length;
		result.normal = 	
		
		return (fraction != -1);
		//
		//
		//
		//
		//var dir : Vector2 = ray.dir.clone();
		//dir.normalize(1);
		//var endpoint:Vector2 = new Vector2(ray.start.x + dir.x * ray.length, ray.start.y + dir.y * ray.length);
		//
		//if (Hit(ray.start.x, ray.start.y))
		//{
			//result.hitPos.x = ray.start.x;
			//result.hitPos.y = ray.start.y;
			//return true;
		//}
		//
		//
		//var t1:Float = (topLeft.x - ray.start.x) * ray.dir_inv.x;
		//var t2:Float = (bottomRight.x - ray.start.x) * ray.dir_inv.x;
		//
		//var tmin : Float = (t1 < t2 ? t1:t2);
		//var tmax : Float = (t1 > t2 ? t1:t2);
		//
		//var ty1:Float = (topLeft.y - ray.start.y) * ray.dir_inv.y;
		//var ty2:Float = (bottomRight.y - ray.start.y) * ray.dir_inv.y;
		//
		//tmin = GeomUtils.Max(tmin, GeomUtils.Min(ty1, ty2));
		//tmax = GeomUtils.Min(tmax, GeomUtils.Max(ty1, ty2));
		//
		//result.hitPos = 
		//
		
		
		
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
}