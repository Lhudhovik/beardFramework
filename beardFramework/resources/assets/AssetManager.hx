package beardFramework.resources.assets;
import mloader.HttpLoader;
import mloader.ImageLoader;
import mloader.Loader.LoaderEvent;
import mloader.Loader.LoaderEventType;
import mloader.Loader.LoaderErrorType;
import mloader.Loader.Loader;
import mloader.LoaderQueue;
import mloader.StringLoader;
import mloader.XmlLoader;
import msignal.Signal.Signal0;
import msignal.Signal.Signal1;
import openfl.Assets;
import openfl.display.BitmapData;

/**
 * ...
 * @author Ludo
 */
class AssetManager 
{
	
	
	
	private static var instance(get, null):AssetManager;
	
	private var DEFAULT_LOADER_NAME(null, never):String = "DefaultName";
	
	private var loaderQueue:LoaderQueue;
	private var loaders:Map<String, Loader<Dynamic>>;
	private var atlases:Map<String, Atlas>;
	private var onComplete:Signal0;
	private var onProgress:Signal1<Float>;
	private var onCancel:Signal0;
	private var onStart:Signal0;
	private var onError:Signal1<LoaderErrorType>;
	private var requestedAtlasQueue:Array<String>;
	
	public function new() 
	{
		
	}
	
	public static function get_instance():AssetManager
	{
		if (instance == null)
		{
			instance = new AssetManager();
			instance.Init();
		}
		
		return instance;
	}
	
	private function Init():Void
	{
		
		loaders = new Map<String, Loader<Dynamic>>();
		atlases = new Map<String, Atlas>();
		
		requestedAtlasQueue = new Array<String>();
		
		onComplete = new Signal0();
		onProgress = new Signal1(Float);
		onStart = new Signal0();
		onError = new Signal1(LoaderErrorType);
		onCancel = new Signal0();
		
		loaderQueue = new LoaderQueue();
		loaderQueue.ignoreFailures = false;
		loaderQueue.loaded.add(OnLoadingEvent);
		
		
	}
		
	public function Append(type:AssetType, url:String, loaderName:String, onCompleteCallback:LoaderEvent<Dynamic>->Void = null, onProgressCallback:LoaderEvent<Dynamic>->Void = null, onErrorCallback:LoaderEvent<Dynamic>->Void = null, onCancelCallback:LoaderEvent<Dynamic>->Void = null):Void
	{
	
		if (loaderName == null)
			loaderName = DEFAULT_LOADER_NAME+ Date.now().getTime();
		
		if (loaders[loaderName] != null){
			throw "Name already existing";
			return;
		}
			
		switch(type)
		{
			case AssetType.IMAGE : 
				
				loaders[loaderName] = new ImageLoader(url);
				
			
			case AssetType.XML : 
				
				loaders[loaderName] = new XmlLoader(url);
				
				
			case AssetType.DATA | AssetType.SOUND : 	
				
				loaders[loaderName] = new StringLoader(url);
				
			case AssetType.ATLAS_PNG | AssetType.ATLAS_JPG:
				if (requestedAtlasQueue.indexOf(loaderName) == -1){
					requestedAtlasQueue.push(loaderName);
					Append(AssetType.XML, '${url}/${loaderName}.xml', '${loaderName}_xml', onCompleteCallback, onProgressCallback, onErrorCallback, onCancelCallback);
					Append(AssetType.IMAGE, '${url}/${loaderName}${ type == AssetType.ATLAS_PNG ? ".png" : ".jpg"}', '${loaderName}_image', onCompleteCallback, onProgressCallback, onErrorCallback, onCancelCallback);
					
				}
				return;
		}
		
		
		if (onCompleteCallback != null)
			loaders[loaderName].loaded.addOnce(onCompleteCallback).forType(LoaderEventType.Complete);
		if (onProgressCallback!=null)
			loaders[loaderName].loaded.addOnce(onProgressCallback).forType(LoaderEventType.Progress);
		//if (onErrorCallback!=null)
			//loaders[loaderName].loaded.addOnce(onErrorCallback).forType(LoaderEventType.Fail(LoaderErrorType.Data));
		//if (onCancelCallback!=null)
			//loaders[loaderName].loaded.addOnce(onCancelCallback).forType(LoaderEventType.Cancel);
		//trace(loaderName);
		//trace(url);
		
		loaderQueue.add(loaders[loaderName]);
		
		
	}
	
	public function RemoveLoader(name:String = ""):Void
	{
		loaders[name].cancel();
		loaders[name] = null;
		loaders.remove(name);
		
	}
	
	public function Load(onCompleteCallback:Void->Void = null, onProgressCallback:Float->Void = null, onErrorCallback:LoaderErrorType->Void = null, onCancelCallback:Void->Void = null):Void
	{
		
		if (onCompleteCallback != null)
			onComplete.addOnce(onCompleteCallback);
		if (onProgressCallback!=null)
			onProgress.add(onProgressCallback);
		if (onErrorCallback!=null)
			onError.addOnce(onErrorCallback);
		if (onCancelCallback!=null)
			onCancel.addOnce(onCancelCallback);
		loaderQueue.load();
	
	}
	
	private function OnLoadingEvent(e:LoaderEvent<Dynamic> = null):Void
	{
		//trace(e.type.getName());
		switch(e.type){
			
			case LoaderEventType.Start:
				onStart.dispatch();
			case LoaderEventType.Complete:
				var i:Int=0;
				for (requestedAtlas in requestedAtlasQueue){
					CreateAtlas(requestedAtlas);
					requestedAtlasQueue[i++] = null;
				}
				requestedAtlasQueue = [];
				
				onComplete.dispatch();
			case LoaderEventType.Progress:
				onProgress.dispatch(get_progress());
			case LoaderEventType.Cancel:
				while(requestedAtlasQueue.length>0) requestedAtlasQueue.pop();
				onCancel.dispatch();	
				//Errors
			case LoaderEventType.Fail(e):
				while(requestedAtlasQueue.length>0) requestedAtlasQueue.pop();
				onError.dispatch(e);
		}
		
		
	}
		
	public function get_loading():Bool return loaderQueue.loading;
	
	public function get_progress():Float return loaderQueue.progress;
	
	public function GetContent(loaderName:String):Dynamic
	{
		
		var content : Dynamic = null;
		if(loaders[loaderName] != null && loaders[loaderName].content != null)
		content =  loaders[loaderName].content;
		
		return content;
	}
	
	public inline function HasContent(loaderName:String):Bool
	{
		return (loaders[loaderName] != null && loaders[loaderName].content != null);
	}
	
	public function CreateAtlas(atlasName:String):Void
	{
		
		if (atlases[atlasName] == null){
			atlases[atlasName] = new Atlas(GetContent('${atlasName}_image'), GetContent('${atlasName}_xml'));
		}else throw "Atlas already exists";
		
	}
	
	public function GetAtlas(atlasName:String):Atlas
	{
		return atlases[atlasName] != null ? atlases[atlasName] : null;
	}
	
	public function GetBitmapData(textureName:String, atlasName:String):BitmapData
	{
		return atlases[atlasName] != null ? atlases[atlasName].GetBitmapData(textureName) : null;
	}
	
	public function ClearAtlas(atlasName:String):Void
	{
		if ( atlases[atlasName] != null ){
			atlases[atlasName].Dispose();
			atlases[atlasName] = null;
			
		}
	}
	
	public function cancel():Void
	{
		loaderQueue.cancel();
	}
	
	
}
enum AssetType{
		IMAGE;
		XML;
		DATA;
		SOUND;
		ATLAS_PNG;
		ATLAS_JPG;
	}