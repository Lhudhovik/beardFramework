package beardFramework.graphics.rendering;
import beardFramework.utils.simpleDataStruct.SVec3;

/**
 * @author Ludovic
 */
typedef Light =
{
	public var position:SVec3;
	public var ambient:UInt;
	public var diffuse:UInt;
	public var specular:UInt;
}

typedef PointLight =
{
	>Light,
	public var constant : Float;
	public var linear : Float;
	public var quadratic : Float;
}

typedef SpotLight =
{
	>Light,
	public var constant : Float;
	public var linear : Float;
	public var quadratic : Float;
}