package beardFramework.resources.assets;
import mloader.Loader.LoaderEvent;
import mloader.LoaderQueue;
import mloader.XmlLoader;
import msignal.Signal.Signal1;
import openfl.Assets;
import starling.textures.TextureAtlas;



/**
 * ...
 * @author Ludo
 */
class AssetManager 
{
	
	
	
	private static var instance(get,null):AssetManager;
	//private var loader:
	private var atlases:Map<String, TextureAtlas>;
	private var onComplete:Signal1<LoaderEvent>;
	private var onProgress:Signal1<LoaderEvent>;
	private var onStart:Signal1<LoaderEvent>;
	private var onError:Signal1<LoaderEvent>;
	
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
		
	}
	
		
	public function append(type:AssetType, url:String = "", loaderName:String = null):void
	{
		
		if (loaderName == null)
			loaderName = DEFAULT_LOADER_NAME+getTimer();
		
		if ( !params)				
			params = {};
		
		params.name = loaderName;
	
		
		switch(type)
	{
			case AssetType.IMAGE : _loader.append(new ImageLoader(url, params));
				break;
			case AssetType.XML : _loader.append(new XMLLoader(url, params));
				break;
			case AssetType.DATA : _loader.append(new DataLoader(url, params));
				break;
			case AssetType.SOUND : _loader.append(new MP3Loader(url, params));
				break;
			
		}
		
	}
	
	public function removeLoader(name:String = ""):void
	{
		_loader.remove(_loader.getLoader(name));
	}
	
	public function load(onCompleteCallback:Function = null, onProgressCallback:Function = null, onErrorCallback:Function = null, flush:Boolean = false):void
	{
		
		if (onCompleteCallback != null)
			_onComplete.addOnce(onCompleteCallback);
		if (onProgressCallback!=null)
			_onProgress.add(onProgressCallback);
		if (onErrorCallback!=null)
			_onError.addOnce(onErrorCallback);
		
		_loader.load(flush);
	
	}
	
	private function onLoadingEvent(e:LoaderEvent = null):void
	{
		trace(e.type + ": Data : " + e.data +"\nText : "+ e.text +"\n");			
		switch(e.type){
			
			
			case LoaderEvent.CHILD_OPEN:
				
				break;
			case LoaderEvent.CHILD_COMPLETE:
				break;
			case LoaderEvent.COMPLETE:
				
					_onComplete.dispatch(e);
					_onProgress.removeAll();
					_onError.removeAll();
					_loader.empty(true, true);
					
				break;
			case LoaderEvent.OPEN:
				break;
			case LoaderEvent.CHILD_PROGRESS:
			case LoaderEvent.PROGRESS:
				
					_onProgress.dispatch(e);
					
				break;
			
				//Errors
			case LoaderEvent.HTTP_STATUS:
				if (e.text != HTTP_STATUS_SAFE){
					_onError.dispatch(e);
				}
			break;
	
			case LoaderEvent.HTTP_RESPONSE_STATUS:
			case LoaderEvent.FAIL:
			case LoaderEvent.ERROR:
			case LoaderEvent.IO_ERROR:
			case LoaderEvent.CHILD_FAIL:
			case LoaderEvent.CANCEL:
			case LoaderEvent.CHILD_CANCEL:
					
					_loader.pause();
					_onError.dispatch(e);
					
				break;
		}
		
		
	}
	
	public function getContent(loaderName:String):*{
		
		
		return _loader.getContent(loaderName);
	}
	
	public function empty(disposeChildren:Boolean=true, unloadAllContent:Boolean=true):void
	{
		_loader.empty(disposeChildren, unloadAllContent);
	}
	
	
}
enum AssetType{
		IMAGE;
		XML;
		DATA;
		SOUND;
	}