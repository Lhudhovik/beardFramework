package beardFramework.gameSystem.levels;
import beardFramework.core.BeardGame;
import msignal.Signal.Signal0;
import openfl.display.Sprite;
import openfl.display.Stage;

/**
 * ...
 * @author Ludo
 */
class Level 
{
	public var onReady(get, null):Signal0;
	private var contentLayer : Sprite;
	public function new() 
	{
		onReady = new Signal0();
		contentLayer = BeardGame.Game().GetContentLayer();

		Init();
	}
	
	public inline function get_onReady():Signal0
		return onReady;
	private function Init():Void
	{
		
	}
	public function ParseLevelData(xml:Xml):Void
	{
		
	}
	
}