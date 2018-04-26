package beardFramework.resources.save.data;

/**
 * @author Ludo
 */
typedef DataAbstractUI =
{
	>DataGeneric,
	var visible:Bool;
	//var group:String;
	
}

@:forward
abstract AbstractDataAbstractUI(DataAbstractUI) from DataAbstractUI to DataAbstractUI {
  inline public function new(data:DataAbstractUI) {
    this = data;
  }
}