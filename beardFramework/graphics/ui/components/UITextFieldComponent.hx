package beardFramework.graphics.ui.components;


import beardFramework.graphics.text.TextField;
import beardFramework.interfaces.IUIComponent;
import beardFramework.resources.save.data.StructDataUIComponent;

/**
 * ...
 * @author Ludo
 */
class UITextFieldComponent extends TextField implements IUIComponent
{

	public var vAlign:UInt;
	public var hAlign:UInt;
	public var fillPart:Float;
	public var keepRatio:Bool;
	@:isVar public var group(get, set):String;
	@:isVar public var preserved(get, set):Bool;
	@:isVar public var container(get, set):String;
	
	
	public function new(text:String="", font:String="", size:Int = 32, name:String = "" ) 
	{
		super(text, font, size, name);
		
	}
	
	public function UpdateVisual():Void 
	{
		
	}
	
	public function Clear():Void 
	{
		
	}
	
	public function ToData():StructDataUIComponent 
	{
		var data:StructDataUIComponent = 
		{
			visible:this.visible,
			name:this.name,
			type:Type.getClassName(Type.getClass(this)),
			x: this.x,
			y: this.y,
			width: this.width,
			height:this.height,
			scaleX:this.scaleX,
			scaleY:this.scaleY,
			
			vAlign:this.vAlign,
			hAlign:this.hAlign,
			fillPart:this.fillPart,
			keepRatio:this.keepRatio,
			
			parent: (container!= null) ? container:"",
			additionalData:	""		
			
		}
			
		return data;
	}
	
	public function ParseData(data:StructDataUIComponent):Void 
	{
		
	}
	
	function get_group():String 
	{
		return group;
	}
	
	function set_group(value:String):String 
	{
		return group = value;
	}
	
	function get_preserved():Bool 
	{
		return preserved;
	}
	
	function set_preserved(value:Bool):Bool 
	{
		return preserved = value;
	}
	
	function get_container():String 
	{
		return container;
	}
	
	function set_container(value:String):String 
	{
		return container = value;
	}	
}