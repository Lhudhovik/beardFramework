package beardFramework.utils.data;
import beardFramework.resources.save.data.StructAbstractData;
import beardFramework.resources.save.data.StructDataSave;
import haxe.Json;
import haxe.crypto.Base64;
import haxe.io.Bytes;

/**
 * ...
 * @author Ludo
 */
class Crypto 
{

	public static inline function DecodedData(data:String):Dynamic
	{
		
		return haxe.Json.parse( haxe.crypto.Base64.decode(data).toString());
		
		
	}
	
	public static inline function EncodeData(data:StructAbstractData):String
	{
		
		return  Base64.encode(Bytes.ofString(haxe.Json.stringify(data)));
		//return  game.code.encodeString(haxe.Json.stringify(data));
		
		
	}
	
}