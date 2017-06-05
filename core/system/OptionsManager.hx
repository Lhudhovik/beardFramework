package beardFramework.core.system;
import beardFramework.events.input.InputManager;
import beardFramework.resources.assets.AssetManager;

/**
 * ...
 * @author Ludo
 */
class OptionsManager
{

	private static var instance(get,null):OptionsManager;
	
	public var resourcesToLoad:Array<ResourceToLoad>;
	private var settings:Xml;
	private function new() 
	{
		
	}
	
	public static function get_instance():OptionsManager
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
		xml = xml.firstElement();
		
		for (element in xml.elements())
		{
			
			if (element.nodeName == "atlases")
			{
				for (atlas in element.elementsNamed("atlas"))
				{
					resourcesToLoad.push({ type:atlas.get("fileExtention") == "jpg" ?AssetType.ATLAS_JPG : AssetType.ATLAS_PNG, name : atlas.get("name"), url:atlas.get("path") });
				}
			}
			
			if (element.nodeName == "settings")
			{
				settings = element;
				InputManager.get_instance().ParseInputSettings(settings.elementsNamed("inputs").next());
				
			}
			
			
		}
	}
	
	
	
	
}

typedef ResourceToLoad = {
	
	var type : AssetType;
	var name : String;
	var url : String;
	
}