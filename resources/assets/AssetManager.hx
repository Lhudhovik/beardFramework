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
import starling.textures.TextureAtlas;



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
	private var atlases:Map<String, TextureAtlas>;
	private var onComplete:Signal0;
	private var onProgress:Signal1<Float>;
	private var onCancel:Signal0;
	private var onStart:Signal0;
	private var onError:Signal1<LoaderErrorType>;
	
	
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
	
	private function Init():Void{
		
		loaders = new Map<String, Loader<Dynamic>>();
		atlases = new Map<String, TextureAtlas>();
		
		onComplete = new Signal0();
		onProgress = new Signal1(Float);
		onStart = new Signal0();
		onError = new Signal1(LoaderErrorType);
		onCancel = new Signal0();
		
		loaderQueue = new LoaderQueue();
		loaderQueue.ignoreFailures = false;
		loaderQueue.loaded.add(onLoadingEvent);
		
		
	}
	
	
	 public function append(type:AssetType, url:String, loaderName:String, onCompleteCallback:LoaderEvent<Dynamic>->Void = null, onProgressCallback:LoaderEvent<Dynamic>->Void = null, onErrorCallback:LoaderEvent<Dynamic>->Void = null, onCancelCallback:LoaderEvent<Dynamic>->Void = null):Void
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
				
				
			case AssetType.DATA : 	
				
				loaders[loaderName] = new StringLoader(url);
				
			case AssetType.SOUND :
				//loaders[loaderName] = new String(url);
				
			
		}
		
		if (onCompleteCallback != null)
			loaders[loaderName].loaded.addOnce(onCompleteCallback).forType(LoaderEventType.Complete);
		if (onProgressCallback!=null)
			loaders[loaderName].loaded.addOnce(onProgressCallback).forType(LoaderEventType.Progress);
		//if (onErrorCallback!=null)
			//loaders[loaderName].loaded.addOnce(onErrorCallback).forType(LoaderEventType.Fail(LoaderErrorType.Data));
		if (onCancelCallback!=null)
			loaders[loaderName].loaded.addOnce(onCancelCallback).forType(LoaderEventType.Cancel);
		
		
		loaderQueue.add(loaders[loaderName]);
		
		
	}
	
	public function removeLoader(name:String = ""):Void
	{
		loaders[name].cancel();
		loaders[name] = null;
		loaders.remove(name);
		
	}
	
	public function load(onCompleteCallback:Void->Void = null, onProgressCallback:Float->Void = null, onErrorCallback:LoaderErrorType->Void = null, onCancelCallback:Void->Void = null):Void
	{
		
		if (onCompleteCallback != null)
			onComplete.addOnce(onCompleteCallback);
		if (onProgressCallback!=null)
			onProgress.add(onProgressCallback);
		if (onErrorCallback!=null)
			onError.addOnce(onErrorCallback);
		if (onCancelCallback!=null)
			onCancel.addOnce(onCancelCallback);
		trace("jusque là...");
		loaderQueue.load();
	
	}
	
	private function onLoadingEvent(e:LoaderEvent<Dynamic> = null):Void
	{
		
		switch(e.type){
			
			case LoaderEventType.Start:
				onStart.dispatch();
			case LoaderEventType.Complete:
				onComplete.dispatch();
			case LoaderEventType.Progress:
				onProgress.dispatch(get_progress());
			case LoaderEventType.Cancel:
				onCancel.dispatch();	
				//Errors
			case LoaderEventType.Fail(e):
				onError.dispatch(e);
		}
		
		
	}
	
	
	public function get_loading():Bool return loaderQueue.loading;
	
	public function get_progress():Float return (loaderQueue.progress + loaderQueue.content[0].progress) / 2;
	
	public function getContent(loaderName:String):Dynamic{
		
		var content : Dynamic = null;
		if(loaders[loaderName] != null && loaders[loaderName].content != null)
		content =  loaders[loaderName].content;
		
		return content;
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
	}