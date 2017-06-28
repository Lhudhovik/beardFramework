package beardFramework.displaySystem.ui.components;

import beardFramework.displaySystem.BeardSprite;
import beardFramework.interfaces.IUIComponent;


/**
 * ...
 * @author Ludo
 */
class UISpriteComponent extends BeardSprite implements IUIComponent
{


	
	public var fillPart:Float;
	
	public var keepRatio:Bool;
	
	public var vAlign:UInt;
	
	public var hAlign:UInt;
	
	public function new() 
	{
		super();
				
	}
	
	
	/* INTERFACE beardFramework.interfaces.IUIComponent */
	
	public function UpdateVisual():Void 
	{
		
	}
	
	
	
	
}