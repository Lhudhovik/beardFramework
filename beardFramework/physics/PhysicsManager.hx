package beardFramework.physics;
import beardFramework.resources.pool.ArrayPool;
import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.Material;
import nape.shape.Circle;
import nape.shape.Polygon;
import nape.shape.Shape;
import nape.space.Space;

/**
 * ...
 * @author Ludo
 */
class PhysicsManager
{
	private static var instance(default, null):PhysicsManager;
	
	private var space(get,null):Space;
	private var GRAVITY(get, null):Vec2;
	private var bodyPool:ArrayPool<Body>;
	private var polygonPool:ArrayPool<Polygon>;
	private var circlePool:ArrayPool<Circle>;
	private var sharedShapes:Map<String, Shape>;
	private var materialPool:ArrayPool<Material>;
	
	public function new() 
	{
		
	}
	
	public static inline function Get():PhysicsManager
	{
		if (instance == null)
		{
			instance = new PhysicsManager();
		}
		
		return instance;
	}

	public function InitSpace(spaceOptions:Xml, bodyPoolSize:Int = 0, polygonPoolSize:Int=0,circlePoolSize:Int = 0,  materialPoolSize:Int=0):Void
	{
		GRAVITY = Vec2.get(Std.parseFloat(spaceOptions.get("gravityX")),Std.parseFloat(spaceOptions.get("gravityY")));
		space = new Space(GRAVITY);
		if (bodyPoolSize > 0){
			bodyPool = new ArrayPool<Body>(bodyPoolSize);
		}
		if (polygonPoolSize > 0){
			polygonPool = new ArrayPool<Polygon>(polygonPoolSize);
		}
		if (circlePoolSize > 0){
			circlePool = new ArrayPool<Circle>(circlePoolSize);
		}
		if (materialPoolSize > 0){
			materialPool = new ArrayPool<Material>(materialPoolSize);
		}
		sharedShapes = new Map<String, Shape>();
	}
	
	public inline function Step(deltaTime:Float):Void
	{
		space.step(deltaTime);
	}
	
	public inline function get_space():Space return space;
	public inline function get_GRAVITY():Vec2
	{
		return Vec2.get(GRAVITY.x, GRAVITY.y, true);
	}
	public function GetBody():Body
	{
		if (bodyPool == null)
		{
			bodyPool = new ArrayPool<Body>(5);
			bodyPool.Populate([for (i in 0...5) new Body()]);
		}
		return bodyPool.Get();
	}
	public inline function AddSharedShape(name:String, sharedShape:Shape):Void
	{
		sharedShapes[name] = sharedShape;
	}	
	
	public inline function GetSharedShape(name:String):Shape
	{
		return sharedShapes[name];
	}	
	
	public function GetCircle():Circle
	{
		if (circlePool == null)
		{
			circlePool = new ArrayPool<Circle>(5);
			circlePool.Populate([for (i in 0...5) new Circle(50)]);
		}
		return circlePool.Get();
	}	
	
	public function GetPolygon():Polygon
	{
		if (polygonPool == null)
		{
			polygonPool = new ArrayPool<Polygon>(5);
			polygonPool.Populate([for (i in 0...5) new Polygon(Polygon.rect(0,0,100,100))]);
		}
		return polygonPool.Get();
	}
	
	public inline function ReleaseBody(body:Body):Body
	{
		return bodyPool.Release(body);
	}
	
	public inline function ReleaseMaterial(material:Material):Material
	{
		return materialPool.Release(material);
	}
	
	public inline function ReleaseCircle(circle:Circle):Circle
	{
		return circlePool.Release(circle);
	}
	
	public inline function ReleasePolygon(polygon:Polygon):Polygon
	{
		return polygonPool.Release(polygon);
	}
	
	
	public function GetMaterial():Material
	{
		if (materialPool == null)
		{
			materialPool = new ArrayPool<Material>(5);
			materialPool.Populate([for (i in 0...5) new Material()]);
		}
		return materialPool.Get();
	}
}