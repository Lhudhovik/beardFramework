package beardFramework.resources.save.data;

/**
 * @author Ludo
 */
typedef StructDataComponent =
{
	>StructDataGeneric,
	var update:Bool;
	var position:Int;
	var additionalData:String;
}

@:forward
abstract DataComponent(StructDataComponent) from StructDataComponent to StructDataComponent {
  inline public function new(data:StructDataComponent) {
    this = data;
  }
}