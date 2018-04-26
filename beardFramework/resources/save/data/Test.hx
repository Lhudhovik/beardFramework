package beardFramework.resources.save.data;

/**
 * ...
 * @author Ludo
 */
abstract Test<T>(T) from T to T 
{
	inline public function new(data:T) {
		this = data;
	}
}