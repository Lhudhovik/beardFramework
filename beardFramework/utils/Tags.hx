package beardFramework.utils;

/**
 * ...
 * @author 
 */
class Tags 
{

	static private var tags:Map<String, UInt>;
	static private var count:Int = 0;
	
	static inline public function AddTag(tag:String):UInt
	{
		
		if (tags == null)
			tags = new Map();
		
		if (!tags.exists(tag)) tags[tag] = 1 << count++;
		
		
		return tags[tag];
		
	}
	
	static inline public function GetTag(tag:String):UInt
	{
		return (tags != null && tags.exists(tag)) ? tags[tag] : 0;
	}
		
	
	static inline public function GetTagList(tagValue:UInt):List<String>
	{
		var list:List<String> = new List();
		
		for (key in tags.keys())
			if (Is(tagValue, tags[key])) list.push(key);
				
		return list;
	}
	
	static inline public function GetTags(tagNames:Array<String>):UInt
	{
		var tag:UInt = 0;
		
		if (tags != null && tagNames != null)
			for (tagName in tagNames)
				if (tags.exists(tagName)) tag |= tags[tagName];
		
		return tag;
	}
	
	
	static inline public function Is(tagValue:UInt, tag:UInt):Bool
	return (tagValue & tag ) == tag;
	
	static inline public function HasTag(tagValue:UInt, tag:UInt):Bool
	return (tagValue & tag ) != 0;	
}