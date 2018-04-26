package beardFramework.display.ui.components;
import beardFramework.interfaces.IUIComponent;
import beardFramework.resources.save.data.DataUIComponent;
import openfl.display.DisplayObject;

/**
 * ...
 * @author Ludo
 */

enum Layout
{
	VERTICAL;
	HORIZONTAL;
	CUSTOM;
	
}
class UIContainer implements IUIComponent
{
	@:isVar public var width(get, set):Float;
	@:isVar public var height(get, set):Float;
	@:isVar public var name(get, set):String;
	@:isVar public var visible(get, set):Bool = false;
	@:isVar public var scaleX(get, set):Float;
	@:isVar public var scaleY(get, set):Float;
	@:isVar public var x(get, set):Float;
	@:isVar public var y(get, set):Float;
	@:isVar public var group(get, set):String;
	@:isVar public var preserved(get, set):Bool;
	@:isVar public var container(get, set):String;
	
	public var fillPart:Float;
	public var vAlign:UInt;
	public var hAlign:UInt;
	public var keepRatio:Bool;
	public var layoutType : Layout;
	public var topMargin:Float;
	public var bottomMargin:Float;
	public var leftMargin:Float;
	public var rightMargin:Float;
	public var separator:Float; // see to add a range
	public var similarChildren:Bool;
	public var components:Array<IUIComponent>;
	
	
	public function new(layout:Layout, x:Float=0, y:Float = 0, width:Float = -1, height:Float = -1,  similarChildren:Bool = true) 
	{
		this.x = x;
		this.y = y;
		this.width = width;
		this.height = height;
		this.similarChildren = similarChildren;
		topMargin = bottomMargin = leftMargin = rightMargin = separator = 0;
		hAlign = vAlign = 0;
		layoutType = layout;
		keepRatio = false;
		components = new Array<IUIComponent>();
	}
	
	public inline function Add(component:IUIComponent ):Void
	{
		components.push(component);
		component.visible = this.visible;
		component.container = this.name;
		
		UpdateVisual();

	}
	
	public inline function Remove(component:IUIComponent):Void
	{
		components.remove(component);
		UpdateVisual();
	}
	
	public function GetComponent(name:String):IUIComponent
	{
		
		for (component in components){
			
			if (component.name == name) return component;
		}
		
		return null;
		
	}
	
	public function UpdateVisual():Void
	{
		//adjust size
		var i : Int = 0;
		var helper:Float = 0;
		if (layoutType == Layout.HORIZONTAL){
			if (similarChildren){
				for (component in components){
					component.width = (width - leftMargin - rightMargin - (separator * width * (components.length - 1))) / components.length;
				
					component.height = height - topMargin - bottomMargin;
					if (component.keepRatio) component.scaleX = component.scaleY = component.scaleX > component.scaleY? component.scaleY:component.scaleX;
					
					component.x = this.x + (component.width + separator*width) * i++ + leftMargin;
					component.y = this.y + topMargin;
					component.UpdateVisual();
					
					
				}
			}
			else {
				for (component in components){
					component.width =  ((width - leftMargin - rightMargin) * component.fillPart) - ((separator*width*(components.length-1)) / components.length);
					component.height = height - topMargin - bottomMargin;
					if (component.keepRatio) component.scaleX = component.scaleY = component.scaleX > component.scaleY? component.scaleY:component.scaleX;
					
					component.x = this.x + helper + separator*width*i++ + leftMargin;
					component.y = this.y +topMargin;
					helper += component.width;
					component.UpdateVisual();
				}	
			}
			
			
			
		}
		else if (layoutType == Layout.VERTICAL)
		{
			
			if (similarChildren){
				for (component in components){
					component.height = (height - topMargin - bottomMargin - (separator * height * (components.length - 1))) / components.length;
				
					component.width = width - leftMargin - rightMargin;
					if (component.keepRatio) component.scaleX = component.scaleY = component.scaleX > component.scaleY? component.scaleY:component.scaleX;
					
					component.y = this.y + (component.height + separator*height) * i++ + topMargin;
					component.x = this.x + leftMargin;
					component.UpdateVisual();	
					
					
				}
			}
			else {
				for (component in components){
					component.height = ((height - topMargin - bottomMargin) * component.fillPart) - ((separator*height*(components.length-1)) / components.length);
					component.width = width - leftMargin - rightMargin;
					if (component.keepRatio) component.scaleX = component.scaleY = component.scaleX > component.scaleY? component.scaleY:component.scaleX;
					
					component.y = this.y + helper + separator*height*i++ + topMargin;
					component.x = this.x + leftMargin;
					helper += component.height;
					component.UpdateVisual();
				}	
			}
			
		}
		
	}
	
	public function Clear():Void 
	{
		
		while (components.length > 0)
		{
			components.pop().Clear();
		}
		
		components = null;
		
		
	}	
	
	public function ToData():DataUIComponent 
	{
		
		var data:DataUIComponent = 
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
			
			parent: (container!= null) ? container:"",
			additionalData:	""		
			
		}
			
		return data;
	}
	
	public function ToDeepData(parent:String = ""):Array<DataUIComponent>
	{
		var data:Array<DataUIComponent> = [ToData()];
		
		for (component in components){
			if (Std.is(component, UIContainer)) data = data.concat(cast(component, UIContainer).ToDeepData());
			else data.push(component.ToData());
		}
		
		return data;
	}
	
	public function ParseData(data:DataUIComponent):Void 
	{
		
		this.visible=data.visible;
			
		this.x= data.x;
		this.y= data.y;
		this.name= data.name;
		this.width= data.width;
		this.height=data.height;
		this.scaleX=data.scaleX;
		this.scaleY=data.scaleY;
			
		this.vAlign=data.vAlign;
		this.hAlign=data.hAlign;
		this.fillPart=data.fillPart;
		this.keepRatio=data.keepRatio;
		UpdateVisual();
		
	}
		
	function get_group():String 
	{
		return group;
	}
	
	function set_group(value:String):String 
	{
		for (component in components)
			component.group = value;
		
		return group = value;
	}
		
	function get_x():Float 
	{
		return x;
	}
	
	function set_x(value:Float):Float 
	{
		if (x != value){
			x = value;
			//UpdateVisual();
		}
		return x;
	}
	
	function get_y():Float 
	{
		return y;
	}
	
	function set_y(value:Float):Float 
	{
		if (y != value){
			y = value;
			//UpdateVisual();
		}
		return y;
	}
	
	function get_scaleX():Float 
	{
		return scaleX;
	}
	
	function set_scaleX(value:Float):Float 
	{
		return scaleX = value;
	}
		
	function get_scaleY():Float 
	{
		return scaleY;
	}
	
	function set_scaleY(value:Float):Float 
	{
		return scaleY = value;
	}
		
	function set_width(value:Float):Float 
	{
		if (width != value){
		width = value;
		//UpdateVisual();	
		}
		
		return width;
	}
	
	function set_height(value:Float):Float 
	{
		if (height != value){
			height = value;
			//UpdateVisual();
		}
		return height;
	}
	
	function get_width():Float 
	{
		return width;
	}
	
	function get_height():Float 
	{
		return height;
	}
	
	function get_name():String 
	{
		return name;
	}
	
	function set_name(value:String):String 
	{
		return name = value;
	}
	
	function get_visible():Bool
	{
		return visible;
	}
	
	function set_visible(value:Bool):Bool 
	{
		visible = value;
		
		for (component in components)
		{
			component.visible = value;
		}
				 
		return visible;
	}
	
	function get_preserved():Bool 
	{
		return preserved;
	}
	
	function set_preserved(value:Bool):Bool 
	{
		for (component in components)
			component.preserved = value;
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