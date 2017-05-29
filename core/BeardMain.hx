package beardFramework.core;

import beardFramework.events.input.InputManager;
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
		//AssetManager.getInstance().append(AssetManager.LOADER_TYPE_XML, SETTINGS_PATH, SETTINGS);
		//AssetManager.getInstance().load(onSettingsLoaded, onSettingsProgressing, onSettingsFailed);
		
		//Inputs Should Check for the settings to add listeners
		stage.addEventListener(MouseEvent.CLICK, InputManager.get_instance().OnMouseEvent);
		stage.addEventListener(KeyboardEvent.KEY_UP, InputManager.get_instance().OnKeyboardEvent);
		stage.addEventListener(KeyboardEvent.KEY_DOWN, InputManager.get_instance().OnKeyboardEvent);
		
		
		
	}
	
	/*private function onSettingsLoaded(e:LoaderEvent):Void{
		
	//	trace("complete!");
		//trace(AssetManager.getInstance().getContent(SETTINGS));
		
	}
	
	private function onSettingsProgressing(e:LoaderEvent):void{
	//	trace("progress...");
		//trace(e.data);
		
	}
		
	private function onSettingsFailed(e:LoaderEvent):Void{
		//trace("error !");
		//trace(e.data +"\n"+ e.text + e.type );
		
	}
	*/
	private function deactivate(e:Event):Void{
		
		
		
	}
}