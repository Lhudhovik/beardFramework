package beardFramework.utils;
import beardFramework.resources.save.data.AbstractData;
import beardFramework.resources.save.data.DataSave;
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
	
	public static inline function EncodeData(data:AbstractData):String
	{
		
		return  Base64.encode(Bytes.ofString(haxe.Json.stringify(data)));
		//return  game.code.encodeString(haxe.Json.stringify(data));
		
		
	}
	
}