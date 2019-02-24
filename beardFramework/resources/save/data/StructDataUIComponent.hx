package beardFramework.resources.save.data;

/**
 * @author Ludo
 */
typedef StructDataUIComponent =
{
	>StructDataAbstractUI,
	
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
abstract DataUIComponent(StructDataUIComponent) from StructDataUIComponent to StructDataUIComponent {
  inline public function new(data:StructDataUIComponent) {
    this = data;
  }
}