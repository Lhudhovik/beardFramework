package beardFramework.interfaces;
import beardFramework.graphics.ui.FocusableList;
import beardFramework.input.data.InputData;

/**
 * @author 
 */
interface IFocusable extends INamed
{
	
	public var list:FocusableList;
	public function FocusOn(inputdata:InputData=null):Void;
	public function FocusOff():Void;
	public function Validate():Void;
	
	
}