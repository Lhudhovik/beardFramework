package beardFramework.utils;

/**
 * ...
 * @author Ludo
 */
class SysPreciseTime 
{

	static public inline function preciseTime(sys:Class<Sys>):Float {
    return Sys.time()*1000;
  }
	
}