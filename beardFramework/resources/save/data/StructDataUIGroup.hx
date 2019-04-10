package beardFramework.resources.save.data;
import haxe.ds.Vector;

/**
 * @author Ludo
 */
typedef StructDataUIGroup =
{
	>StructDataAbstractUI,
	var parentGroup:String;
	var subGroupsData:Array<StructDataUIGroup>;
	var componentsData:Array<StructDataUIComponent>;
}

@:forward
abstract DataUIGroup(StructDataUIGroup) from StructDataUIGroup to StructDataUIGroup {
  inline public function new(data:StructDataUIGroup) {
    this = data;
  }
}