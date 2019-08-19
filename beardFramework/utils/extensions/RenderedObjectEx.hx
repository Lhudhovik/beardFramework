package beardFramework.utils.extensions;
import beardFramework.graphics.objects.RenderedObject;

/**
 * ...
 * @author 
 */
class RenderedObjectEx 
{

	static public function intWidth(object:RenderedObject ):Int
    return Std.int(object.width);
  
	
	static public function intHeight(object:RenderedObject ):Int
    return Std.int(object.height);
}