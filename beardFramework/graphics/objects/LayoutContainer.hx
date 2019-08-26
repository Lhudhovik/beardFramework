package beardFramework.graphics.objects;
import beardFramework.graphics.objects.WorldObject;
import beardFramework.interfaces.IUIComponent;
import beardFramework.resources.MinAllocArray;
import beardFramework.resources.save.data.StructDataUIComponent;
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
class LayoutContainer extends WorldObject
{
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
	public var components:MinAllocArray<WorldObject>;
	
	
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
		components = new MinAllocArray<WorldObject>();
	}
	
	public inline function Add(component:IUIComponent ):Void
	{
		components.Push(component);
		//component.canRender = this.canRender;
		component.container = this.name;
		
		UpdateVisual();

	}
	
	public inline function Remove(component:WorldObject):Void
	{
		components.Remove(component);
		UpdateVisual();
	}
	
	public function GetComponent(name:String):WorldObject
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
					if (keepRatio) component.scaleX = component.scaleY = component.scaleX > component.scaleY? component.scaleY:component.scaleX;
					
					component.x = this.x + (component.width + separator*width) * i++ + leftMargin;
					component.y = this.y + topMargin;
				}
			}
			else {
				for (component in components){
					component.width =  ((width - leftMargin - rightMargin) * component.fillPart) - ((separator*width*(components.length-1)) / components.length);
					component.height = height - topMargin - bottomMargin;
					if (keepRatio) component.scaleX = component.scaleY = component.scaleX > component.scaleY? component.scaleY:component.scaleX;
					
					component.x = this.x + helper + separator*width*i++ + leftMargin;
					component.y = this.y +topMargin;
					helper += component.width;
				}	
			}
			
			
			
		}
		else if (layoutType == Layout.VERTICAL)
		{
			
			if (similarChildren){
				for (component in components){
					component.height = (height - topMargin - bottomMargin - (separator * height * (components.length - 1))) / components.length;
				
					component.width = width - leftMargin - rightMargin;
					if (keepRatio) component.scaleX = component.scaleY = component.scaleX > component.scaleY? component.scaleY:component.scaleX;
					
					component.y = this.y + (component.height + separator*height) * i++ + topMargin;
					component.x = this.x + leftMargin;
				}
			}
			else {
				for (component in components){
					component.height = ((height - topMargin - bottomMargin) * component.fillPart) - ((separator*height*(components.length-1)) / components.length);
					component.width = width - leftMargin - rightMargin;
					if (keepRatio) component.scaleX = component.scaleY = component.scaleX > component.scaleY? component.scaleY:component.scaleX;
					
					component.y = this.y + helper + separator*height*i++ + topMargin;
					component.x = this.x + leftMargin;
					helper += component.height;
				}	
			}
			
		}
		
	}
	
	public function Destroy():Void 
	{
		
		while (components.length > 0)
		{
			components.Pop().Destroy();
		}
		
		components = null;
		
		
	}	
	
	public function ToData():StructDataUIComponent 
	{
		
		var data:StructDataUIComponent = 
		{
			canRender:this.canRender,
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
	
	public function ToDeepData(parent:String = ""):Array<StructDataUIComponent>
	{
		var data:Array<StructDataUIComponent> = [ToData()];
		
		for (component in components){
			if (Std.is(component, LayoutContainer)) data = data.concat(cast(component, LayoutContainer).ToDeepData());
			else data.push(component.ToData());
		}
		
		return data;
	}
	
	public function ParseData(data:StructDataUIComponent):Void 
	{
		
		this.canRender=data.canRender;
			
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
	
	override public function set_width(value:Float):Float 
	{
		return SetBaseWidth(value);
	}
	
	override public function set_height(value:Float):Float 
	{
		return SetBaseHeight(value);
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