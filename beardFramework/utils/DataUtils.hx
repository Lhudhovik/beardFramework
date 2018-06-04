package beardFramework.utils;
import beardFramework.resources.save.data.DataGeneric;
import haxe.Json;
import lime.utils.Float32Array;


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
	
	static public function DataListToMap<T:DataGeneric>(dataList:List<T>):Map<String, T>
	{
		
		var map:Map<String, T> = new Map<String, T>();
		
		for (element in dataList)
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
	
	static public inline function FromStringToBool(value:String):Bool
    {
        return value != null ? value.toLowerCase() == "true" : false;
    }
	
	static public function DisplayFloatArrayContent(array:Float32Array, stride:Int ):Void
	{
		var string:String;
		for (i in 0...Math.round(array.length / stride))
		{
			string = "";
			for (j in 0...stride)
				string += array[i * stride +j] + ", ";
			
			trace(string);
			
		}
		
		
	}
}


private typedef JSONMapPair<T> = {
	
	var key:String;
	var value:T;
}