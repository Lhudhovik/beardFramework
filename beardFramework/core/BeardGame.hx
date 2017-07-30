package beardFramework.core;

import beardFramework.core.system.OptionsManager;
import beardFramework.core.system.ScreenFlowManager;
import beardFramework.debug.MemoryUsage;
import beardFramework.display.cameras.Camera;
import beardFramework.display.core.BeardLayer;
import beardFramework.display.core.BeardSprite;
import beardFramework.display.screens.BasicScreen;
import beardFramework.events.input.InputManager;
import beardFramework.interfaces.ICameraDependent;
import beardFramework.physics.PhysicsManager;
import beardFramework.resources.assets.AssetManager;
import beardFramework.utils.StringLibrary;
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
	private static var game:BeardGame;
	
	public var SETTING_PATH(default, never):String = "assets/gp.xml";
	public var SETTINGS(default, never):String = "settings";
	private var physicsEnabled:Bool;
	private var contentLayer:BeardLayer;
	private var UILayer:BeardLayer;
	private var LoadingLayer:BeardLayer;
	private var pause:Bool;
	
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
		// Do visual Loading stuff
		contentLayer = new BeardLayer("ContentLayer");
		contentLayer.visible = false;
		UILayer = new BeardLayer("UILayer");
		UILayer.visible = false;
		LoadingLayer = new BeardLayer("LoadingLayer");
		LoadingLayer.visible = false;
		cameras = new Map<String,Camera>();
		AddCamera(new Camera("default", stage.stageWidth, stage.stageHeight));
		stage.addChild(contentLayer);
		stage.addChild(UILayer);
		stage.addChild(LoadingLayer);
		//
		InputManager.get_instance().Activate(stage.window);
		
		AssetManager.get_instance().Append(AssetType.XML, SETTING_PATH, SETTINGS, OnSettingsLoaded, OnSettingsProgressing, OnSettingsFailed);
		
		AssetManager.get_instance().Load();
		
		var fps:MemoryUsage = new MemoryUsage(10,10,0xffffff);
		stage.addChild(fps);
		
		
	}
	
	private function OnSettingsLoaded(e:LoaderEvent<Dynamic>):Void
	{
		
		
		OptionsManager.get_instance().parseSettings(AssetManager.get_instance().GetContent(SETTINGS));
		physicsEnabled = OptionsManager.get_instance().GetSettings("physics").get("enabled") == "true";
		LoadResources();
	}
	
	private function OnSettingsProgressing(e:LoaderEvent<Dynamic>):Void
	{
		trace("progress...");
		trace(e.target.progress);
		
	}
		
	public function OnSettingsFailed(e:LoaderEvent<Dynamic>):Void
	{
		trace("error !");
		trace(e.type.getName() +"\n" + e.type.getParameters());
		
	}
	
	private function LoadResources():Void
	{
		
		if (OptionsManager.get_instance().resourcesToLoad.length > 0){
			for (resource in OptionsManager.get_instance().resourcesToLoad)
			{
				AssetManager.get_instance().Append(resource.type, resource.url, resource.name,null,OnPreciseResourcesProgress);
			}
			trace(OptionsManager.get_instance().resourcesToLoad);
			
			AssetManager.get_instance().Load(GameStart, OnResourcesProgress, OnResourcesFailed);
		}
		else GameStart();
		
		
	}
	
	private function GameStart():Void
	{
		
		if (physicsEnabled)
			PhysicsManager.get_instance().InitSpace(OptionsManager.get_instance().GetSettings("physics"));
		
	}
	
	private function OnResourcesProgress(progress:Float):Void
	{
		
		trace(progress);
		
		
	}
	
	private function OnPreciseResourcesProgress(e:LoaderEvent<Dynamic>):Void
	{
		
		trace((e.target.progress + AssetManager.get_instance().get_progress()) / 2);
		
		
	}
	
	private function OnResourcesFailed(error: LoaderErrorType):Void
	{
		
		trace(error.getName() + "\n" + error.getParameters());
		
		
	}
	
	public function AddCamera(camera:Camera):Bool
	{
		if (!cameras.exists(camera.id)){
			cameras[camera.id] = camera;
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
	override function __enterFrame(deltaTime:Int):Void 
	{
		super.__enterFrame(deltaTime);
		
		if (ScreenFlowManager.get_instance().transitioning)
		{
			
			if (!ScreenFlowManager.get_instance().get_transitionThread().empty) ScreenFlowManager.get_instance().get_transitionThread().Proceed();
		}
		
		if (!pause){
			
		
			if (physicsEnabled && PhysicsManager.get_instance().get_space() != null)
				PhysicsManager.get_instance().Step(deltaTime);
			
		}
	}
	
	
	
	public function getTargetUnderPoint (point:Point):DisplayObject
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
				if (ScreenFlowManager.get_instance().transitioning)	hit = LoadingLayer.ChildHitTest(tempPoint.x, tempPoint.y, false, stack, true, LoadingLayer);
				else if(!(hit = UILayer.ChildHitTest(tempPoint.x, tempPoint.y, false, stack, true, UILayer)))
					hit = contentLayer.ChildHitTest(tempPoint.x, tempPoint.y, false, stack, true, contentLayer);
				if (hit) break;
			}
			
		}
		
		StringLibrary.utilString = "";
		for (element in stack){
			StringLibrary.utilString += "   -->  " + element.name;
		}
		
		trace(StringLibrary.utilString);
		
		
		stack.reverse ();
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
			trace("default camera resized");
		}
	}
	
	public static inline function Game():BeardGame
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