package beardFramework.core;

import beardFramework.core.system.OptionsManager;
import beardFramework.core.system.ScreenFlowManager;
import beardFramework.debug.MemoryUsage;
import beardFramework.display.cameras.Camera;
import beardFramework.display.core.BeardLayer;
import beardFramework.display.core.BeardSprite;
import beardFramework.display.screens.BasicScreen;
import beardFramework.display.ui.UIManager;
import beardFramework.gameSystem.entities.GameEntity;
import beardFramework.input.InputManager;
import beardFramework.interfaces.ICameraDependent;
import beardFramework.physics.PhysicsManager;
import beardFramework.resources.assets.AssetManager;
import beardFramework.resources.save.data.DataSave;
import beardFramework.utils.StringLibrary;
import haxe.Json;
import haxe.crypto.BaseCode;
import haxe.io.Bytes;
import openfl.system.System;
import mloader.Loader;
import mloader.Loader.LoaderErrorType;
import mloader.Loader.LoaderEvent;
import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;
import openfl.display.Sprite;
import openfl.display.StageScaleMode;
import openfl.display.StageAlign;
import openfl.display.Window;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.geom.Point;
import openfl.ui.Multitouch;
import openfl.ui.MultitouchInputMode;
import openfl._internal.renderer.RenderSession;
import openfl._internal.renderer.opengl.GLDisplayObject;

@:access(openfl.display.Graphics)
@:access(openfl.display.Stage)
@:access(openfl.geom.Point)
/**
 * ...
 * @author Ludo
 */
class BeardGame extends Sprite
{
	private static var game(default, null):BeardGame;
	
	public var SETTING_PATH(default, never):String = "assets/gp.xml";
	public var SAVE_PATH(default, null):String = "save/";
	public var UI_PATH(default, null):String = "assets/UI/";
	public var SETTINGS(default, never):String = "settings";
	//public var code(default, null):BaseCode;
	private var physicsEnabled:Bool;
	private var contentLayer:BeardLayer;
	private var UILayer:BeardLayer;
	private var LoadingLayer:BeardLayer;
	private var pause:Bool;
	private var updateProcesses:List<UpdateProcess>;
	
	public var entities:Array<GameEntity>;
	public var cameras:Map<String,Camera>;
	public var currentScreen:BasicScreen;
	
	public function new() 
	{
		super();
		
		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.align = StageAlign.TOP_LEFT;
		stage.addEventListener(Event.DEACTIVATE, Deactivate);
		stage.addEventListener(Event.RESIZE, Resize);
		Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
		
		Init();
	}
	
	private function Init():Void
	{
	
		game = this;
		
		#if mobile
			
		SAVE_PATH = System.applicationStorageDirectory+"/save/";
			
		#end
		//code = new haxe.crypto.BaseCode(haxe.io.Bytes.ofString("LUDO"));
		
		
		// Do visual Loading stuff
		contentLayer = new BeardLayer("ContentLayer");
		contentLayer.visible = false;
		UILayer = new BeardLayer("UILayer");
		UILayer.visible = false;
		LoadingLayer = new BeardLayer("LoadingLayer");
		LoadingLayer.visible = false;
		cameras = new Map<String,Camera>();
		AddCamera(new Camera("default", stage.stageWidth, stage.stageHeight));
		updateProcesses = new List<UpdateProcess>();
		
		stage.addChild(contentLayer);
		stage.addChild(UILayer);
		stage.addChild(LoadingLayer);
		
		
		
		
		
		//InputManager.Get().Activate(stage.window);
		
		AssetManager.Get().Append(AssetType.XML, SETTING_PATH, SETTINGS);
		
		AssetManager.Get().Load( OnSettingsLoaded, OnSettingsProgressing, OnSettingsFailed);
		
		entities = new Array<GameEntity>();
		
		var fps:MemoryUsage = new MemoryUsage(10,10,0xffffff);
		stage.addChild(fps);
		
		
	}
	
	private function OnSettingsLoaded():Void
	{
		
		
		OptionsManager.Get().parseSettings(AssetManager.Get().GetContent(SETTINGS));
		physicsEnabled = OptionsManager.Get().GetSettings("physics").get("enabled") == "true";
		
		LoadResources();
	}
	
	private function OnSettingsProgressing(progress:Float):Void
	{
		trace("Setting Loading in progress... " + progress +" %" );		
	}
		
	public function OnSettingsFailed(e:LoaderErrorType):Void
	{
		trace("/!\\ Setting Loading Failed!\nError name:  " + e.getName() +"\nError Parameters: " + e.getParameters());		
	}
	
	private function LoadResources():Void
	{
		
		if (OptionsManager.Get().resourcesToLoad.length > 0){
			for (resource in OptionsManager.Get().resourcesToLoad)
			{
				AssetManager.Get().Append(resource.type, resource.url, resource.name,null,OnPreciseResourcesProgress);
			}
			trace("*** Resources to load : " + OptionsManager.Get().resourcesToLoad);
			
			AssetManager.Get().Load(GameStart, OnResourcesProgress, OnResourcesFailed);
		}
		else GameStart();
		
		
	}
	
	private function GameStart():Void
	{
		
		if (physicsEnabled)
			PhysicsManager.Get().InitSpace(OptionsManager.Get().GetSettings("physics"));
		
	}
	
	private function OnResourcesProgress(progress:Float):Void
	{
		
		trace("*** Resources Loading in progress... " + progress + " %");
		
		
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
	
	public function AddUpdateProcess(name: String, call:Void->Void):Void
	{
		var exist:Bool = false;
		for (process in updateProcesses)
		{
			if (process.name == name) return;
		}
		
		
		updateProcesses.add({name : name, process:call});

		
	}
	
	public function RemoveUpdateProcess(name:String):Void
	{
		
		for (process in updateProcesses)
		{
			if (process.name == name){
				updateProcesses.remove(process);
				
			}
		}
	}
	
	override function __enterFrame(deltaTime:Int):Void 
	{

		
		//if (ScreenFlowManager.Get().transitioning)
		//{
			//
			//if (!ScreenFlowManager.Get().get_transitionThread().isEmpty()) ScreenFlowManager.Get().get_transitionThread().Proceed();
		//}
		//
		if (!updateProcesses.isEmpty())
		{
			for (process in updateProcesses)
				process.process();
		}
	
		if (!pause){
			
			if (!InputManager.directMode) InputManager.Get().Update();
			
			UIManager.Get().Update();
			
			if (physicsEnabled && PhysicsManager.Get().get_space() != null)
				PhysicsManager.Get().Step(deltaTime);
				
			for (entity in entities)
			{
				entity.Update();
			}
	
		}
		
		//trace(BeardGame.Get().GetUILayer().visible);
		
		super.__enterFrame(deltaTime);
		
	}
		
	public function getTargetUnderPoint (point:Point, reverse:Bool = true):DisplayObject
	{
		var tempPoint:Point = Point.__pool.get ();
		var stack = new Array<DisplayObject> ();
		var hit:Bool = false;
		var i :Int = 0;
		for (camera in cameras){
			
			if (camera.ContainsPoint(point))
			{
				hit = false;
				tempPoint.x = (point.x - camera.viewportX) + camera.cameraX;
				tempPoint.y = (point.y - camera.viewportY) + camera.cameraY;
				
				//trace(tempPoint);
				if (ScreenFlowManager.Get().transitioning)	hit = LoadingLayer.ChildHitTest(tempPoint.x, tempPoint.y, false, stack, true, LoadingLayer);
				else if(!(hit = UILayer.ChildHitTest(tempPoint.x, tempPoint.y, false, stack, true, UILayer)))
					hit = contentLayer.ChildHitTest(tempPoint.x, tempPoint.y, false, stack, true, contentLayer);
				if (hit) break;
			}
			
		}
		
		/*StringLibrary.utilString = "";
		for (element in stack){
			StringLibrary.utilString += "   -->  " + element.name;
		}
		
		trace(StringLibrary.utilString);
		*/
		
		if(reverse) stack.reverse ();
		return stack != null ? stack[0] : null;
		
	}
	
	private function Deactivate(e:Event):Void
	{
		
		
		
	}
	
	private function Resize(e:Event):Void
	{
		
		if (cameras != null && cameras["default"] != null){
			
			cameras["default"].viewportWidth = stage.stageWidth;
			cameras["default"].viewportHeight = stage.stageHeight;
			trace("Default camera resized");
		}
	}
	
	public static inline function Get():BeardGame
	{
		return game;
	}
	
	public inline function GetContentLayer():BeardLayer
	{
		return contentLayer;
	}
	
	public inline function GetUILayer():BeardLayer
	{
		return UILayer;
	}
	
	public inline function GetLoadingLayer():BeardLayer
	{
		return LoadingLayer;
	}

}


typedef UpdateProcess =
{
	var name : String;
	var process: Void->Void;
}