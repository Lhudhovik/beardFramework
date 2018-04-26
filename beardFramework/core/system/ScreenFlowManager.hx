package beardFramework.core.system;
import beardFramework.core.system.ScreenFlowManager.NextScreenData;
import beardFramework.core.system.thread.ChainThread;
import beardFramework.core.system.thread.ParamThreadDetail;
import beardFramework.core.system.thread.RowThreadDetail;
import beardFramework.core.system.thread.Thread;
import beardFramework.core.system.thread.ThreadDetail;
import beardFramework.display.screens.BasicLoadingScreen;
import beardFramework.display.screens.BasicScreen;
import beardFramework.display.ui.UIManager;
import beardFramework.resources.assets.AssetManager;
import beardFramework.resources.save.data.DataCamera;
import beardFramework.resources.save.data.DataEntity;
import beardFramework.resources.save.data.DataScreen;
import beardFramework.resources.save.data.DataUIGroup;
import beardFramework.utils.Crypto;
import beardFramework.utils.DataUtils;
import beardFramework.utils.StringLibrary;
import haxe.Json;
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
	private var screenClearTD:ThreadDetail;
	private var UIClearTD:ThreadDetail;
	private var screenLoadTD: ParamThreadDetail<AbstractDataScreen>;
	private var UILoadTD: RowThreadDetail<AbstractDataUIGroup>;
	private var transitionThread(get, null):ChainThread;
	private var nextScreenData:NextScreenData;
	
	private function new() 
	{
		
	}
	public static inline function Get():ScreenFlowManager
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
		//#if classicThread
		//loadThread = new OldThread<DataScreen>(10);
		//#else
		//loadThread = new Thread("yes", 10);
		//#end
		
		screenClearTD = new ThreadDetail(null);
		UIClearTD = new ThreadDetail(null);
		screenLoadTD = new ParamThreadDetail<AbstractDataScreen>(null, null);
		UILoadTD = new RowThreadDetail<AbstractDataUIGroup>(null, null);
		transitionThread = new ChainThread("transition",10);
		loadingScreens = new Map<String, BasicLoadingScreen>();
		existingScreens = new Map<String, BasicScreen>();
		nextScreenData = { screen:null, reUse:false, screenClass:null, dataPath:""};
		transitioning = false;
	}
	
	public function LoadScreen(screenClass:Class<BasicScreen>, loadingScreenClass:Class<BasicLoadingScreen>, dataPath:String = "", reUse:Bool = true):Void
	{
		trace("~~ " + screenClass + " Loading started");
		if (BeardGame.Get().currentScreen != null){
			
			BeardGame.Get().currentScreen.Freeze();
			screenClearTD.action = BeardGame.Get().currentScreen.Clear;
	
			UIClearTD.action =  UIManager.Get().ClearUI;
			
			transitionThread.Add(screenClearTD);
			transitionThread.Add(UIClearTD);
		}
		
		nextScreenData.reUse = reUse;
		nextScreenData.dataPath = dataPath;
		nextScreenData.screenClass = screenClass;
		transitioning = true;
		DisplayLoadingScreen(loadingScreenClass,true,PrepareScreenData);
	}
	
	private function PrepareScreenData():Void
	{
		trace("~~ Screen Transition ready");
		
		StringLibrary.utilString = Type.getClassName(nextScreenData.screenClass);
		
		if (nextScreenData.reUse){
						
			if (existingScreens[StringLibrary.utilString] == null) existingScreens[StringLibrary.utilString] = Type.createInstance(nextScreenData.screenClass,[]);
			
			nextScreenData.screen = existingScreens[StringLibrary.utilString];
			
		}
		else nextScreenData.screen = Type.createInstance(nextScreenData.screenClass, []);
		
		if (nextScreenData.screen == null){
			trace(StringLibrary.utilString);
			trace("~~ /!\\ Hum... unexpected : Screen Class ->   " + nextScreenData.screenClass);
			return;
		}
		
		nextScreenData.screen.dataPath = nextScreenData.dataPath;
		
		if (nextScreenData.dataPath != "" && !AssetManager.Get().HasContent(nextScreenData.dataPath)){
			
			currentLoadingScreen.loadingTasksCount++;
			
			AssetManager.Get().Append(AssetType.DATA, nextScreenData.dataPath, nextScreenData.dataPath);
			AssetManager.Get().Load(StartTransition, currentLoadingScreen.OnLoadingProgress, BeardGame.Get().OnSettingsFailed );
		
		}
		else
		{
			StartTransition();			
		}
	}
	
	private function StartTransition():Void
	{
	
		var data:AbstractDataScreen = null;
		
		#if (debug)
			data = haxe.Json.parse(AssetManager.Get().GetContent(nextScreenData.screen.dataPath));
		#else
			data = Crypto.DecodedData(AssetManager.Get().GetContent(nextScreenData.screen.dataPath));
		#end
		
		screenLoadTD.action = nextScreenData.screen.ParseScreenData;
		screenLoadTD.parameter = data;
		
		nextScreenData.screen.onReady.addOnce(EndTransition);
		
		transitionThread.Add(screenLoadTD);
		
		
		if (data.UITemplates != null){
			for (template in data.UITemplates)
				UILoadTD.parameters.add(UIManager.Get().GetTemplateData(template));
			
			UILoadTD.parameter = UILoadTD.parameters.first();
			UILoadTD.action = UIManager.Get().LoadTemplate;
			
			transitionThread.Add(UILoadTD);
		
		}
				
		transitionThread.Start();
		
		
	}
	
	private inline function EndTransition():Void
	{
		trace("~~ "+ nextScreenData.screenClass + " ready");
		BeardGame.Get().currentScreen = nextScreenData.screen;
		HideLoadingScreen(true, nextScreenData.screen.StartTransitionIn);
		UIManager.Get().ShowUI();
		
		transitioning = false;
	}
	
	public function DisplayLoadingScreen(loadingScreenClass:Class<BasicLoadingScreen>, transition:Bool = true, onComplete:Void->Void = null):Void
	{
		trace("~~ Loading Screen Displayed");
		StringLibrary.utilString = Type.getClassName(loadingScreenClass);
		if (loadingScreens[StringLibrary.utilString] == null){
			loadingScreens[StringLibrary.utilString] = Type.createInstance(loadingScreenClass, []);
			loadingScreens[StringLibrary.utilString].ParseScreenData(null);
		}
		currentLoadingScreen = loadingScreens[StringLibrary.utilString];
		
		currentLoadingScreen.loadingTasksCount = 3;//clear previous screen + load the next screen + minim loading timer
		
		
		if (transition){
			if (onComplete != null) currentLoadingScreen.onTransitionFinished.addOnce(onComplete);
			currentLoadingScreen.StartTransitionIn();
		}
		else{
			currentLoadingScreen.Show();
			if(onComplete != null) onComplete();
		}
	}
	
	public function HideLoadingScreen(transition:Bool = true, onComplete:Void->Void):Void
	{
		trace("~~ Loading Screen hidden");
		
		if (currentLoadingScreen != null){
			
			if (transition){
				if (onComplete != null) currentLoadingScreen.onTransitionFinished.addOnce(onComplete);
				currentLoadingScreen.StartTransitionOut();
			}
			else{
				currentLoadingScreen.Hide();
				if(onComplete != null) onComplete();
			}
			
		}
		
		
		
	}
	
	public function get_transitionThread():ChainThread
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
