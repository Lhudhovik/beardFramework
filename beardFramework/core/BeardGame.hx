package beardFramework.core;

import beardFramework.graphics.objects.RenderedObject;
import beardFramework.graphics.objects.Visual;
import beardFramework.graphics.objects.CameraQuad;
import beardFramework.graphics.core.Renderer;
import beardFramework.graphics.shaders.Shader;
import beardFramework.graphics.batches.Batch;
import beardFramework.graphics.batches.RenderedObjectBatch;
import beardFramework.graphics.screens.regions.RegionGrid;
import beardFramework.input.MousePos;
import beardFramework.resources.options.OptionsManager;
import beardFramework.systems.aabb.AABB;
import beardFramework.updateProcess.UpdateProcessesManager;
import beardFramework.updateProcess.Wait;
import beardFramework.updateProcess.sequence.VoidStep;
import beardFramework.debug.MemoryUsage;
import beardFramework.graphics.cameras.Camera;
import beardFramework.graphics.screens.BeardLayer;
import beardFramework.graphics.screens.BasicScreen;
import beardFramework.graphics.screens.SplashScreen;
import beardFramework.graphics.ui.UIManager;
import beardFramework.systems.entities.GameEntity;
import beardFramework.input.InputManager;
import beardFramework.physics.PhysicsManager;
import beardFramework.resources.assets.AssetManager;
import beardFramework.resources.MinAllocArray;
import beardFramework.utils.libraries.StringLibrary;
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
	public var CONTENTLAYER(default, never):Int = 3;
	public var UILAYER(default, never):Int = 2;
	public var LOADINGLAYER(default, never):Int = 1;
	public var DEBUGLAYER(default, never):Int = 0;
	//public var code(default, null):BaseCode;
	private var physicsEnabled:Bool;
	private var layers:MinAllocArray<BeardLayer>;
	private var pause(default,null):Bool;
	private var gameReady:Bool;
	private var previousWidth:Int;
	private var previousHeight:Int;
	
	//public var grid(default,null):RegionGrid;
	private var splashScreen:SplashScreen;
	
	public var entities:Array<GameEntity>;
	public var cameras:Map<String,Camera>;
	public var currentScreen:BasicScreen;
	public var scaleX:Float = 1;
	public var scaleY:Float = 1;
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
		
		layers = new MinAllocArray(4);
		layers.Push(new BeardLayer("Debug", BeardLayer.DEPTH_DEBUG,DEBUGLAYER));
		layers.Push(new BeardLayer("LoadingLayer", BeardLayer.DEPTH_LOADING,LOADINGLAYER));
		layers.Push(new BeardLayer("UILayer", BeardLayer.DEPTH_UI,UILAYER));
		layers.Push(new BeardLayer("ContentLayer", BeardLayer.DEPTH_CONTENT, CONTENTLAYER));
	
		previousWidth = window.width;
		previousHeight = window.height;
		for (i in 0...4)
			layers.get(i).visible = false;
			
		cameras = new Map<String,Camera>();
		
		
		entities = new Array<GameEntity>();
		
		
		//stage.addChild(fps);
		
		gameReady = false;
		
			
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
		
		if (OptionsManager.Get().resourcesToLoad.length > 0 || OptionsManager.Get().fontsToLoad.length > 0 || OptionsManager.Get().batchesToCreate.length > 0){
			for (resource in OptionsManager.Get().resourcesToLoad)
			{
				AssetManager.Get().Append(resource.type, resource.url, resource.name,null,OnPreciseResourcesProgress);
			}
			
			for (font in OptionsManager.Get().fontsToLoad)
			{
				for (size in font.size)
				{
					AssetManager.Get().LoadFont(font.name,  font.format, size);
				}
			}
			
			
			OptionsManager.Get().resourcesToLoad = null;
			OptionsManager.Get().fontsToLoad = null;
			
			AssetManager.Get().Load(InitGraphics, OnResourcesProgress, OnResourcesFailed);
		}
		else GameStart();
		
		
	}
	
	private function InitGraphics():Void
	{
		
		
		
		Shader.LoadShaders(OptionsManager.Get().shadersToCreate);
		
		var defaultCam:Camera = new Camera(StringLibrary.DEFAULT, 1,1,100);
		AddCamera(defaultCam);
		
		defaultCam.Center(window.width * 0.5,window.height * 0.5);
		
		//if (cameras != null && cameras["default"] != null){
			
			//cameras["default"].viewportWidth = window.width;
			//cameras["default"].viewportHeight = window.height;
			//trace("Default camera resized");
		////}
		
		for (batch in OptionsManager.Get().batchesToCreate)
		{
			trace(batch.name);
			Renderer.Get().CreateBatch(batch.name, batch.template,batch.needOrdering);
		
		}
		
		var quad :CameraQuad = Renderer.Get().AddCameraQuad(StringLibrary.DEFAULT, StringLibrary.DEFAULT);
		//quad.x = 150;
		
		OptionsManager.Get().batchesToCreate = null;		
		OptionsManager.Get().shadersToCreate = null;
		
		
		
		Visual.InitSharedGraphics();
		
		
		GameStart();
	}
	
	private function GameStart():Void
	{
		
		gameReady = true;
		
		
		if (physicsEnabled)
			PhysicsManager.Get().InitSpace(OptionsManager.Get().GetSettings("physics"));
		
		Renderer.Get().Start();	
			
		UIManager.Get();
		
		//fps = new MemoryUsage(10, 10, 0xffffffff);
	//
		//fps.renderingBatch = cast Renderer.Get().GetBatch(Renderer.Get().UI);
		//
		//GetDebugLayer().Add(fps);
		//GetDebugLayer().visible = true;
		//grid = new RegionGrid(window.width, window.height,5);
		
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
		if(gameReady) Renderer.Get().Render();
		
		
	}
	
	override public function update(deltaTime:Int):Void 
	{
		//trace(deltaTime);
		
		if (preloader.complete){
			
			if (!InputManager.directMode) InputManager.Get().Update();
			
			if (!UpdateProcessesManager.Get().IsEmpty())	UpdateProcessesManager.Get().Update();
			
			if (gameReady)
			{
				if (!pause){
				
					for (camera in cameras.keys())
						cameras[camera].Update();
					
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
			
				for (i in 0...layers.length){
					layers.get(i).Update();
				}
				
			
				UIManager.Get().Update();
				
				if(fps!= null) fps.UpdateFPS();
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
		
		scaleX = width / previousWidth;
		scaleY = height / previousHeight;
		if (gameReady) Renderer.Get().OnResize(width, height );
		
		//previousWidth = width;
		//previousHeight = height;
	}
	
	public static inline function Get():BeardGame
	{
		return game;
	}
	
	public inline function GetLayer(layerID:Int):BeardLayer
	{
		return layers.get(layerID);
		
	}
	
	public function GetTargetUnderPoint(x:Float, y:Float):RenderedObject
	{
		var object:RenderedObject = null;
		var testObject:RenderedObject = null;
		
		var aabbs:MinAllocArray<AABB>;
		for (i in 0...layers.length)
		{
			aabbs = layers.get(layers.length - 1 - i).aabbTree.Hit(x, y);
			if (aabbs != null && aabbs.length > 0)
			{
				for (j in 0...aabbs.length)
				{
					testObject = layers.get(layers.length - 1 - i).renderedObjects[aabbs.get(j).owner];
					if (testObject != null && (object == null || object.z > testObject.z) )
						object = testObject;
				}
				
				
			}
			
			if (object != null) break;
		}
		
		
		
		return object;
		
	}
	
	public inline function GetContentLayer():BeardLayer
	{
		return layers.get(CONTENTLAYER);
	}
	
	public inline function GetUILayer():BeardLayer
	{
		//trace("returned layer : " + layer);
		return layers.get(UILAYER);
	}
	
	public inline function GetLoadingLayer():BeardLayer
	{
		return layers.get(LOADINGLAYER);
	}
	
	public inline function GetDebugLayer():BeardLayer
	{
		return layers.get(DEBUGLAYER);
	}
	
	public inline function GetLayersCount():Int
	{
		return layers.length;
	}
	


}


