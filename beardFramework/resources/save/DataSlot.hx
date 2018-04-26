package beardFramework.resources.save;
import beardFramework.resources.save.data.DataSave;


/**
 * ...
 * @author Ludo
 */
@:generic
typedef DataSlot<T> =
{
	var address:String;
	var name:String;
	var data:T;
	
}

@:generic
abstract AbstractDataSlot<T>(DataSlot<T>) from DataSlot<T> to DataSlot<T> {
  inline public function new(data:DataSlot<T>) {
    this = data;
  }
}