package beardFramework.graphics.shaders;
import beardFramework.utils.graphics.Color;
import beardFramework.utils.simpleDataStruct.SRect;

/**
 * @author Ludovic
 */


typedef MaterialComponent =
{
	var color:Color;
	var texture:String;
	var atlas:String;
	var uv:SRect;
}