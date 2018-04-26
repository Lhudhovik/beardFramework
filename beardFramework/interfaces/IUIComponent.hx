package beardFramework.interfaces;
import beardFramework.interfaces.IUIGroupable;
import beardFramework.resources.save.data.DataUIComponent;


/**
 * @author Ludo
 */
interface IUIComponent extends IUIGroupable
{
	
	public var x(get,set):Float;
	public var y(get,set):Float;
	public var width(get,set):Float;
	public var height(get,set):Float;
	public var scaleX(get,set):Float;
	public var scaleY(get, set):Float;
	public var preserved(get, set):Bool;
	public var container(get, set):String;
	
	public var vAlign:UInt;
	public var hAlign:UInt;
	public var fillPart:Float;
	public var keepRatio:Bool;

	
	public function UpdateVisual():Void;
	public function Clear():Void;
	public function ToData():DataUIComponent;
	public function ParseData(data:DataUIComponent):Void;
}