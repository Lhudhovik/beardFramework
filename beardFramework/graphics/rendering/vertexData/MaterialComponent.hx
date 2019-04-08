package beardFramework.graphics.rendering.vertexData;
import beardFramework.utils.graphics.Color;
import beardFramework.utils.simpleDataStruct.SRect;

/**
 * @author Ludovic
 */
typedef MaterialComponent =
{
	var color:Color;
	var texture:String;
	var atlas:Int;
	var uvs:SRect;
}