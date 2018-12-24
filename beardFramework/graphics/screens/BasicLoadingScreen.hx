package beardFramework.graphics.screens;
import beardFramework.core.BeardGame;
import beardFramework.updateProcess.thread.ParamThreadDetail;
import beardFramework.graphics.ui.components.UIContainer;
import beardFramework.resources.assets.AssetManager;

using beardFramework.utils.SysPreciseTime;
/**
 * ...
 * @author Ludo
 */
class BasicLoadingScreen extends BasicScreen 
{
	private static var instance(get, null):BasicLoadingScreen;
	public static var MINLOADINGTIME:Float = 10;
	private var components:UIContainer;
	public var loadingTasksCount : Int;
	public var completedLoadingTasksCount : Int;
	

	public function new( ) 
	{
		super();
		instance = this;
		loadingTasksCount = 0;
		
	}
	
	
	override function Init():Void 
	{
		super.Init();
		
		displayLayer = BeardGame.Get().GetLoadingLayer();
		//var loadingSign:UIBitmapComponent = new UIBitmapComponent();
		//var loadingText:UITextFieldComponent = new UITextFieldComponent();
		
	}
	

	public inline function CheckLoadtingTime(threadDetail:ParamThreadDetail<Float>):Bool
	{
		return (Sys.preciseTime() - threadDetail.parameter > MINLOADINGTIME);
	}
	
	public static function get_instance():BasicLoadingScreen 
	{
		return instance;
	}
	
	
	public function OnLoadingProgress(progression:Float):Void
	{
		
		trace("~~ Loading Screen progress... " + ((progression + completedLoadingTasksCount) / loadingTasksCount) + " %");
		
	}
	
	
	
}