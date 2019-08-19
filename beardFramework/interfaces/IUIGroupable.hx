package beardFramework.interfaces;

/**
 * @author Ludo
 */
interface IUIGroupable extends INamed
{
  
  public var visible(get,set):Bool;
  public var group(get, set):String;
  
  public function Clear():Void;
  
}