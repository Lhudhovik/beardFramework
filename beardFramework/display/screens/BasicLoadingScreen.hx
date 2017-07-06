package beardFramework.display.screens;
import beardFramework.display.ui.components.UIBitmapComponent;
import beardFramework.display.ui.components.UIContainer;
import beardFramework.resources.assets.AssetManager;

/**
 * ...
 * @author Ludo
 */
class BasicLoadingScreen extends BasicScreen 
{
	private var components:UIContainer;
	public function new(dataNeeded:Bool=true) 
	{
		super(dataNeeded);
		
	}
	
	
	override function Init():Void 
	{
		super.Init();
		
		//var loadingSign:UIBitmapComponent = new UIBitmapComponent();
		//var loadingText:UITextFieldComponent = new UITextFieldComponent();
		
	}
}