package beardFramework.graphics.ui.components;

import beardFramework.graphics.core.Visual;
import beardFramework.interfaces.IUIComponent;
import beardFramework.resources.assets.AssetManager;
import beardFramework.resources.save.data.StructDataUIComponent;
import beardFramework.resources.save.data.StructDataUIVisualComponent;

/**
 * ...
 * @author Ludo
 */
class UIBeardVisual extends Visual implements IUIComponent
{
	
	@:isVar public var preserved(get, set):Bool;
	@:isVar public var container(get, set):String;
	@:isVar public var group(get, set):String;
	
	public var vAlign:UInt;
	public var hAlign:UInt;
	public var fillPart:Float;
	public var keepRatio:Bool;
	
	public function new(texture:String, atlas:String) 
	{
		super(texture, atlas);
		
	}
	
	
	/* INTERFACE beardFramework.interfaces.IUIComponent */
	
	
	
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
	
	public function UpdateVisual():Void 
	{
		
	}
	
	public function ToData():StructDataUIComponent 
	{
		var data:StructDataUIVisualComponent = 
		{
			visible:this.visible,
			type:Type.getClassName(Type.getClass(this)),
			x: this.x,
			y: this.y,
			name: this.name,
			width: this.width,
			height:this.height,
			scaleX:this.scaleX,
			scaleY:this.scaleY,
			
			vAlign:this.vAlign,
			hAlign:this.hAlign,
			fillPart:this.fillPart,
			keepRatio:this.keepRatio,
			texture: texture,
			atlas: atlas,
			
			parent: (container!= null) ? container:"",
			additionalData:	""	
			
		}
			
		return data;
	}
	
	public function ParseData(data:StructDataUIComponent):Void 
	{
		var img:DataUIVisualComponent = cast data;
				
		this.visible=img.visible;
			
		this.x= img.x;
		this.y= img.y;
		this.name= img.name;
		this.width= img.width;
		this.height=img.height;
		this.scaleX=img.scaleX;
		this.scaleY=img.scaleY;
			
		this.vAlign=img.vAlign;
		this.hAlign=img.hAlign;
		this.fillPart=img.fillPart;
		this.keepRatio=img.keepRatio;
		this.texture= img.texture;
		this.atlas= img.atlas;
	}
		
	
	function get_group():String 
	{
		return group;
	}
	
	function set_group(value:String):String 
	{
		return group = value;
	}
	
	public function Clear():Void 
	{
		
	}
	
}