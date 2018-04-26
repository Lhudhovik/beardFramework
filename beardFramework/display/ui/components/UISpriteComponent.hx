package beardFramework.display.ui.components;

import beardFramework.display.core.BeardSprite;
import beardFramework.interfaces.IUIComponent;
import beardFramework.resources.save.data.DataUIComponent;


/**
 * ...
 * @author Ludo
 */
class UISpriteComponent extends BeardSprite implements IUIComponent
{


	
	public var fillPart:Float;
	public var keepRatio:Bool;
	public var vAlign:UInt;
	public var hAlign:UInt;
	@:isVar public var group(get, set):String;
	@:isVar public var preserved(get, set):Bool;
	@:isVar public var container(get, set):String;
	
	public function new() 
	{
		super();
				
	}
	
	public function UpdateVisual():Void 
	{
		
	}
	
	public function Clear():Void 
	{
		
	}
		
	public function ToData():DataUIComponent 
	{
		var data:DataUIComponent = 
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
	
	public function ParseData(data:DataUIComponent):Void 
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