package beardFramework.interfaces;

/**
 * @author Ludo
 */
interface IUIGroupable extends IBeardyObject
{
  
  public var canRender(get,set):Bool;
  public var group(get, set):String;
  public function Destroy():Void;
  
}