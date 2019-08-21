package beardFramework.systems;

import beardFramework.core.BeardGame;
import beardFramework.graphics.ui.components.UIContainer;
import beardFramework.interfaces.IBeardyObject;
import beardFramework.interfaces.IUIComponent;
import beardFramework.interfaces.IUIGroupable;
import beardFramework.resources.MinAllocArray;
import beardFramework.resources.save.data.StructDataUIComponent;
import beardFramework.resources.save.data.StructDataUIGroup;

/**
 * ...
 * @author Ludo
 */
class BeardGroup implements IBeardyObject 
{
	public static var groups:Map<String, BeardGroup>;
	
	public static function CreateGroup(name:String):BeardGroup
	{
		if (groups == null) groups = new Map();
		if (groups[name] != null){
			groups[name].Destroy();
			groups[name] = null;
		}
		
		groups[name] = new BeardGroup(name);
		
	}
	
	
	@:isVar public var group(get, set):String;
	@:isVar public var name(get, set):String;
	public var isActivated(default, null):Bool;
	public var members:MinAllocArray<IBeardyObject>;
	
	public function new(name:String) 
	{
		if (groups == null) groups = new Map();
		if (groups[name] != null){
			groups[name].Destroy();
			groups[name] = null;
		}
		
		groups[name] = this;
		members = new Array<IBeardyObject>();
		this.name = name;
	}
	
	public inline function Add(member:IBeardyObject):Void
	{
		if (member.group != null && member.group != "" && member.group != name)
		{
			groups[member.group].Remouve(member);
		}
		
		members.Push(member);
		
		if (member.isActivated != isActivated)
		{
			if(isActivated) member.Activate();
			else member.DeActivate();
		}
		
		member.group = this.name;
	}
	
	public inline function Remove(member:IBeardyObject):Void
	{
		members.remove(member);
	}
	
	public function GetMember(name:String):IBeardyObject
	{
		var result:IBeardyObject = null;
		var member:IBeardyObject = null;
		if (name == this.name) result = this; 
		else
			for (i in 0...members.length)
			{
				
				
				if (member.name == name){
					result = member;
					break;
				}
				else if (Std.is(member, BeardGroup) && (result = cast(member, BeardGroup).GetMember(name)) != null)
					break;
			}
		
		return result;
		
	}
	
	public function ToData():StructDataUIGroup
	{
		
		var componentsData:Array <StructDataUIComponent> = [];
		for (member in members)
			if (!Std.is(member, BeardGroup)){ 
				if (Std.is(member, UIContainer)) componentsData = componentsData.concat(cast(member, UIContainer).ToDeepData());
				else componentsData.push( cast(member, IUIComponent).ToData());
				
			}
		
		
		var data:StructDataUIGroup = 
		{
			name : this.name,
			type: Type.getClassName(Type.getClass(this)),
			canRender: this.canRender,
			parentGroup: this.group,
			subGroupsData: [for(member in members) if(Std.is(member,UIGroup)) cast(member, UIGroup).ToData()],
			componentsData:componentsData,
			additionalData:""
		}
		
		//trace(componentsData);
		return data; 
		
	}
	
	public function Destroy():Void 
	{
		while (members.length > 0)
			members.Pop();
		members = null;
	}
	
	
	/* INTERFACE beardFramework.interfaces.IBeardyObject */
	
	
	public function Activate():Void 
	{
		
	}
	
	public function DeActivate():Void 
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

	function get_name():String 
	{
		return name;
	}
	
	function set_name(value:String):String 
	{
		return name = value;
	}
		
	function get_canRender():Bool 
	{
		return canRender;
	}
	
	function set_canRender(value:Bool):Bool 
	{
		for (member in members)
			member.canRender = value;
				
		return canRender = value;
	}
	
	
}