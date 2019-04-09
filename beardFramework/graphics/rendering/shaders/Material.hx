package beardFramework.graphics.rendering.shaders;

/**
 * ...
 * @author Ludovic
 */
class Material 
{
	
	public var components(default,null):Map<String,MaterialComponent>;
	public var isDirty:Bool;
	
	public function new() 
	{
		components = new Map();
	}
	
	
	public function ParseData():Void
	{
		
		
		isDirty = true;
	}
	
	
	
	
}