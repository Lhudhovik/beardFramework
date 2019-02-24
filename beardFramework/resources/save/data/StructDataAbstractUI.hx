package beardFramework.resources.save.data;

/**
 * @author Ludo
 */
typedef StructDataAbstractUI =
{
	>StructDataGeneric,
	var visible:Bool;
	//var group:String;
	
}

@:forward
abstract DataAbstractUI(StructDataAbstractUI) from StructDataAbstractUI to StructDataAbstractUI {
  inline public function new(data:StructDataAbstractUI) {
    this = data;
  }
}