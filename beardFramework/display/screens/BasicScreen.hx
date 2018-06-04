package beardFramework.display.screens;
import beardFramework.core.BeardGame;
import beardFramework.updateProcess.thread.ParamThreadDetail;
import beardFramework.updateProcess.thread.ThreadDetail;
import beardFramework.display.cameras.Camera;
import beardFramework.display.core.BeardLayer;
import beardFramework.display.ui.UIManager;
import beardFramework.gameSystem.entities.GameEntity;
import beardFramework.resources.save.SaveManager;
import beardFramework.resources.save.data.DataCamera;
import beardFramework.resources.save.data.DataEntity;
import beardFramework.resources.save.data.DataGeneric;
import beardFramework.resources.save.data.DataScreen;
import beardFramework.interfaces.IEntityVisual;
import beardFramework.resources.save.data.Test;
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
	
	public static var globalEntities:Map<String, GameEntity>;
	
	public var name:String = "BasicScreen";
	public var onReady(get, null):Signal0;
	public var onTransitionFinished(get, null):Signal0;
	public var dataPath:String;
	public var entities:Array<GameEntity>;
	private var displayLayer:BeardLayer;
	private var defaultCamera:Camera;
	private var loadingProgression(get, null):Float;
	private var savedData:AbstractDataScreen;
	public var ready:Bool;
	

	
	public function new() 
	{
		onReady = new Signal0();
		onTransitionFinished = new Signal0();
		displayLayer = BeardGame.Get().GetContentLayer();
		defaultCamera = BeardGame.Get().cameras[Camera.DEFAULT];
		name = Type.getClassName(Type.getClass(this));
		entities = new Array<GameEntity>();
		ready = false;
		if (globalEntities == null) globalEntities = new Map<String,GameEntity>();
	}
	
	public inline function AddEntity(entity:GameEntity, isLocal:Bool = true):Void
	{
		
		if (entities.indexOf(entity) == -1)
		{
			entity.isLocal = isLocal;
			entities.push(entity);
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
		savedData = null;
		ready = true;
		onReady.dispatch();
	}
	
	public function ParseScreenData(td:ParamThreadDetail<AbstractDataScreen>):Bool
	{
		if (td != null && td.parameter != null){
			
			var screenData:AbstractDataScreen = td.parameter;
			var elementsCount:Int = screenData.entitiesData.length + screenData.cameras.length;
			
			
			if (td.progression == 0)
			{
				savedData = SaveManager.Get().GetSavedGameData(this.name, savedData);
				screenData.cameras.reverse();
				screenData.entitiesData.reverse();
			}
			
			if (td.progression < (screenData.cameras.length/elementsCount))
			{
				
				var cameraData:DataCamera;
				var savedCameras:Map<String, DataCamera> = (savedData != null ? DataUtils.DataArrayToMap(savedData.cameras) : null);
				
				while (	screenData.cameras.length > 0)
				{
					
					cameraData = screenData.cameras.pop();
					
					
					if (BeardGame.Get().cameras[cameraData.name] == null)
					{
						BeardGame.Get().AddCamera(new Camera(cameraData.name));
					}
					
					if (savedCameras != null && savedCameras[cameraData.name] != null){
						
						BeardGame.Get().cameras[cameraData.name].ParseData(savedCameras[cameraData.name]);
					}
					else 
						BeardGame.Get().cameras[cameraData.name].ParseData(cameraData);
									
					cameraData = null;
						
					td.progression += ((screenData.cameras.length/elementsCount) / screenData.cameras.length);
						
					if (td.TimeExpired()) return false;
					
					
				}
				
				td.progression = screenData.cameras.length/elementsCount;
				
				savedCameras = null;
			}
			
			
			var entityData:DataEntity;
			var savedEntities:Map<String, DataEntity> = (savedData != null? DataUtils.DataArrayToMap(savedData.entitiesData) : null);
			
			while (screenData.entitiesData.length > 0)
			{
				entityData = screenData.entitiesData.pop();
				
				var entity:GameEntity = Type.createInstance(Type.resolveClass(entityData.type),[]); //to be handled by Pool
				
				if (savedEntities != null && savedEntities[entityData.name] != null){
					//trace("data saved enitys");
					entity.ParseData(savedEntities[entityData.name]);
				}
				else 
					entity.ParseData(entityData);
					
				AddEntity(entity);
							
				entityData = null;
				
				td.progression += ((screenData.entitiesData.length / elementsCount)  / screenData.entitiesData.length);
				
				if (td.TimeExpired()) return false;
				
			}
			
			savedEntities = null;
	
			
		}
		
		Init();
					
		return true;		
	
	}
	
	public function Play():Void
	{
		//start/restart game logic
		//ShowUI
	}
		
	public function Clear(td:ThreadDetail):Bool
	{
		var entity:GameEntity;
		if (td.progression == 0){
			td.length = entities.length;
			entities.reverse();
		}
			
		while(entities.length > 0){
			
			entity = entities.pop();
			
			if (entity.isLocal)
			{
				entity.Dispose();
				
			}
			else{
				globalEntities[entity.name] = entity;
				for (component in entity.GetComponents())
					if (Std.is(component, IEntityVisual))
						cast(component, IEntityVisual).UnRegister();
			}
			
			entity = null;
			
			td.progression += 1 / td.length;
			
			if (td.TimeExpired()) return false;
		}
				
		//trace("fully cleaned");
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
		}
		
	}
	
	public inline function Show():Void
	{
		if (displayLayer != null){
			displayLayer.visible = true;
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
			entitiesData : [for(entity in BeardGame.Get().entities) if(entity.isLocal && (complete || entity.requiredSave) ) entity.ToData()],
			UITemplates:[]
		}
		
		return data;
	}
	
	public function Update():Void
	{
		
	}
}






