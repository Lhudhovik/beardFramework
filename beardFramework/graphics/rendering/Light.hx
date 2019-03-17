package beardFramework.graphics.rendering;
import beardFramework.utils.graphics.Color;
import beardFramework.utils.simpleDataStruct.SVec3;

/**
 * @author Ludovic
 */
typedef AbstractLight =
{
	public var ambient:Color;
	public var diffuse:Color;
	public var specular:Color;
}

typedef DirectionalLight =
{
	>AbstractLight,
	public var direction:SVec3;
}

typedef PointLight =
{
	>AbstractLight,
	public var position:SVec3;
	public var constant : Float;
	public var linear : Float;
	public var quadratic : Float;
}

typedef SpotLight =
{
	>AbstractLight,
	public var position:SVec3;
	public var direction:SVec3;
	public var cutOff:Float;
	public var outerCutOff:Float;
}