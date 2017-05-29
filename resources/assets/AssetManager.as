package beardFramework.resources.assets 
{
	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.DataLoader;
	import com.greensock.loading.ImageLoader;
	import com.greensock.loading.LoaderMax;
	import com.greensock.loading.MP3Loader;
	import com.greensock.loading.XMLLoader;
	import com.greensock.loading.core.LoaderCore;
	import com.greensock.loading.data.ImageLoaderVars;
	import com.greensock.loading.data.LoaderMaxVars;
	import com.greensock.loading.data.XMLLoaderVars;
	import flash.events.HTTPStatusEvent;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	import org.osflash.signals.Signal;
	import starling.textures.TextureAtlas;
	/**
	 * ...
	 * @author Ludovic Geraert
	 */
	public class AssetManager 
	{
		static public const LOADER_TYPE_IMAGE:uint 	= 0;
		static public const LOADER_TYPE_XML:uint 	= 1;
		static public const LOADER_TYPE_DATA:uint 	= 2;
		static public const LOADER_TYPE_SOUND:uint 	= 3;
		
		private const HTTP_STATUS_SAFE:String = "0";
		private const MAIN_LOADER_NAME:String = "AssetManagerMainLoader";
		public const DEFAULT_LOADER_NAME:String = "DefaultName";
	
		
		static private var _instance:AssetManager;
				
		private var _loader:LoaderMax;
		private var _atlases:Dictionary;
		private var _onComplete:Signal;
		private var _onProgress:Signal;
		private var _onStart:Signal;
		private var _onError:Signal;
		
	
		
		
		public function AssetManager(singleton:AssetManagerSingleton) 
		{
			
			
		}
		
		static public function getInstance():AssetManager
		{
			if (!_instance){
				_instance = new AssetManager(new AssetManagerSingleton());
				_instance.init();
				
			}
			return _instance;
		}
		
		private function init():void
		{
			var loaderParams:LoaderMaxVars = new LoaderMaxVars();
			loaderParams.name(MAIN_LOADER_NAME);
			loaderParams.onChildOpen(onLoadingEvent);
			loaderParams.onChildComplete(onLoadingEvent);
			loaderParams.onChildFail(onLoadingEvent);
			loaderParams.onChildProgress(onLoadingEvent);
			loaderParams.onComplete(onLoadingEvent);
			loaderParams.onCancel(onLoadingEvent);
			loaderParams.onError(onLoadingEvent);
			loaderParams.onFail(onLoadingEvent);
			loaderParams.onChildCancel(onLoadingEvent);
			loaderParams.onScriptAccessDenied(onLoadingEvent);
			loaderParams.onHTTPStatus(onLoadingEvent);
			loaderParams.onIOError(onLoadingEvent);
			loaderParams.onOpen(onLoadingEvent);
			loaderParams.onProgress(onLoadingEvent);
			
			
			_onComplete = new Signal(LoaderEvent);
			_onProgress = new Signal(LoaderEvent);
			_onError = new Signal(LoaderEvent);
			_onStart = new Signal(LoaderEvent);
		
			
			_loader = new LoaderMax(loaderParams);
			_atlases = new Dictionary();
		}
		
		
		public function append(type:uint, url:String = "", loaderName:String = null, params:Object = null):void
		{
			
			if (loaderName == null)
				loaderName = DEFAULT_LOADER_NAME+getTimer();
			
			if ( !params)				
				params = {};
			
			params.name = loaderName;
		
			
			switch(type)
		{
				case LOADER_TYPE_IMAGE : _loader.append(new ImageLoader(url,params));
					break;
				case LOADER_TYPE_XML : _loader.append(new XMLLoader(url, params));
					break;
				case LOADER_TYPE_DATA : _loader.append(new DataLoader(url, params));
					break;
				case LOADER_TYPE_SOUND : _loader.append(new MP3Loader(url, params));
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

}
internal class AssetManagerSingleton{
	
}
