package beardFramework.core;

import beardFramework.graphics.rendering.Renderer;
import beardFramework.graphics.rendering.TextRenderer;
import beardFramework.graphics.rendering.Shaders;
import beardFramework.graphics.rendering.VisualRenderer;
import beardFramework.resources.options.OptionsManager;
import beardFramework.updateProcess.UpdateProcessesManager;
import beardFramework.updateProcess.Wait;
import beardFramework.updateProcess.sequence.VoidStep;
import beardFramework.debug.MemoryUsage;
import beardFramework.graphics.cameras.Camera;
import beardFramework.graphics.core.BeardLayer;
import beardFramework.graphics.screens.BasicScreen;
import beardFramework.graphics.screens.SplashScreen;
import beardFramework.graphics.ui.UIManager;
import beardFramework.gameSystem.entities.GameEntity;
import beardFramework.input.InputManager;
import beardFramework.physics.PhysicsManager;
import beardFramework.resources.assets.AssetManager;
import lime.graphics.opengl.GL;
//import crashdumper.CrashDumper;
//import crashdumper.SessionData;
import lime.app.Application;
import lime.graphics.RenderContext;
import lime.utils.Assets;
import mloader.Loader.LoaderErrorType;
import mloader.Loader.LoaderEvent;
import sys.FileSystem;

@:access(openfl.display.Graphics)
@:access(openfl.display.Stage)
@:access(openfl.geom.Point)
@:access(beardFramework.debug.MemoryUsage)
@:access(openfl.text.TextField)
/**
 * ...
 * @author Ludo
 */
class BeardGame extends Application
{
	private static var game(default, null):BeardGame;
	
	public var SETTING_PATH(default, never):String = "assets/gp.xml";
	public var SAVE_PATH(default, never):String = "save/";
	public var UI_PATH(default, never):String = "assets/UI/";
	public var FONT_PATH(default, never):String = "assets/fonts/";
	public var SETTINGS(default, never):String = "settings";
	public var SPLASHSCREENS_PATH(default, never):String = "assets/splash/";
	public var SHADERS_PATH(default, never):String = "assets/shaders/";
	//public var code(default, null):BaseCode;
	private var physicsEnabled:Bool;
	private var contentLayer:BeardLayer;
	private var UILayer:BeardLayer;
	private var loadingLayer:BeardLayer;
	private var pause:Bool;
	
	private var splashScreen:SplashScreen;
	
	public var entities:Array<GameEntity>;
	public var cameras:Map<String,Camera>;
	public var currentScreen:BasicScreen;
	var fps:MemoryUsage;
	public function new() 
	{
		super();
		game = this;
	
	}
	override public function onPreloadComplete():Void 
	{
		Init();
	}
	
	private function Init():Void
	{
	
		//game = this;
		
		//#if mobile
			//
		//SAVE_PATH = System.applicationStorageDirectory+"/save/";
			//
		//#end
		//code = new haxe.crypto.BaseCode(haxe.io.Bytes.ofString("LUDO"));
		contentLayer = new BeardLayer("ContentLayer", BeardLayer.DEPTH_CONTENT);
		contentLayer.visible = false;
		UILayer = new BeardLayer("UILayer", BeardLayer.DEPTH_UI);
		UILayer.visible = false;
		loadingLayer = new BeardLayer("LoadingLayer", BeardLayer.DEPTH_LOADING);
		loadingLayer.visible = false;
		cameras = new Map<String,Camera>();
		AddCamera(new Camera("default",window.width, window.height));
		
		cameras["default"].Center(Application.current.window.width * 0.5, Application.current.window.height * 0.5);
		
		entities = new Array<GameEntity>();
		
		//fps = new MemoryUsage(10,10,0xffffff);
		//stage.addChild(fps);
		
		InputManager.Get().Activate(Application.current.window);
		
		if (FileSystem.exists(SPLASHSCREENS_PATH) && FileSystem.readDirectory(SPLASHSCREENS_PATH).length > 0){
			
			splashScreen = new SplashScreen(FileSystem.readDirectory(SPLASHSCREENS_PATH));
			splashScreen.AddStep( new VoidStep("LoadSettings", LoadSettings));
			Wait.WaitFor(3, splashScreen.Start);
			
		}
		else 
			LoadSettings();
		
	}
	
	
	private inline function LoadSettings():Void
	{
		
		AssetManager.Get().Append(AssetType.XML, SETTING_PATH, SETTINGS);
		AssetManager.Get().Load( OnSettingsLoaded, OnSettingsProgressing, OnSettingsFailed);
		
	}
	
	private function OnSettingsLoaded():Void
	{
		OptionsManager.Get().parseSettings(AssetManager.Get().GetContent(SETTINGS));
		physicsEnabled = OptionsManager.Get().GetSettings("physics").get("enabled") == "true";
		
		LoadResources();
	}
	
	private function OnSettingsProgressing(progress:Float):Void
	{
		trace("Setting Loading in progress... " + progress*100 +" %" );		
	}
		
	public function OnSettingsFailed(e:LoaderErrorType):Void
	{
		trace("/!\\ Setting Loading Failed!\nError name:  " + e.getName() +"\nError Parameters: " + e.getParameters());		
	}
	
	private inline function LoadResources():Void
	{
		
		if (OptionsManager.Get().resourcesToLoad.length > 0 || OptionsManager.Get().fontsToLoad.length > 0){
			for (resource in OptionsManager.Get().resourcesToLoad)
			{
				AssetManager.Get().Append(resource.type, resource.url, resource.name,null,OnPreciseResourcesProgress);
			}
			
			//trace("*** Resources to load : " + OptionsManager.Get().resourcesToLoad);
			Shaders.LoadShaders();
			for (font in OptionsManager.Get().fontsToLoad)
			{
				for (size in font.size)
				{
					AssetManager.Get().LoadFont(font.name,  font.format, size);
				}
			}
			
			AssetManager.Get().Load(GameStart, OnResourcesProgress, OnResourcesFailed);
		}
		else GameStart();
		
		
	}
	
	private function GameStart():Void
	{
		//var unique_id:String = SessionData.generateID("BeardGame_"); 
			//
    //
		//var crashDumper = new CrashDumper(unique_id); 
		if (cameras != null && cameras["default"] != null){
			
			cameras["default"].viewportWidth = window.width;
			cameras["default"].viewportHeight = window.height;
			trace("Default camera resized");
		}
		
		if (physicsEnabled)
			PhysicsManager.Get().InitSpace(OptionsManager.Get().GetSettings("physics"));
		
		Renderer.Get().Start();
		
		
	}
	
	private function OnResourcesProgress(progress:Float):Void
	{
		
		trace("*** Resources Loading in progress... " + progress*100 + " %");
		
		
	}
	
	private function OnPreciseResourcesProgress(e:LoaderEvent<Dynamic>):Void
	{
		
		trace("*** Precise Resources Loading in progress...!" + ((e.target.progress + AssetManager.Get().get_progress()) / 2));
		
		
	}
	
	private function OnResourcesFailed(error: LoaderErrorType):Void
	{
		
		trace("/!\\ *** Resources Loading Failed!\nError name:  " + error.getName() +"\nError Parameters: " + error.getParameters());		
		
	}
	
	public function AddCamera(camera:Camera):Bool
	{
		if (!cameras.exists(camera.name)){
			cameras[camera.name] = camera;
			return true;
		}
		
		return false;
		
	}
	
	public function RemoveCamera(id:String):Void
	{
		cameras[id] = null;	
		
	}
	
	public function Pause(pause:Bool=true):Void
	{
		
		this.pause = pause;
		//do more stuff if needed

	}
	
	override public function render(context:RenderContext):Void 
	{
		
		
		
		//trace("prep for rendering");
		//VisualRenderer.Get().UpdateBufferFromLayer(contentLayer);
		Renderer.Get().Render();
		
		
	}
	

	override public function update(deltaTime:Int):Void 
	{
		//trace(deltaTime);
		
		if (preloader.complete){
			
			if (!InputManager.directMode) InputManager.Get().Update();
			
				if (!UpdateProcessesManager.Get().IsEmpty())	UpdateProcessesManager.Get().Update();
						
				UIManager.Get().Update();

				if (!pause){
					
					if (physicsEnabled && PhysicsManager.Get().get_space() != null)
						PhysicsManager.Get().Step(deltaTime);
						
					if (currentScreen != null && currentScreen.ready){
						
						for (entity in currentScreen.entities)
						{
							entity.Update();
						}
						
						currentScreen.Update();
					}

				}
		}
		
		
		//trace(fps.text);
	}
		
	public inline function GetFPS():Float
	{
		return Application.current.window.frameRate;
	}
	
	override public function onWindowDeactivate():Void 
	{
		
	}
	override public function onWindowResize(width:Int, height:Int):Void 
	{
		
		if (cameras != null && cameras["default"] != null){
			
			cameras["default"].viewportWidth = width;
			cameras["default"].viewportHeight = height;
			trace("Default camera resized");
		}
	}
	
	public static inline function Get():BeardGame
	{
		return game;
	}
	
	public inline function GetLayer(layerType:BeardLayerType):BeardLayer
	{
		var layer:BeardLayer;
		switch(layerType)
		{
			
			case BeardLayerType.CONTENT : layer=  contentLayer;
			case BeardLayerType.LOADING : layer= loadingLayer;
			case BeardLayerType.UI : layer = UILayer;
			
			
		}
		
		
		return layer;
		
	}
	
	public inline function GetContentLayer():BeardLayer
	{
		return contentLayer;
	}
	
	public inline function GetUILayer():BeardLayer
	{
		//trace("returned layer : " + layer);
		return UILayer;
	}
	
	public inline function GetLoadingLayer():BeardLayer
	{
		return loadingLayer;
	}

}


