package beardFramework.resources.assets;
import beardFramework.core.BeardGame;
import beardFramework.graphics.core.BatchedVisual;
import beardFramework.graphics.rendering.batches.BatchRenderingData;
import beardFramework.graphics.rendering.shaders.Shader;
import beardFramework.resources.assets.Atlas;
import beardFramework.graphics.text.FontFormat;
import beardFramework.utils.data.Crypto;
import beardFramework.utils.graphics.TextureU;
import haxe.Utf8;
import lime.graphics.Image;
import lime.graphics.opengl.GL;
import lime.utils.Assets;
import openfl.display.BitmapData;
import sys.io.File;
//import extension.harfbuzz.TextScript;
import haxe.ds.Vector;
import haxe.io.Float32Array;
import haxe.io.UInt8Array;
import lime.text.Font;
import lime.graphics.opengl.GLTexture;
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


using beardFramework.utils.SysPreciseTime;
/**
 * ...
 * @author Ludo
 */
class AssetManager 
{
	
	private static var instance(default, null):AssetManager;
	
	private var DEFAULT_LOADER_NAME(null, never):String = "DefaultName";
	public var FONT_ATLAS_NAME(default, never):String = "FontAtlas";
	
	private var FREETEXTUREUNIT:Int = 0;
	private var loaderQueue:LoaderQueue;
	private var loaders:Map<String, Loader<Dynamic>>;
	private var atlases:Map<String, Atlas>;
	private var textures:Map<String, Texture>;
	private var fonts:Map<String, Font>;
	private var onComplete:Signal0;
	private var onProgress:Signal1<Float>;
	private var onCancel:Signal0;
	private var onStart:Signal0;
	private var onError:Signal1<LoaderErrorType>;
	private var requestedAtlasQueue:Array<String>;
	private var requestedTexturesQueue:Array<String>;
	private var requestedNativeShaderQueue:Array<String>;
	private var batchTemplates:Map<String, BatchRenderingData>;
			
	public function new() 
	{
		
	}
	
	public static inline function Get():AssetManager
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
		fonts = new Map<String, Font>();
		textures = new Map<String,Texture>();
		requestedAtlasQueue = new Array<String>();
		requestedTexturesQueue = new Array<String>();
		requestedNativeShaderQueue = new Array<String>();
		batchTemplates = new Map();
				
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
			loaderName = DEFAULT_LOADER_NAME+ Sys.preciseTime();
		
		if (loaders[loaderName] != null){
			throw "Name already existing";
			return;
		}
			
		switch(type)
		{
			case AssetType.IMAGE: 
				
				loaders[loaderName] = new ImageLoader(url);
			case AssetType.TEXTURE :
				loaders[loaderName] = new ImageLoader(url);
				requestedTexturesQueue.push(loaderName);		
			
			case AssetType.XML : 
				
				loaders[loaderName] = new XmlLoader(url);
			
			case AssetType.SHADER :
				requestedNativeShaderQueue.push(loaderName);
				loaders[loaderName] = new StringLoader(url);
				
			case AssetType.DATA | AssetType.SOUND : 	
						loaders[loaderName] = new StringLoader(url);
			case AssetType.FONT_TTF | AssetType.FONT_OTF:
				return;
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
			
		//trace(onCompleteCallback);
		//trace(loaderQueue.size);
		loaderQueue.load();
	
	}
	
	private function OnLoadingEvent(e:LoaderEvent<Dynamic> = null):Void
	{
		//trace(e.type);
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
					
				for (requestedTexture in requestedTexturesQueue)
				{
					if (loaders[requestedTexture] != null && loaders[requestedTexture].content != null){
						AddTextureFromImage(	requestedTexture, cast(loaders[requestedTexture].content, BitmapData).image);		
					}
				}
				requestedTexturesQueue = [];
				
				for (requestedNativeShader in requestedNativeShaderQueue)
				{
					if (loaders[requestedNativeShader] != null && loaders[requestedNativeShader].content != null){
						#if debug
							Shader.nativeShaders[requestedNativeShader].src =  cast loaders[requestedNativeShader].content;
						#else
							Shader.nativeShaders[requestedNativeShader].src =  Crypto.DecodedData( cast loaders[requestedNativeShader].content);	
						#end
					}
				}
				requestedNativeShaderQueue = [];
				
				
				
				onProgress.removeAll();
				onCancel.removeAll();
				onError.removeAll();
				
				onComplete.dispatch();
				
				
			case LoaderEventType.Progress:
				onProgress.dispatch(get_progress());
			case LoaderEventType.Cancel:
				while(requestedAtlasQueue.length>0) requestedAtlasQueue.pop();
				
				onProgress.removeAll();
				onComplete.removeAll();
				onError.removeAll();
				
				onCancel.dispatch();	
				
				//Errors
			case LoaderEventType.Fail(e):
				while (requestedAtlasQueue.length > 0) requestedAtlasQueue.pop();
				
				onProgress.removeAll();
				onCancel.removeAll();
				onComplete.removeAll();
				
				onError.dispatch(e);
		}
		
		
	}
		
	public function get_loading():Bool
	{
		return loaderQueue.loading;
	}
	
	public function get_progress():Float
	{
		return loaderQueue.progress;
	}
	
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
			atlases[atlasName] = new Atlas(atlasName, GetContent('${atlasName}_image'), GetContent('${atlasName}_xml'));
		}else throw "Atlas already exists";
		
	}
	
	public inline function GetAtlas(atlasName:String):Atlas
	{
		return atlases[atlasName] != null ? atlases[atlasName] : null;
	}
	
	public inline function GetFont(fontName:String):Font
	{
		return fonts[fontName] != null ? fonts[fontName] : null;
	}
	
	public function LoadFont(fontName:String, format:FontFormat, size:Int = 72/*, script:TextScript = TextScript.ScriptLatin, language:String = ""*/, atlasName:String = null):Void
	{
		//trace("font loading");
		var fileExtension:String = "";
		
		switch (format)
		{
			case FontFormat.TTF : fileExtension = ".ttf";
			case FontFormat.OTF : fileExtension = ".otf";
			
		}
		
		
		if(fonts[fontName] == null) fonts[fontName] = Font.fromFile(BeardGame.Get().FONT_PATH + fontName + fileExtension);
		
		//trace(fontName);
		//trace(fonts[fontName]);
		var fontAtlas:FontAtlas;
		
		if (atlasName == null || atlasName == ""){
			
			if (atlases[FONT_ATLAS_NAME] == null)	atlases[FONT_ATLAS_NAME] = fontAtlas = new FontAtlas(FONT_ATLAS_NAME);
			else fontAtlas = cast(atlases[FONT_ATLAS_NAME],FontAtlas);
			
		}
		else{
			
			if (atlases[atlasName] == null) atlases[atlasName] = new FontAtlas(atlasName);
			fontAtlas = cast( atlases[atlasName], FontAtlas);
		}
		
		
		
		if (!fontAtlas.ContainsFont(fontName,size)) fontAtlas.AddFont(fonts[fontName] , fontName, size);	
		
	}
	
	public inline function GetSubTextureData(textureName:String, atlasName:String):SubTextureData
	{
		return (atlases[atlasName] != null ? atlases[atlasName].GetSubTextureData(textureName) : null);
	}
	
	public inline function GetFontGlyphTextureData(font:String, char:String, size:Int = 72, atlasName:String = null):SubTextureData
	{
		
		if (atlasName == null) atlasName = FONT_ATLAS_NAME;
		return cast(atlases[atlasName], FontAtlas).GetGlyphData(font,char,size);
	}
	
	public inline function GetFontGlyphTextureName(font:String, char:String, size:Int = 72, atlasName:String = null):String
	{
		
		if (atlasName == null) atlasName = FONT_ATLAS_NAME;
		return cast(atlases[atlasName], FontAtlas).GetGlyphDataName(font,char,size);
	}
	
	public function ClearAtlas(atlasName:String):Void
	{
		if ( atlases[atlasName] != null ){
			atlases[atlasName].Dispose();
			atlases[atlasName] = null;
			
		}
	}
	
	public inline function AddTextureFromImage(name:String, texture:Image, fixedIndex:Int=-1):GLTexture
	{
		trace(name);
		trace(texture);
		
		var glTexture:GLTexture;
		
		if (textures[name] == null){
		
			glTexture = TextureU.GetTexture(texture);
		
			textures[name] = {glTexture:glTexture, fixedIndex:fixedIndex, width:texture.buffer.width, height:texture.buffer.height};
			
		}
		else glTexture = textures[name].glTexture;
		
		return glTexture;
	}

	
	public inline function RemoveTexture(name:String, destroy:Bool = false):Void
	{
		if (textures[name] != null) 
		{
			if (destroy) GL.deleteTexture(textures[name].glTexture);
			textures[name] = null;
		}
	}
	
	public inline function GetTexture(name:String):Texture
	{
		return textures[name];
	}
	
	public inline function AddTemplate(templateData:BatchRenderingData):Void
	{
		if (templateData != null)
		{
			batchTemplates[templateData.name] = templateData;
		}
	}
	
	public inline function GetTemplate(name:String):BatchRenderingData
	{
		return batchTemplates[name];
	}
	
	public function GetFreeTextureUnit():Int
	{
		return FREETEXTUREUNIT;
	}
	
	public inline function AllocateFreeTextureIndex():Int
	{
		
		return FREETEXTUREUNIT++;
	}
	
	
	public function Cancel():Void
	{
		loaderQueue.cancel();
	}
	
	
}
enum AssetType{
		IMAGE;
		TEXTURE;
		SHADER;
		XML;
		DATA;
		SOUND;
		ATLAS_PNG;
		ATLAS_JPG;
		FONT_TTF;
		FONT_OTF;
	}