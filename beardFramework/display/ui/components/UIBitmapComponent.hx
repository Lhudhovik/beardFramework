package beardFramework.display.ui.components;

import beardFramework.display.heritage.BeardBitmap;
import beardFramework.display.ui.UIManager;
import beardFramework.interfaces.IUIComponent;
import beardFramework.resources.assets.AssetManager;
import beardFramework.resources.save.data.DataUIVisualComponent;
import beardFramework.resources.save.data.DataUIVisualComponent.AbstractDataUIVisualComponent;
import beardFramework.resources.save.data.DataUIComponent;
import openfl.display.BitmapData;
import openfl.display.PixelSnapping;

/**
 * ...
 * @author Ludo
 */
class UIBitmapComponent extends BeardBitmap implements IUIComponent
{
	public var vAlign:UInt;
	
	public var hAlign:UInt;
	
	public var fillPart:Float;
	
	public var keepRatio:Bool;
	
	@:isVar public var group(get, set):String;
	@:isVar public var preserved(get, set):Bool;
	@:isVar public var container(get, set):String;
	
	private var texture:String;
	private var atlas:String;
	
	public function new(texture:String = "", atlas:String  = "", pixelSnapping:PixelSnapping=null, smoothing:Bool=false) 
	{
		super(AssetManager.Get().GetBitmapData(texture, atlas), pixelSnapping, smoothing);
		
		this.texture = texture;
		this.atlas = atlas;
		keepRatio = true;
	}
		
	public function UpdateVisual():Void 
	{
		
	}
	
	public function Clear():Void 
	{
		AssetManager.Get().DisposeBitmapData(this.texture, this.atlas);
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
				
		this.bitmapData = AssetManager.Get().GetBitmapData(img.texture, img.atlas);
		
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