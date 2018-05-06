package beardFramework.display.ui.components;

import beardFramework.display.core.BeardVisual;
import beardFramework.interfaces.IUIComponent;
import beardFramework.resources.assets.AssetManager;
import beardFramework.resources.save.data.DataUIComponent;
import beardFramework.resources.save.data.DataUIVisualComponent;

/**
 * ...
 * @author Ludo
 */
class UIBeardVisual extends BeardVisual implements IUIComponent
{
	@:isVar public var width(get, set):Float;
	@:isVar public var height(get, set):Float;
	@:isVar public var preserved(get, set):Bool;
	@:isVar public var container(get, set):String;
	@:isVar public var visible(get, set):Bool;
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
	
	
	
	function get_width():Float 
	{
		return width;
	}
	
	function set_width(value:Float):Float 
	{
		return width = value;
	}
		
	function get_height():Float 
	{
		return height;
	}
	
	function set_height(value:Float):Float 
	{
		return height = value;
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
	
	public function UpdateVisual():Void 
	{
		
	}
	
	public function ToData():DataUIComponent 
	{
		var data:DataUIVisualComponent = 
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
	
	public function ParseData(data:DataUIComponent):Void 
	{
		var img:AbstractDataUIVisualComponent = cast data;
				
		this.id = AssetManager.Get().GetTileID(img.texture, img.atlas);
		
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
		
	function get_visible():Bool 
	{
		return visible;
	}
	
	function set_visible(value:Bool):Bool 
	{
		return visible = value;
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