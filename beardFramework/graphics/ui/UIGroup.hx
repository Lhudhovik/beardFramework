package beardFramework.graphics.ui;

import beardFramework.graphics.ui.components.UIContainer;
import beardFramework.interfaces.IUIComponent;
import beardFramework.interfaces.IUIGroupable;
import beardFramework.resources.save.data.StructDataUIComponent;
import beardFramework.resources.save.data.StructDataUIGroup;

/**
 * ...
 * @author Ludo
 */
class UIGroup implements IUIGroupable 
{
	@:isVar public var group(get, set):String;
	@:isVar public var name(get, set):String;
	@:isVar public var visible(get, set):Bool;
	
	public var members:Array<IUIGroupable>;
	
	public function new(name:String) 
	{
	
		members = new Array<IUIGroupable>();
		this.name = name;
		this.visible = true;
	}
	
	public inline function Add(member:IUIGroupable):Void
	{
		members.push(member);
		member.visible = this.visible;
		member.group = this.name;
	}
	
	public inline function Remove(member:IUIGroupable):Void
	{
		members.remove(member);
	}
	
	public function GetMember(name:String):IUIGroupable
	{
		var result:IUIGroupable = null;
		
		if (name == this.name) result = this; 
		else
			for (member in members)
			{
				
				if (member.name == name){
					result = member;
					break;
				}
				else if (Std.is(member, UIGroup) && (result = cast(member, UIGroup).GetMember(name)) != null)
					break;
			}
		
		return result;
		
	}
	
	public function ToData():StructDataUIGroup
	{
		
		var componentsData:Array <StructDataUIComponent> = [];
		for (member in members)
			if (!Std.is(member, UIGroup)){ 
				if (Std.is(member, UIContainer)) componentsData = componentsData.concat(cast(member, UIContainer).ToDeepData());
				else componentsData.push( cast(member, IUIComponent).ToData());
				
			}
		
		
		var data:StructDataUIGroup = 
		{
			name : this.name,
			type: Type.getClassName(Type.getClass(this)),
			visible: this.visible,
			parentGroup: this.group,
			subGroupsData: [for(member in members) if(Std.is(member,UIGroup)) cast(member, UIGroup).ToData()],
			componentsData:componentsData
		}
		
		//trace(componentsData);
		return data; 
		
	}
	
	public function Clear():Void 
	{
		while (members.length > 0)
			members.pop();
		members = null;
	}
	
	function get_group():String 
	{
		return group;
	}
	
	function set_group(value:String):String 
	{
		return group = value;
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
		for (member in members)
			member.visible = value;
				
		return visible = value;
	}
	
	
}