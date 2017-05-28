package BeardFramework.Core 
{

	import BeardFramework.Events.InputManager;
	import BeardFramework.Resources.Assets.AssetManager;
	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.XMLLoader;
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.desktop.NativeApplication;
	import flash.events.Event;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	/**
	 * ...
	 * @author Ludo
	 */
	public class BeardMain extends Sprite
	{
		
		public const SETTINGS_PATH:String = "/res/gp.xml";
		public const SETTINGS:String = "settings";
		public function BeardMain() 
		{
		
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.addEventListener(Event.DEACTIVATE, deactivate);
			
			// touch or gesture?
			Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
			
			init();
			
			
		}
		
		private function init():void{
			
			
			// Do visual Loading stuff
			
			
			
			//load settings
		
			
			AssetManager.getInstance().append(AssetManager.LOADER_TYPE_XML, SETTINGS_PATH, SETTINGS);
			AssetManager.getInstance().load(onSettingsLoaded, onSettingsProgressing, onSettingsFailed);
			
			//Inputs Should Check for the settings to add listeners
			stage.addEventListener(MouseEvent.CLICK, InputManager.getInstance().onMouseEvent);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, InputManager.getInstance().onKeyboardEvent);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, InputManager.getInstance().onKeyboardEvent);
			
			
		
			
		}
		
		private function onSettingsLoaded(e:LoaderEvent):void{
			
			trace("complete!");
			trace(AssetManager.getInstance().getContent(SETTINGS));
			
		}
		private function onSettingsProgressing(e:LoaderEvent):void{
			trace("progress...");
			trace(e.data);
			
		}
		private function onSettingsFailed(e:LoaderEvent):void{
			trace("error !");
			trace(e.data +"\n"+ e.text + e.type );
		
			
		}
		private function deactivate(e:Event):void 
		{
			// make sure the app behaves well (or exits) when in background
			//NativeApplication.nativeApplication.exit();
		}
	}

}