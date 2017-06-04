package beardFramework.core;

import beardFramework.core.system.OptionsManager;
import beardFramework.events.input.InputManager;
import beardFramework.resources.assets.AssetManager;
import mloader.Loader.LoaderErrorType;
import mloader.Loader.LoaderEvent;
import openfl.display.Sprite;
import openfl.display.StageScaleMode;
import openfl.display.StageAlign;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.ui.Multitouch;
import openfl.ui.MultitouchInputMode;
/**
 * ...
 * @author Ludo
 */
class BeardMain extends Sprite
{
	
	public var SETTING_PATH(default, never):String = "/assets/gp.xml";
	public var SETTINGS(default, never):String = "settings";
	
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
	
		// Do visual Loading stuff
				
		
		//load settings
		AssetManager.get_instance().Append(AssetType.XML, SETTING_PATH, SETTINGS, OnSettingsLoaded, OnSettingsProgressing, OnSettingsFailed);
		
		//Inputs Should Check for the settings to add listeners
		stage.addEventListener(MouseEvent.CLICK, InputManager.get_instance().OnMouseEvent);
		stage.addEventListener(KeyboardEvent.KEY_UP, InputManager.get_instance().OnKeyboardEvent);
		stage.addEventListener(KeyboardEvent.KEY_DOWN, InputManager.get_instance().OnKeyboardEvent);
		
		
		
	}
	
	private function OnSettingsLoaded(e:LoaderEvent<Dynamic>):Void{
		
	//	trace("complete!");
		//trace(AssetManager.getInstance().getContent(SETTINGS));
		OptionsManager.get_instance().parseSettings(AssetManager.get_instance().getContent(SETTINGS));
		
		LoadResources();
	}
	
	private function OnSettingsProgressing(e:LoaderEvent<Dynamic>):Void{
	//	trace("progress...");
		//trace(e.data);
		
	}
		
	private function OnSettingsFailed(e:LoaderEvent<Dynamic>):Void{
		//trace("error !");
		//trace(e.data +"\n"+ e.text + e.type );
		
	}
	
	private function LoadResources():Void{
		
		for (resource in OptionsManager.get_instance().resourcesToLoad)
		{
			AssetManager.get_instance().Append(resource.type, resource.url, resource.name);
		}
		
		AssetManager.get_instance().Load(OnResourcesLoaded, OnResourcesProgress, OnResourcesFailed);
		
		
	}
	
	private function OnResourcesLoaded():Void
	{
		
		trace("yeah");
		
	}
	
	private function OnResourcesProgress(progress:Float):Void
	{
		
		
		
		
	}
	private function OnResourcesFailed(error: LoaderErrorType):Void
	{
		
		
		
		
	}
	private function deactivate(e:Event):Void{
		
		
		
	}
}