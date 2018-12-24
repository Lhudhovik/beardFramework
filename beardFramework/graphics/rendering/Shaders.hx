package beardFramework.graphics.rendering;
import beardFramework.core.BeardGame;
import beardFramework.utils.Crypto;
import beardFramework.utils.StringLibrary;
import mloader.Loader.LoaderEvent;
import sys.FileSystem;
import sys.io.File;

/**
 * ...
 * @author 
 */
class Shaders 
{
	
	static public var shader:Map<String,String> = new Map<String,String>();
	static public var loaded:Bool= false;
	
	static public function LoadShaders():Void
	{
		
		if (!loaded && FileSystem.exists(BeardGame.Get().SHADERS_PATH))
		{
			for (element in FileSystem.readDirectory(BeardGame.Get().SHADERS_PATH))
			{
				if (element.indexOf(StringLibrary.SHADER_EXTENSION) != -1){
					//
					#if debug
					shader[cast(element, String).split(".")[0]] = File.getContent(BeardGame.Get().SHADERS_PATH + element);
					#else
					shader[cast(element, String).split(".")[0]] =  Crypto.DecodedData(File.getContent(BeardGame.Get().SHADERS_PATH + element));	
					#end
					
					//trace(shader[cast(element, String).split(".")[0]]);
					//trace(shader);
				}
			}
			loaded = true;
		}
		
			
	}
}