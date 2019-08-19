package beardFramework.interfaces;
import beardFramework.interfaces.IUIGroupable;
import beardFramework.resources.save.data.StructDataUIComponent;


/**
 * @author Ludo
 */
interface IUIComponent extends IUIGroupable extends ISpatialized
{
	
	
	public var preserved(get, set):Bool;
	public var container(get, set):String;
	
	public var vAlign:UInt;
	public var hAlign:UInt;
	public var fillPart:Float;
	public var keepRatio:Bool;

	
	public function UpdateVisual():Void;
	public function ToData():StructDataUIComponent;
	public function ParseData(data:StructDataUIComponent):Void;
}