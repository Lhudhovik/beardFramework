package beardFramework.resources.save.data;

/**
 * @author Ludo
 */
typedef DataComponent =
{
	>DataGeneric,
	var update:Bool;
	var position:Int;
	var additionalData:String;
}

@:forward
abstract AbstractDataComponent(DataComponent) from DataComponent to DataComponent {
  inline public function new(data:DataComponent) {
    this = data;
  }
}