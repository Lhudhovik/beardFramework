package beardFramework.display.ui.components;
import beardFramework.interfaces.IUIComponent;
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
	public var elements:List<IUIComponent>;
	
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
		elements = new List<IUIComponent>();
	}
	
	public function AddComponent(component:IUIComponent, addToDisplayList:Bool = true ):Void
	{
		elements.add(component);
		UpdateVisual();
	}
	
	public function RemoveComponent(component:IUIComponent):Void
	{
		elements.remove(component);
		UpdateVisual();
	}
	
	public function UpdateVisual():Void
	{
		//adjust size
		var i : Int = 0;
		var helper:Float = 0;
		if (layoutType == Layout.HORIZONTAL){
			if (similarChildren){
				for (element in elements){
					element.width = (width - leftMargin - rightMargin - (separator * width * (elements.length - 1))) / elements.length;
				
					element.height = height - topMargin - bottomMargin;
					if (element.keepRatio) element.scaleX = element.scaleY = element.scaleX > element.scaleY? element.scaleY:element.scaleX;
					
					element.x = this.x + (element.width + separator*width) * i++ + leftMargin;
					element.y = this.y + topMargin;
					element.UpdateVisual();
				}
			}
			else {
				for (element in elements){
					element.width =  ((width - leftMargin - rightMargin) * element.fillPart) - ((separator*width*(elements.length-1)) / elements.length);
					element.height = height - topMargin - bottomMargin;
					if (element.keepRatio) element.scaleX = element.scaleY = element.scaleX > element.scaleY? element.scaleY:element.scaleX;
					
					element.x = this.x + helper + separator*width*i++ + leftMargin;
					element.y = this.y +topMargin;
					helper += element.width;
					element.UpdateVisual();
				}	
			}
			
			
			
		}
		else if (layoutType == Layout.VERTICAL)
		{
			
			if (similarChildren){
				for (element in elements){
					element.height = (height - topMargin - bottomMargin - (separator * height * (elements.length - 1))) / elements.length;
				
					element.width = width - leftMargin - rightMargin;
					if (element.keepRatio) element.scaleX = element.scaleY = element.scaleX > element.scaleY? element.scaleY:element.scaleX;
					
					element.y = this.y + (element.height + separator*height) * i++ + topMargin;
					element.x = this.x + leftMargin;
					element.UpdateVisual();	
				}
			}
			else {
				for (element in elements){
					element.height = ((height - topMargin - bottomMargin) * element.fillPart) - ((separator*height*(elements.length-1)) / elements.length);
					element.width = width - leftMargin - rightMargin;
					if (element.keepRatio) element.scaleX = element.scaleY = element.scaleX > element.scaleY? element.scaleY:element.scaleX;
					
					element.y = this.y + helper + separator*height*i++ + topMargin;
					element.x = this.x + leftMargin;
					helper += element.height;
					element.UpdateVisual();
				}	
			}
			
		}
		
		
		
		
	}
	
	
	/* INTERFACE beardFramework.interfaces.IUIComponent */
	
	@:isVar public var x(get, set):Float;
	
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
	
	@:isVar public var y(get, set):Float;
	
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
	
	@:isVar public var scaleX(get, set):Float;
	
	function get_scaleX():Float 
	{
		return scaleX;
	}
	
	function set_scaleX(value:Float):Float 
	{
		return scaleX = value;
	}
	
	@:isVar public var scaleY(get, set):Float;
	
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
	
		
	
}