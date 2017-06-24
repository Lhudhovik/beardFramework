package beardFramework.core;

import beardFramework.core.system.OptionsManager;
import beardFramework.events.input.InputManager;
import beardFramework.physics.PhysicsManager;
import beardFramework.resources.assets.AssetManager;
import mloader.Loader;
import mloader.Loader.LoaderErrorType;
import mloader.Loader.LoaderEvent;
import openfl.display.Sprite;
import openfl.display.StageScaleMode;
import openfl.display.StageAlign;
import openfl.display.Window;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.ui.Multitouch;
import openfl.ui.MultitouchInputMode;
/**
 * ...
 * @author Ludo
 */
class BeardGame extends Sprite
{
	
	public var SETTING_PATH(default, never):String = "assets/gp.xml";
	public var SETTINGS(default, never):String = "settings";
	private static var game:BeardGame;
	private var physicsEnabled:Bool;
	private var contentLayer:Sprite;
	private var UILayer:Sprite;
	
	public function new() 
	{
		super();
		
		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.align = StageAlign.TOP_LEFT;
		stage.addEventListener(Event.DEACTIVATE, deactivate);
		
		Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
		
		Init();
	}
	
	private function Init():Void{
	
		game = this;
		// Do visual Loading stuff
		contentLayer = new Sprite();
		UILayer = new Sprite();
		
		stage.addChild(contentLayer);
		stage.addChild(UILayer);
		InputManager.get_instance().Activate(stage.window);
		AssetManager.get_instance().Append(AssetType.XML, SETTING_PATH, SETTINGS, OnSettingsLoaded, OnSettingsProgressing, OnSettingsFailed);
		
		AssetManager.get_instance().Load();
		
	}
	
	private function OnSettingsLoaded(e:LoaderEvent<Dynamic>):Void{
		
		
		OptionsManager.get_instance().parseSettings(AssetManager.get_instance().getContent(SETTINGS));
		physicsEnabled = OptionsManager.get_instance().GetSettings("physics").get("enabled") == "true";
		LoadResources();
	}
	
	private function OnSettingsProgressing(e:LoaderEvent<Dynamic>):Void{
		trace("progress...");
		trace(e.target.progress);
		
	}
		
	private function OnSettingsFailed(e:LoaderEvent<Dynamic>):Void{
		trace("error !");
		trace(e.type.getName() +"\n" + e.type.getParameters());
		
	}
	
	private function LoadResources():Void{
		
		if (OptionsManager.get_instance().resourcesToLoad.length > 0){
				for (resource in OptionsManager.get_instance().resourcesToLoad)
			{
				AssetManager.get_instance().Append(resource.type, resource.url, resource.name,null,OnPreciseResourcesProgress);
			}
			
			AssetManager.get_instance().Load(GameStart, OnResourcesProgress, OnResourcesFailed);
		}
		else GameStart();
		
		
	}
	
	private function GameStart():Void{
		
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
	
	override function __enterFrame(deltaTime:Int):Void 
	{
		super.__enterFrame(deltaTime);
		
		if (physicsEnabled && PhysicsManager.get_instance().get_space() != null)
			PhysicsManager.get_instance().Step(deltaTime);
		
	}
	
	
	
	private function deactivate(e:Event):Void{
		
		
		
	}
	public static inline function Game():BeardGame
	{
		return game;
	}
	public inline function GetContentLayer():Sprite
	{
		return contentLayer;
	}
	public inline function GetUILayer():Sprite
	{
		return UILayer;
	}

}