package beardFramework.utils;
import beardFramework.resources.save.data.DataGeneric;
import haxe.Json;


/**
 * ...
 * @author Ludo
 */
class DataUtils 
{

	static public function Convert<T>(data:DataGeneric, to:T):T
	{
		
		to = haxe.Json.parse(haxe.Json.stringify(data));
		return to;
		
	}
	
	static public function DataArrayToMap<T:DataGeneric>(dataArray:Array<T>):Map<String, T>
	{
		
		var map:Map<String, T> = new Map<String, T>();
		
		for (element in dataArray)
		{
			map.set(element.name, element);			
		}
		
		return map;
		
		
	}
	
	
	static public function MapFromJSON<T>(map:Map<String, T>, data:String):Map<String, T>
	{
		
		if (map == null) map = new Map<String, T>();
		
		
		var pairs:Array<JSONMapPair<T>> = haxe.Json.parse(data);
		
		for (pair in pairs)
		{
			map.set(pair.key, pair.value);			
		}
		
		return map;
		
		
	}
	
	static public function MapToJson<T>(map:Map<String, T>):String
	{
		
		var data:Array<JSONMapPair<T>> = [];
		for (key in map.keys())
		{
			
			var value:JSONMapPair<T> = {
				
				key:key,
				value: map[key]
			}
			
			data.push(value);
			
		}
				
	
		return haxe.Json.stringify(data);
		
	}
	
}


private typedef JSONMapPair<T> = {
	
	var key:String;
	var value:T;
}