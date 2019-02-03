package beardFramework.graphics.screens.regions;
import beardFramework.utils.MinAllocArray;

/**
 * @author 
 */
typedef GridObject =
{
	public var layer:Int;
	public var cells:MinAllocArray<Int>;
	public var level:Int;
}