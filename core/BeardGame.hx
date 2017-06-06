package beardFramework.core;

import beardFramework.core.system.OptionsManager;
import beardFramework.events.input.InputManager;
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
	private static var instance:BeardGame;
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
	
		instance = this;
		// Do visual Loading stuff
	
		//Inputs Should Check for the settings to add listeners
		//stage.addEventListener(MouseEvent.CLICK, InputManager.get_instance().OnMouseEvent);
		//stage.addEventListener(KeyboardEvent.KEY_UP, InputManager.get_instance().OnKeyboardEvent);
		//stage.addEventListener(KeyboardEvent.KEY_DOWN, InputManager.get_instance().OnKeyboardEvent);
		InputManager.get_instance().Activate(stage.window);
		AssetManager.get_instance().Append(AssetType.XML, SETTING_PATH, SETTINGS, OnSettingsLoaded, OnSettingsProgressing, OnSettingsFailed);
		
		AssetManager.get_instance().Load();
		
	}
	
	private function OnSettingsLoaded(e:LoaderEvent<Dynamic>):Void{
		
		
		OptionsManager.get_instance().parseSettings(AssetManager.get_instance().getContent(SETTINGS));
		
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
	private function deactivate(e:Event):Void{
		
		
		
	}
	public static inline function getInstance():BeardGame
	{
		return instance;
	}
}