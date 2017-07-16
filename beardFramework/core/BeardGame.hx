package beardFramework.core;

import beardFramework.core.system.OptionsManager;
import beardFramework.debug.MemoryUsage;
import beardFramework.display.cameras.Camera;
import beardFramework.display.core.BeardSprite;
import beardFramework.display.screens.BasicScreen;
import beardFramework.events.input.InputManager;
import beardFramework.interfaces.ICameraDependent;
import beardFramework.physics.PhysicsManager;
import beardFramework.resources.assets.AssetManager;
import mloader.Loader;
import mloader.Loader.LoaderErrorType;
import mloader.Loader.LoaderEvent;
import openfl.display.DisplayObject;
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
	private var contentLayer:BeardSprite;
	private var UILayer:BeardSprite;
	private var LoadingLayer:BeardSprite;
	public var cameras:Map<String,Camera>;
	private var pause:Bool;
	private var currentScreen(get, null):BasicScreen;
	
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
		contentLayer = new BeardSprite();
		contentLayer.visible = false;
		UILayer = new BeardSprite();
		UILayer.visible = false;
		LoadingLayer = new BeardSprite();
		LoadingLayer.visible = false;
		cameras = new Map<String,Camera>();
		AddCamera(new Camera("default", stage.stageWidth, stage.stageHeight));
		stage.addChild(contentLayer);
		stage.addChild(UILayer);
		stage.addChild(LoadingLayer);
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
		
	private function OnSettingsFailed(e:LoaderEvent<Dynamic>):Void
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
		
		if (!pause){
			
		
			if (physicsEnabled && PhysicsManager.get_instance().get_space() != null)
				PhysicsManager.get_instance().Step(deltaTime);
			
		}
	}
	
	public function getTargetUnderPoint (point:Point):Array<DisplayObject> 
	{
		
		var stack = new Array<DisplayObject> ();
		__hitTest (point.x, point.y, false, stack, true, stage);
		//for (element in stack)
		//trace(element.name);
		stack.reverse ();
		return stack;
		
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
	
	public inline function GetContentLayer():BeardSprite
	{
		return contentLayer;
	}
	
	public inline function GetUILayer():BeardSprite
	{
		return UILayer;
	}
	public inline function GetLoadingLayer():BeardSprite
	{
		return LoadingLayer;
	}
	
	private override function __renderGL (renderSession:RenderSession):Void 
	{
		
		if (!__renderable || __worldAlpha <= 0) return;
		
		GLDisplayObject.render (this, renderSession);
		
		var utilX:Float;
		var utilY:Float;
	
		renderSession.filterManager.pushObject (this);
		
		for (camera in cameras.iterator()){
		
			renderSession.maskManager.pushRect (camera.GetRect(), camera.transform);
			
			for (child in __children) {
				if (camera.Contains(child)){
					
					
					if (Std.is(child, ICameraDependent)){
						
						cast(child, ICameraDependent).RenderThroughCamera(camera, renderSession);
					}
					else{
						utilX = child.__transform.tx;
						utilY = child.__transform.ty;
						child.__transform.tx = camera.viewportX +(utilX - camera.cameraX);
						child.__transform.ty = camera.viewportY + (utilY - camera.cameraY);
						child.__update(true, true);
						child.__renderGL (renderSession);
						child.__transform.tx = utilX;
						child.__transform.ty = utilY;
					}
					
				}
				
				
			}
		
			for (orphan in __removedChildren) {
				
				if (orphan.stage == null) {
					
					orphan.__cleanup ();
					
				}
				
			}
		
		__removedChildren.length = 0;
		
			
			renderSession.maskManager.popRect ();
		}
		renderSession.filterManager.popObject (this);
	}
	
	public function get_currentScreen():BasicScreen 
	{
		return currentScreen;
	}
	

}