package beardFramework.graphics.screens;
import beardFramework.core.BeardGame;
import beardFramework.input.InputManager;
import beardFramework.input.InputType;
import beardFramework.updateProcess.UpdateProcess;
import beardFramework.updateProcess.Wait;
import beardFramework.updateProcess.sequence.MultipleStep;
import beardFramework.updateProcess.sequence.Sequence;
import beardFramework.updateProcess.thread.ChainThread;
import beardFramework.updateProcess.thread.VoidThreadDetail;
import lime.app.Application;
import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.Tile;
import openfl.display.Tilemap;
import openfl.display.Tileset;
import sys.FileSystem;

/**
 * ...
 * @author Ludo
 */
class SplashScreen extends Sequence
{

	var alphaDuration:Int = 4;
	var content:Bitmap;
	var step:MultipleStep<String>;
	var alphaThread:ChainThread;
	var decreaseAlphaTD:VoidThreadDetail;
	var increasAlphaTD:VoidThreadDetail;
	
	public function new(series:Array<String>) 
	{
		super("splashScreens", 0);
		step = new MultipleStep<String>("splashScreensStep", ShowNext, series);
		alphaThread = new ChainThread("alphaThread", 0);
		increasAlphaTD = new VoidThreadDetail(null);
		decreaseAlphaTD = new VoidThreadDetail(null);
		//InputManager.Get().BindToInput("a", InputType.KEY_PRESS, Skip);
		AddStep(step);
		
		
		//var tileset:Tileset = new Tileset(AssetManager.Get().GetAtlas("menuHD").atlasBitmapData);
	//
		//var plop:Tile = new Tile(tileset.addRect( new Rectangle(0, 0, 2048, 2048)));
		////var plop:BeardTile = new BeardTile("menuHD", tileset.addRect( new Rectangle(1616, 923, 81, 118)));
		//var tilemap:Tilemap = new Tilemap(Math.round(displayLayer.width), Math.round( displayLayer.height), tileset);
		////var tilemap:BeardTileMap = new BeardTileMap(Math.round(displayLayer.width), Math.round( displayLayer.height), tileset);
		//
		//tilemap.addTile(plop);
		//
		//displayLayer.addChild(tilemap);
		
	}

	public function Skip(value:Float):Void
	{
		if (content != null && content.bitmapData != null){
			//BeardGame.Get().removeChild(content);
			content.bitmapData.dispose();
		}
		alphaThread.Clear();
		SetCondition("splashScreensStep", true);
		SetCondition("LoadSettings", true);
	}
		
	public function ShowNext(screen:String):Void
	{
		if (content != null && content.bitmapData != null){
			//BeardGame.Get().removeChild(content);
			content.bitmapData.dispose();
			alphaThread.Clear();
		}
		
		content = new Bitmap(Assets.getBitmapData(BeardGame.Get().SPLASHSCREENS_PATH + screen ));
		content.width = BeardGame.Get().window.width;
		content.height = BeardGame.Get().window.height;
		content.scaleX = content.scaleY = (content.scaleX > content.scaleY ? content.scaleY : content.scaleX);
		content.x = (BeardGame.Get().window.width - content.width) * 0.5;
		content.y = (BeardGame.Get().window.height - content.height) * 0.5;
		content.alpha = 0;
	
		//BeardGame.Get().addChild(content);
		SetCondition("splashScreensStep", false);
		SetCondition("LoadSettings", false);
		Display();
		
	}
	
	//will need to be replaced by a tween or animation
	private function Display():Void
	{
		increasAlphaTD.action = IncreaseAlpha;
		alphaThread.Add(increasAlphaTD);
		alphaThread.Start();
	}
	
	private function Hide():Void
	{	
		decreaseAlphaTD.action = DecreaseAlpha;
		alphaThread.Add(decreaseAlphaTD);
	}
	
	private function IncreaseAlpha():Bool
	{
		
		content.alpha += 1 / (BeardGame.Get().GetFPS()* alphaDuration);
	
		
		if (content.alpha == 1)
			Hide();
		return content.alpha >= 1;	
		
		
	}
	
	private function DecreaseAlpha():Bool
	{
		
		content.alpha -= 1 / (BeardGame.Get().GetFPS() * alphaDuration);
		
		if (content.alpha <= 0){
			
			SetCondition("splashScreensStep", true);
			SetCondition("LoadSettings", true);
			
		}
			
		return content.alpha <= 0;
		
	}
	
	override public function Clear():Void 
	{
		super.Clear();
		//InputManager.Get().UnbindFromInput("a", InputType.KEY_PRESS, Skip);
	}
	
	
}