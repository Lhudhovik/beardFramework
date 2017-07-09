package beardFramework.core.system;
import beardFramework.core.system.thread.ChainThread;
import beardFramework.core.system.thread.Thread;
import beardFramework.display.screens.BasicLoadingScreen;
import beardFramework.display.screens.BasicScreen;
import beardFramework.display.ui.UIManager;
import beardFramework.resources.assets.AssetManager;

/**
 * ...
 * @author Ludo
 */
class ScreenFlowManager
{
	private static var instance(get, null):ScreenFlowManager;
	
	public var LEVELS_PATH(default, never):String = "assets/levels/";
	//public var SCREENDATA(default, never):String = "screenData";
	public var currentLoadingScreen : BasicLoadingScreen;
	
	private var loadingScreens:Map<Class<BasicLoadingScreen>, BasicLoadingScreen>;
	private var existingScreens:Map<Class<BasicScreen>, BasicScreen>;
	private var loadThread:Thread<Xml>;
	private var clearThread:Thread<Int>;
	private var TransitionThread:ChainThread<Int>;
	private var nextScreen:BasicScreen;
	
	private function new() 
	{
		
	}
	public static function get_instance():ScreenFlowManager
	{
		if (instance == null)
		{
			instance = new ScreenFlowManager();
			instance.Init();
		}
		
		return instance;
	}
	
	private function Init():Void
	{
		loadThread = new Thread<Xml>(10);
		clearThread = new Thread<Int>(10);
		TransitionThread = new ChainThread<Int>(10);
		loadingScreens = new Map<Class<BasicLoadingScreen>, BasicLoadingScreen>();
		existingScreens = new Map<Class<BasicScreen>, BasicScreen>();
	}
	
	public function LoadScreen(screenClass:Class<BasicScreen>, loadingScreenClass:Class<BasicLoadingScreen>, dataPath:String = "", reUse:Bool = true):Void
	{
		BeardGame.Game().get_currentScreen().Freeze();
		DisplayLoadingScreen(loadingScreenClass);
		
		if (reUse){
			
			if (existingScreens[screenClass] == null) existingScreens[screenClass] == Type.createInstance(screenClass, [dataPath != ""]));
			
			nextScreen = existingScreens[screenClass];
			
		}
		else nextScreen = Type.createInstance(screenClass, [dataPath != ""]);
		
		nextScreen.dataPath = dataPath;
		
		if (dataPath != "" && !AssetManager.get_instance().HasContent(dataPath)){
			
			currentLoadingScreen.activeLoadingTasksCount++;
			
			AssetManager.get_instance().Append(AssetType.XML, dataPath, dataPath, null, null, OnSettingsFailed);
			AssetManager.get_instance().Load(OnScreenDataReady, currentLoadingScreen.OnProgress);
		
		}
		else
		{
			OnScreenDataReady();			
		}
		
	}
	
	private function OnScreenDataReady():Void
	{
	
		clearThread.AddToThread(BeardGame.Game().get_currentScreen().Clear, 0);
		loadThread.AddToThread(nextScreen.ParseScreenData, AssetManager.get_instance().GetContent(nextScreen.dataPath));
		TransitionThread.AddToThread(clearThread.ThreadedProceed, 0);
		TransitionThread.AddToThread(loadThread.ThreadedProceed, 0);
		
	}
	
	
	public function DisplayLoadingScreen(loadingScreenClass:Class<BasicLoadingScreen>):Void
	{
		
		if (loadingScreens[loadingScreenClass] == null){
			loadingScreens[loadingScreenClass] = Type.createInstance(loadingScreenClass, [false]);
		}
		currentLoadingScreen = loadingScreens[loadingScreenClass];
		BeardGame.Game().addChild(currentLoadingScreen);
		currentLoadingScreen.TransitionIn();
	}
	
	public function HideLoadingScreen():Void
	{
		
		if (currentLoadingScreen != null){
			
			
			
		}
		
		BeardGame.Game().addChild(currentLoadingScreen);
	}
	
}