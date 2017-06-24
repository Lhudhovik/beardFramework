package beardFramework.interfaces;

/**
 * @author Ludo
 */
interface IUIComponent 
{
	
	public var x(get,set):Float;
	public var y(get,set):Float;
	public var width(get,set):Float;
	public var height(get,set):Float;
	public var scaleX(get,set):Float;
	public var scaleY(get,set):Float;
	
	public var vAlign:UInt;
	public var hAlign:UInt;
	public var fillPart:Float;
	public var keepRatio:Bool;
}