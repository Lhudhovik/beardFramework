package beardFramework.core.system;
import beardFramework.resources.assets.AssetManager;

/**
 * ...
 * @author Ludo
 */
class OptionsManager
{

	private static var instance(get,null):OptionsManager;
	
	public var resourcesToLoad:Array<ResourceToLoad>;
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
		
		for (element in xml.elements())
		{
			
			if (element.nodeName == "atlases")
			{
				for (atlas in element.elementsNamed("atlas"))
				{
					resourcesToLoad.push({ type:atlas.get("fileExtention") == "jpg" ?AssetType.ATLAS_JPG : AssetType.ATLAS_PNG, name : atlas.get("name"), url:atlas.get("path") });
				}
			}
			
			
		}
	}
	
	
	
	
}

typedef ResourceToLoad = {
	
	var type : AssetType;
	var name : String;
	var url : String;
	
}