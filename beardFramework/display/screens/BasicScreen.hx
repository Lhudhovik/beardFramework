package beardFramework.display.screens;
import beardFramework.core.BeardGame;
import beardFramework.core.system.thread.Thread;
import beardFramework.core.system.thread.Thread.ThreadDetail;
import beardFramework.display.cameras.Camera;
import beardFramework.display.core.BeardLayer;
import beardFramework.display.core.BeardSprite;
import beardFramework.gameSystem.entities.GameEntity;
import beardFramework.resources.save.SaveManager;
import beardFramework.resources.save.data.DataCamera;
import beardFramework.resources.save.data.DataEntity;
import beardFramework.resources.save.data.DataGeneric;
import beardFramework.resources.save.data.DataScreen;
import beardFramework.interfaces.IEntityVisual;
import beardFramework.utils.DataUtils;
import haxe.Json;
import msignal.Signal.Signal0;
import openfl.display.Sprite;
import openfl.display.Stage;

/**
 * ...
 * @author Ludo
 */
class BasicScreen 
{
	public var name:String = "BasicScreen";
	public var onReady(get, null):Signal0;
	public var onTransitionFinished(get, null):Signal0;
	public var dataPath:String;
	private var displayLayer:BeardLayer;
	private var defaultCamera:Camera;
	//private var id:String;
	private var loadingProgression(get, null):Float;
	private var savedData:DataScreen;
	
	public function new() 
	{
		onReady = new Signal0();
		onTransitionFinished = new Signal0();
		displayLayer = BeardGame.Get().GetContentLayer();
		defaultCamera = BeardGame.Get().cameras[Camera.DEFAULT];
		name = Type.getClassName(Type.getClass(this));
		
		
	}
	
	public inline function AddEntity(entity:GameEntity):Void
	{
		
		if (BeardGame.Get().entities.indexOf(entity) == -1)
		{
			BeardGame.Get().entities.push(entity);
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
		onReady.dispatch();
	}
	
		
	public function ParseScreenData(threadDetail:ThreadDetail<DataScreen>):Bool
	{
		if (threadDetail != null && threadDetail.parameter != null){
			
			trace(threadDetail);
			trace(threadDetail.parameter);
			trace(threadDetail.parameter.cameras);
			
			Thread.MarkDate();
			
			if (threadDetail.progression == 0)
			{
				savedData = SaveManager.Get().GetScreenSavedData(this.name);
				
				trace(savedData);
				//trace(savedData);
			}
			
			if (threadDetail.progression < 0.2)
			{
				
				
				
				var cameraData:DataCamera;
				var savedCameras:Map<String, DataCamera> = (savedData != null ? DataUtils.DataArrayToMap(savedData.cameras) : null);
				
				for (i in threadDetail.marker...threadDetail.parameter.cameras.length)
				{
					cameraData = threadDetail.parameter.cameras[i];
					
					if (BeardGame.Get().cameras[cameraData.name] == null)
					{
						BeardGame.Get().AddCamera(new Camera(cameraData.name));
					}
					
					if (savedCameras != null && savedCameras[cameraData.name] != null){
						trace("data saved");
						BeardGame.Get().cameras[cameraData.name].ParseData(savedCameras[cameraData.name]);
					}
					else 
						BeardGame.Get().cameras[cameraData.name].ParseData(cameraData);
						
					threadDetail.progression += (0.2 / threadDetail.parameter.cameras.length);
					threadDetail.marker++;
					
					if (Thread.CheckTimeExpiration(threadDetail.allowedTime)) return false;
						
				}
				
				threadDetail.progression = 0.2;
				threadDetail.marker = 0;
				
			}
			
			
			var entityData:DataEntity;
			var savedEntities:Map<String, DataEntity> = (savedData != null? DataUtils.DataArrayToMap(savedData.entitiesData) : null);
			for (i in threadDetail.marker...threadDetail.parameter.entitiesData.length)
			{
				
				entityData = threadDetail.parameter.entitiesData[i];
				
				var entity:GameEntity = Type.createInstance(Type.resolveClass(entityData.type),[]); //to be handled by Pool
				
				if (savedEntities != null && savedEntities[entityData.name] != null){
					trace("data saved enitys");
					entity.ParseData(savedEntities[entityData.name]);
				}
				else 
					entity.ParseData(entityData);
					
				AddEntity(entity);
				
				threadDetail.marker++;
				threadDetail.progression += (0.8 / threadDetail.parameter.entitiesData.length);
				if (Thread.CheckTimeExpiration(threadDetail.allowedTime)) return false;
			}
		}
		
		
		savedData = null;
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
		
	public function StartTransitionIn():Void
	{
		Show();
		onTransitionFinished.addOnce(Play);
		TransitionIn();
		
	}
	
	private function TransitionIn():Void
	{
		onTransitionFinished.dispatch();
		//Do visual Stuff and don't forget to call the onTransitionFinished.dispatch function
	}
	
	public function StartTransitionOut():Void
	{
		onTransitionFinished.addOnce(Hide);
		TransitionOut();
	}
	private function TransitionOut():Void
	{
		onTransitionFinished.dispatch();
		//Do visual Stuff and don't forget to call the onTransitionFinished.dispatch function
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
	
	public function ToData(complete:Bool=false):DataScreen
	{
		var data:DataScreen =
		{
			name : this.name,
			type : Type.getClassName(Type.getClass(this)),
			cameras : [for (camera in BeardGame.Get().cameras) camera.ToData() ],
			entitiesData : [for(entity in BeardGame.Get().entities) if(entity.isLocal && (complete || entity.requiredSave) ) entity.ToData()]
			
		}
		
		return data;
	}
	
}






