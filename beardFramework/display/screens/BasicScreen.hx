package beardFramework.display.screens;
import beardFramework.core.BeardGame;
import beardFramework.core.system.thread.Thread.ThreadDetail;
import beardFramework.display.cameras.Camera;
import beardFramework.display.core.BeardLayer;
import beardFramework.display.core.BeardSprite;
import beardFramework.gameSystem.entities.GameEntity;
import beardFramework.interfaces.IEntityVisual;
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
	private var displayLayer:BeardLayer;
	private var defaultCamera:Camera;
	//private var id:String;
	private var loadingProgression(get, null):Float;
	
	
	public function new() 
	{
		onReady = new Signal0();
		onTransitionFinished = new Signal0();
		displayLayer = BeardGame.Game().GetContentLayer();
		defaultCamera = BeardGame.Game().cameras[Camera.DEFAULT];
	}
	
	public inline function AddEntity(entity:GameEntity):Void
	{
		
		if (BeardGame.Game().entities.indexOf(entity) == -1)
		{
			BeardGame.Game().entities.push(entity);
			for (component in entity.GetComponents())
			{
				if (Std.is(component, IEntityVisual))
				{
					cast(component, IEntityVisual).Register();
				}
			}
		
			
		}
		
		
	}
	
	public inline function get_onReady():Signal0 return onReady;
		
	private function Init():Void
	{
		
	}
	
	public function ParseScreenData(threadDetail:ThreadDetail<Xml>):Bool
	{
		Init();
		return true;
	}
	
	public function Play():Void
	{
		//start/restart game logic
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
		onTransitionFinished.addOnce(Play);
		//Do visual Stuff and don't forget to call the onTransitionFinished.dispatch function
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
		if (displayLayer != null){
			displayLayer.visible = false;
			displayLayer.mouseEnabled = false;
		}
		
	}
	
	public inline function Show():Void
	{
		if (displayLayer != null){
			displayLayer.visible = true;
			displayLayer.mouseEnabled = true;
		}
		
	}
	
	function get_onTransitionFinished():Signal0 
	{
		return onTransitionFinished;
	}
	public inline function isDisplayed():Bool
	{
		return displayLayer.visible;
	}
	
	
}