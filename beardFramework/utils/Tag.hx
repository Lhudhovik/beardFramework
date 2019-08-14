package beardFramework.utils;

/**
 * ...
 * @author 
 */
abstract Tag(UInt) from UInt to UInt
{

	static private var tags:Map<String, Tag>;
	static private var count:Int = 0;
	
	static inline public function AddTag(tag:String):Tag
	{
		
		if (tags == null)
			tags = new Map();
		
		if (!tags.exists(tag)) tags[tag] = 1 << count++;
		
		
		return tags[tag];
		
	}
	
	static inline public function GetTags(tagNames:Array<String>):Tag
	{
		var tag:Tag = 0;
		
		if (tags != null && tagNames != null)
			for (tagName in tagNames)
				if (tags.exists(tagName)) tag |= tags[tagName];
		
		return tag;
	}
	
	static inline public function GetTag(tag:String):Tag
	{
		return (tags != null && tags.exists(tag)) ? tags[tag] : 0;
	}

	inline public function new(i:UInt) {
		this = i;
	}
	inline public function Is(tag:Tag):Bool	return ( this | tag ) == tag;
	
	inline public function HasTag(tag:Tag):Bool return (this & tag ) != 0;	
	
	inline public function GetTagList():List<String>
	{
		var list:List<String> = new List();
		
		for (key in tags.keys()) if (( this | tags[key] ) == tags[key]) list.push(key);
		return list;
	}
	
	
	
	
	
}