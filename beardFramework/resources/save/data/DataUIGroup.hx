package beardFramework.resources.save.data;

/**
 * @author Ludo
 */
typedef DataUIGroup =
{
	>DataAbstractUI,
	var parentGroup:String;
	var subGroupsData:Array<DataUIGroup>;
	var componentsData:Array<DataUIComponent>;
}

@:forward
abstract AbstractDataUIGroup(DataUIGroup) from DataUIGroup to DataUIGroup {
  inline public function new(data:DataUIGroup) {
    this = data;
  }
}