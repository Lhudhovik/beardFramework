package beardFramework.interfaces;

/**
 * @author 
 */
interface ISpatialized extends IBeardyObject
{
	public var width(get, set):Float;
	public var height(get, set):Float;
	public var scaleX(get, set):Float;
	public var scaleY(get, set):Float;
	public var rotation (get, set):Float;
	public var x(get, set):Float;
	public var y(get, set):Float;
	public var z(get, set):Float;
	
}