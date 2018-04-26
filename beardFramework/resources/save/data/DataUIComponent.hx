package beardFramework.resources.save.data;

/**
 * @author Ludo
 */
typedef DataUIComponent =
{
	>DataAbstractUI,
	
	var x:Float;
	var y:Float;
	var name:String;
	var width:Float;
	var height:Float;
	var scaleX:Float;
	var scaleY:Float;
	
	var vAlign:UInt;
	var hAlign:UInt;
	var fillPart:Float;
	var keepRatio:Bool;
	
	var parent:String;
	//var subComponents:Array<DataUIComponent>; 
	var additionalData:String;
	
	
	
	
}
@:forward
abstract AbstractDataUIComponent(DataUIComponent) from DataUIComponent to DataUIComponent {
  inline public function new(data:DataUIComponent) {
    this = data;
  }
}