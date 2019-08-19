package beardFramework.interfaces;

/**
 * @author 
 */
interface ISpatialized extends INamed
{
	@:isVar public var width(get, set):Float;
	@:isVar public var height(get, set):Float;
	@:isVar public var scaleX(get, set):Float;
	@:isVar public var scaleY(get, set):Float;
	@:isVar public var rotation (get, set):Float;
	@:isVar public var x(get, set):Float;
	@:isVar public var y(get, set):Float;
	@:isVar public var z(get, set):Float;
	
}