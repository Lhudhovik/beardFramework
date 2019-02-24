package beardFramework.utils.data;

/**
 * ...
 * @author 
 */
class XMLU 
{

	static public inline function GetXmlFloat(xml:Xml, attributeName:String):Float
    {
        var value:String = xml.get (attributeName);
        if (value != null)
            return Std.parseFloat(value);
        else
            return 0;
    }
    	
	
	
}