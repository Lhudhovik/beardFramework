package beardFramework.interfaces;
import beardFramework.graphics.ui.FocusableList;
import beardFramework.input.data.InputData;

/**
 * @author 
 */
interface IFocusable 
{
	public var name(get, set):String;
	public var list:FocusableList;
	public function FocusOn(inputdata:InputData=null):Void;
	public function FocusOff():Void;
	public function Validate():Void;
	
	
}