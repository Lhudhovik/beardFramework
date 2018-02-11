package beardFramework.interfaces;
import beardFramework.interfaces.IEntityComponent;

/**
 * @author Ludo
 */
interface IEntityVisual extends IEntityComponent 
{
	
	public var x(get,set):Float;
	public var y(get, set):Float;
	public function Register():Void;
	
	
}