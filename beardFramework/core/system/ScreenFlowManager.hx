package beardFramework.core.system;
import beardFramework.core.system.ScreenFlowManager.NextScreenData;
import beardFramework.core.system.thread.ChainThread;
import beardFramework.core.system.thread.Thread;
import beardFramework.display.screens.BasicLoadingScreen;
import beardFramework.display.screens.BasicScreen;
import beardFramework.display.ui.UIManager;
import beardFramework.resources.assets.AssetManager;
import beardFramework.utils.StringLibrary;
import mloader.Loader.LoaderEvent;

/**
 * ...
 * @author Ludo
 */
class ScreenFlowManager
{
	private static var instance(default, null):ScreenFlowManager;
		//public var SCREENDATA(default, never):String = "screenData";
	public var currentLoadingScreen : BasicLoadingScreen;
	public var transitioning:Bool;
	
	private var loadingScreens:Map<String, BasicLoadingScreen>;
	private var existingScreens:Map<String, BasicScreen>;
	private var loadThread:Thread<Xml>;
	private var clearThread:Thread<Int>;
	private var transitionThread(get, null):ChainThread<Int>;
	private var nextScreenData:NextScreenData;
	
	private function new() 
	{
		
	}
	public static function Get():ScreenFlowManager
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
		transitionThread = new ChainThread<Int>(10);
		loadingScreens = new Map<String, BasicLoadingScreen>();
		existingScreens = new Map<String, BasicScreen>();
		nextScreenData = { screen:null, reUse:false, screenClass:null, dataPath:""};
		transitioning = false;
	}
	
	public function LoadScreen(screenClass:Class<BasicScreen>, loadingScreenClass:Class<BasicLoadingScreen>, dataPath:String = "", reUse:Bool = true):Void
	{
		trace("start loading");
		if (BeardGame.Get().currentScreen!= null){
			BeardGame.Get().currentScreen.Freeze();
			clearThread.AddToThread(BeardGame.Get().currentScreen.Clear, 0);
		}
		nextScreenData.reUse = reUse;
		nextScreenData.dataPath = dataPath;
		nextScreenData.screenClass = screenClass;
		transitioning = true;
		DisplayLoadingScreen(loadingScreenClass,true,OnTransitionReady);
	}
	
	public function DisplayLoadingScreen(loadingScreenClass:Class<BasicLoadingScreen>, transition:Bool = true, onComplete:Void->Void = null):Void
	{
		trace("display loading");
		StringLibrary.utilString = Type.getClassName(loadingScreenClass);
		if (loadingScreens[StringLibrary.utilString] == null){
			loadingScreens[StringLibrary.utilString] = Type.createInstance(loadingScreenClass, []);
			loadingScreens[StringLibrary.utilString].ParseScreenData(null);
		}
		currentLoadingScreen = loadingScreens[StringLibrary.utilString];
		
		if (transition){
			if (onComplete != null) currentLoadingScreen.onTransitionFinished.addOnce(onComplete);
			currentLoadingScreen.TransitionIn();
		}
		else{
			currentLoadingScreen.Show();
			if(onComplete != null) onComplete();
		}
	}
	
	private function OnTransitionReady():Void
	{
		trace("transition ready");
		currentLoadingScreen.loadingTasksCount = 2;//clear previous screen + load the next screen
		StringLibrary.utilString = Type.getClassName(nextScreenData.screenClass);
		
		if (nextScreenData.reUse){
						
			if (existingScreens[StringLibrary.utilString] == null) existingScreens[StringLibrary.utilString] = Type.createInstance(nextScreenData.screenClass,[]);
			
			nextScreenData.screen = existingScreens[StringLibrary.utilString];
			
		}
		else nextScreenData.screen = Type.createInstance(nextScreenData.screenClass, []);
		
		if (nextScreenData.screen == null){
			trace(StringLibrary.utilString);
			trace("hum... unexpected : Screen Class ->   " + nextScreenData.screenClass);
			return;
		}
		
		nextScreenData.screen.dataPath = nextScreenData.dataPath;
		
		if (nextScreenData.dataPath != "" && !AssetManager.Get().HasContent(nextScreenData.dataPath)){
			
			currentLoadingScreen.loadingTasksCount++;
			
			AssetManager.Get().Append(AssetType.XML, nextScreenData.dataPath, nextScreenData.dataPath);
			AssetManager.Get().Load(OnScreenDataReady, currentLoadingScreen.OnLoadingProgress, BeardGame.Get().OnSettingsFailed );
		
		}
		else
		{
			OnScreenDataReady();			
		}
	}
	
	private function OnScreenDataReady():Void
	{
	trace("screen data rea loading");
		loadThread.AddToThread(nextScreenData.screen.ParseScreenData, AssetManager.Get().GetContent(nextScreenData.screen.dataPath));
		if(!clearThread.empty) transitionThread.AddToThread(clearThread.ThreadedProceed, 0);
		transitionThread.AddToThread(loadThread.ThreadedProceed, 0);
		//TransitionThread.completed.addOnce(OnTransitionThreadFinished);
		nextScreenData.screen.onReady.addOnce(OnScreenReady);
		
	}
	
	
	
	private inline function OnScreenReady():Void
	{
		trace("screen ready");
		BeardGame.Get().currentScreen = nextScreenData.screen;
		HideLoadingScreen(true, nextScreenData.screen.TransitionIn);
		transitioning = false;
	}
	
	
	
	
	public function HideLoadingScreen(transition:Bool = true, onComplete:Void->Void):Void
	{
		trace("Hide loading");
		
		if (currentLoadingScreen != null){
			
			if (transition){
				if (onComplete != null) currentLoadingScreen.onTransitionFinished.addOnce(onComplete);
				currentLoadingScreen.TransitionOut();
			}
			else{
				currentLoadingScreen.Hide();
				if(onComplete != null) onComplete();
			}
			
		}
		
		
		
	}
	
	public function get_transitionThread():ChainThread<Int> 
	{
		return transitionThread;
	}
	
}

typedef NextScreenData =
{
	var screen:BasicScreen;
	var reUse:Bool;
	var screenClass:Class<BasicScreen>;
	var dataPath:String;
}
