package beardFramework.utils.data;
import beardFramework.resources.save.data.StructDataGeneric;
import haxe.Json;
import lime.utils.Float32Array;


/**
 * ...
 * @author Ludo
 */

class DataU 
{


	static public function Convert<T>(data:StructDataGeneric, to:T):T
	{
		
		to = haxe.Json.parse(haxe.Json.stringify(data));
		return to;
		
	}
	
	static public function DataArrayToMap<T:StructDataGeneric>(dataArray:Array<T>):Map<String, T>
	{
		
		var map:Map<String, T> = new Map<String, T>();
		
		for (element in dataArray)
		{
			map.set(element.name, element);			
		}
		
		return map;
		
		
	}
	
	static public function DataListToMap<T:StructDataGeneric>(dataList:List<T>):Map<String, T>
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
	
	static private var source:Dynamic;
	static private var searched:Array<Dynamic>;
	static private var hierarchy:Int = 0;
	static public function DeepTrace(object:Dynamic):Void
	{
		
		
		
		if (object == null){
			trace("Deep Trace failed : null instance");
			return;
		}
		
		
		
		
		if (searched == null) searched = new Array();
		
		if (searched.length == 0){
			source = object;
		}
		
		
		
		
		searched.push(object);
		
		var fields : Array<String> = Type.getInstanceFields(Type.getClass(object));
		var currentField:Dynamic;
		var depth:String = "";
		
		if (searched.length > 0){
			for (i in 0...hierarchy+1)
			{
				if(i!=0)
				depth += "\t";
			}
		}
		
		if (Reflect.hasField(object, "name"))
			trace(depth + "Deep Trace of " + Reflect.field(object, "name"));
		else
			trace(depth + "Deep Trace of instance of " + Type.getClassName(Type.getClass(object)));
		
		depth += "\t";
		hierarchy++;
		for (field in fields)
		{
			
			currentField  = Reflect.field(object, field);
			if (!Reflect.isFunction(currentField)){
				trace(depth + field + " : " + currentField);
			
				if ( Reflect.isObject(currentField) && searched.indexOf(currentField) == -1)
				{
					
					
					DeepTrace(currentField);
				}
			}
			
			
		}
		
		hierarchy--;
		if (source == object) 
		{
			searched = [];
		}
	
	}
}


private typedef JSONMapPair<T> = {
	
	var key:String;
	var value:T;
}