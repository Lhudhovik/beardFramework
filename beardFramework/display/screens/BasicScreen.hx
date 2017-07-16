package beardFramework.display.screens;
import beardFramework.core.BeardGame;
import beardFramework.core.system.thread.Thread.ThreadDetail;
import beardFramework.display.cameras.Camera;
import beardFramework.display.core.BeardSprite;
import msignal.Signal.Signal0;
import openfl.display.Sprite;
import openfl.display.Stage;

/**
 * ...
 * @author Ludo
 */
class BasicScreen 
{
	public var onReady(get, null):Signal0;
	public var onTransitionFinished(get, null):Signal0;
	public var dataPath:String;
	private var contentLayer:BeardSprite;
	private var defaultCamera:Camera;
	//private var id:String;
	private var loadingProgression(get, null):Float;
	
	
	public function new(dataNeeded:Bool = true) 
	{
		onReady = new Signal0();
		onTransitionFinished = new Signal0();
		if (!dataNeeded) Init();
	}
	
	public inline function get_onReady():Signal0 return onReady;
		
	private function Init():Void
	{
		contentLayer = BeardGame.Game().GetContentLayer();
		defaultCamera = BeardGame.Game().cameras["default"];
	}
	
	public function ParseScreenData(threadDetail:ThreadDetail<Xml>):Bool
	{
		Init();
		return true;
	}
	
	public function Clear(threadDetail:ThreadDetail<Int>):Bool
	{
		return true;
	}
	
	public function Freeze(freeze:Bool = true):Void
	{
		//do stuff to stop game Logic and prevent any error during loading etc.
	}
		
	public function TransitionIn():Void
	{
		Show();
		//Do visual Stuff
	}
	
	public function TransitionOut():Void
	{
		
	}
	
	inline function get_loadingProgression():Float 
	{
		return loadingProgression;
	}
	
	public inline function Hide():Void
	{
		contentLayer.visible = false;
	}
	
	public inline function Show():Void
	{
		contentLayer.visible = true;
	}
	
	function get_onTransitionFinished():Signal0 
	{
		return onTransitionFinished;
	}
	public inline function isDisplayed():Bool
	{
		return contentLayer.visible;
	}
	
	
}