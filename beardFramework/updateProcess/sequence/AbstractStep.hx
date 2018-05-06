package beardFramework.updateProcess.sequence;

/**
 * ...
 * @author Ludo
 */
@:generic
class AbstractStep
{

	public var name(get, null):String;
	private function new(name:String ) 
	{
		this.name = name;
		
	}
	
	
	public function Proceed():Bool
	{
		return true;
	}
	
	public function Clear():Void
	{
		
	}
	
	function get_name():String 
	{
		return name;
	}
	
}