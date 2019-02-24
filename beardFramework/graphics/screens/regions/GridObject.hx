package beardFramework.graphics.screens.regions;
import beardFramework.resources.MinAllocArray;

/**
 * @author 
 */
typedef GridObject =
{
	public var layer:Int;
	public var cells:MinAllocArray<Int>;
	public var level:Int;
}