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
	private var contentLayer:BeardSprite;
	private var defaultCamera:Camera;
	private var id:String;
	private var loadingProgression(get, null):Float;
	
	public function new(dataNeeded:Bool = true) 
	{
		onReady = new Signal0();
		if (!dataNeeded) Init();
	}
	
	public inline function get_onReady():Signal0
		return onReady;
		
	
	private function Init():Void
	{
		contentLayer = BeardGame.Game().GetContentLayer();
		defaultCamera = BeardGame.Game().cameras["default"];
	
	}
	
	public function ParseScreenData(threadDetail:ThreadDetail<Xml>):Void
	{

		
		
		
	}
	
	public function Clear():Bool
	{
		
	}
	
	inline function get_loadingProgression():Float 
	{
		return loadingProgression;
	}
	
	
	
}