package beardFramework.interfaces;

/**
 * @author 
 */
interface IBeardyObject 
{
	public var name(get, set):String;
	public var isActivated(default, null):Bool;
	public var group(get, set):String;
	public function Activate():Void;
	public function DeActivate():Void;
	public function Destroy():Void;
}