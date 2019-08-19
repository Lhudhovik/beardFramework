package beardFramework.interfaces;
import beardFramework.interfaces.IEntityComponent;

/**
 * @author Ludo
 */
interface IEntityVisual extends IEntityComponent extends ISpatialized
{
	
	public function Register():Void;
	public function UnRegister():Void;
	
	
}