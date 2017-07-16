package beardFramework.display.screens;
import beardFramework.core.BeardGame;
import beardFramework.display.ui.components.UIBitmapComponent;
import beardFramework.display.ui.components.UIContainer;
import beardFramework.resources.assets.AssetManager;

/**
 * ...
 * @author Ludo
 */
class BasicLoadingScreen extends BasicScreen 
{
	private static var instance(get, null):BasicLoadingScreen;
	private var components:UIContainer;
	public var loadingTasksCount : Int;
	public var completedLoadingTasksCount : Int;

	public function new(dataNeeded:Bool=true) 
	{
		super(dataNeeded);
		instance = this;
		loadingTasksCount = 0;
	}
	
	
	override function Init():Void 
	{
		super.Init();
		
		contentLayer = BeardGame.Game().GetLoadingLayer();
		//var loadingSign:UIBitmapComponent = new UIBitmapComponent();
		//var loadingText:UITextFieldComponent = new UITextFieldComponent();
		
	}
	
	public static function get_instance():BasicLoadingScreen 
	{
		return instance;
	}
	
	
	public function OnLoadingProgress(progression:Float):Void
	{
		
		trace((progression + completedLoadingTasksCount) / loadingTasksCount);
		
	}
	
	
	
}