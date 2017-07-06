package beardFramework.display.ui.components;

import beardFramework.display.core.BeardTextField;
import beardFramework.interfaces.IUIComponent;

/**
 * ...
 * @author Ludo
 */
class UITextFieldComponent extends BeardTextField implements IUIComponent
{

	public function new() 
	{
		super();
		
	}
	
	
	/* INTERFACE beardFramework.interfaces.IUIComponent */
	
	public var vAlign:UInt;
	
	public var hAlign:UInt;
	
	public var fillPart:Float;
	
	public var keepRatio:Bool;
	
	public function UpdateVisual():Void 
	{
		__updateLayout();
	}
	
	
	/* INTERFACE beardFramework.interfaces.IUIComponent */
	
	public function Clear():Void 
	{
		
	}
	
}