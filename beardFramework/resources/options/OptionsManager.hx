package beardFramework.resources.options;
import beardFramework.display.screens.BasicLoadingScreen;
import beardFramework.display.text.FontFormat;
import beardFramework.display.text.TextField;
import beardFramework.input.InputManager;
import beardFramework.resources.assets.AssetManager;

/**
 * ...
 * @author Ludo
 */
class OptionsManager
{

	private static var instance(default,null):OptionsManager;
	
	public var resourcesToLoad:Array<ResourceToLoad>;
	public var fontsToLoad:Array<FontToLoad>;
	private var settings(null,null):Xml;
	private function new() 
	{
		
	}
	
	public static inline function Get():OptionsManager
	{
		if (instance == null)
		{
			instance = new OptionsManager();
			instance.Init();
		}
		
		return instance;
	}
	
	private function Init():Void
	{
		
	}
	
	public function parseSettings(xml:Xml):Void
	{
		
		resourcesToLoad = new Array<ResourceToLoad>();
		fontsToLoad = new Array<FontToLoad>();
		xml = xml.firstElement();
		
		for (element in xml.elements())
		{
			
			if (element.nodeName == "atlases")
			{
				for (atlas in element.elementsNamed("atlas"))
				{
					resourcesToLoad.push({ type: (atlas.get("fileExtension") == "jpg" ?AssetType.ATLAS_JPG : AssetType.ATLAS_PNG), name : atlas.get("name"), url:atlas.get("path") });
				}
			}
			
			if (element.nodeName == "fonts")
			{

				TextField.defaultFont = element.get("default");
				var size:Array<Int> = [];
				var readSize:Array<String> = [];
				for (font in element.elementsNamed("font"))
				{
					
					size = [];
					readSize = font.get("size").split(",");
					for (fontSize in readSize)
					{
						size.push(Std.parseInt(fontSize));
						trace(size);
					}
				
					fontsToLoad.push({ format: (font.get("fileExtension") == "ttf" ?FontFormat.TTF : FontFormat.OTF), name : font.get("name"), size: size });
				}
			}
			
			if (element.nodeName == "settings")
			{
				settings = element;
				InputManager.Get().ParseInputSettings(settings.elementsNamed("inputs").next());
				
				BasicLoadingScreen.MINLOADINGTIME = Std.parseFloat(settings.elementsNamed("loading").next().get("minLoadingTime")) * 1000; //time is in seconds on the config file so need to translate to milliseconds
				
			}
			
			
		}
	}
	
	public function GetSettings(settingsName:String):Xml
	{
		var returnedSettings : Xml = null;
		if (settingsName == "") returnedSettings = settings;
		else for (element in settings.elementsNamed(settingsName)) 
			if (element.nodeName == settingsName)
			{ 
				returnedSettings = element; 
				break;
			} 
			
		return returnedSettings;
	}
	
	
	
	
}

typedef ResourceToLoad = {
	
	var type : AssetType;
	var name : String;
	var url : String;
	
}

typedef FontToLoad = {
	var size : Array<Int>;
	var format:FontFormat;
	var name:String;
	
}