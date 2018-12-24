package beardFramework.graphics.ui;
import beardFramework.core.BeardGame;
import beardFramework.graphics.core.Visual;
import beardFramework.updateProcess.thread.ParamThreadDetail;
import beardFramework.updateProcess.thread.RowThreadDetail;
import beardFramework.updateProcess.thread.Thread;
import beardFramework.updateProcess.thread.ThreadDetail;
import beardFramework.graphics.core.BeardLayer;
import beardFramework.graphics.ui.components.UIContainer;
import beardFramework.interfaces.IUIComponent;
import beardFramework.interfaces.IUIGroupable;
import beardFramework.resources.save.SaveManager;
import beardFramework.resources.save.data.DataComponent;
import beardFramework.resources.save.data.DataUIComponent;
import beardFramework.resources.save.data.DataUIGroup;
import beardFramework.resources.save.DataSlot;
import beardFramework.utils.Crypto;
import beardFramework.utils.DataUtils;
import beardFramework.utils.StringLibrary;
import haxe.Json;
import openfl.display.DisplayObject;
import openfl.display.Sprite;
import sys.FileSystem;
import sys.io.File;

/**
 * ...
 * @author Ludo
 */
class UIManager 
{
	private static var instance(default,null):UIManager;
	private var UILayer:BeardLayer;
	private var baseGroup:UIGroup;
	private var templates:Array<DataSlot<DataUIGroup>>;
	private var savedData:AbstractDataUIGroup;
	
	private function new() 
	{
		
	}
	
	public static inline function Get():UIManager
	{
		if (instance == null){
			instance = new UIManager();
			instance.Init();
		}
		return instance;
	}
	
	private function Init():Void
	{
		UILayer = BeardGame.Get().GetLayer(BeardLayerType.UI);
		templates = new Array<DataSlot<DataUIGroup>>();
		baseGroup = new UIGroup("UIBase");
				
		if (!FileSystem.exists(BeardGame.Get().UI_PATH)) FileSystem.createDirectory(BeardGame.Get().UI_PATH);
		for (element in FileSystem.readDirectory(BeardGame.Get().UI_PATH))
		{
			if (element.indexOf(StringLibrary.SAVE_EXTENSION) != -1){
				#if debug
				var groupData:DataUIGroup = haxe.Json.parse(File.getContent(BeardGame.Get().UI_PATH + element));
				#else
				var groupData:DataUIGroup = Crypto.DecodedData(File.getContent(BeardGame.Get().UI_PATH + element));	
				#end
				
				templates.push({
					address:BeardGame.Get().SAVE_PATH + element,
					name: groupData.name,
					data: groupData
				});
			}
		}

	}
	
	public function AddComponent(component:IUIComponent, group:String = "UIBase"):Void
	{
		if (Std.is(component, UIContainer))
			for (element in cast(component, UIContainer).components) AddComponent(element);
		else
			UILayer.Add(cast(component, Visual));
		
		AddToGroup(component, group);
	}
	
	public function RemoveComponent(component:IUIComponent):Void
	{
		if (Std.is(component, UIContainer)){
			cast(component, UIContainer).visible = false;
			for (element in cast(component, UIContainer).components)	RemoveComponent(element);
		}
		else UILayer.Remove(cast(component, Visual));
		
		RemoveFromGroup( component, component.group);
	}
		
	public function AddToGroup(member:IUIGroupable, groupName:String = "UIBase" ):Void
	{
		
		if (groupName == baseGroup.name) baseGroup.Add(member);
		else
		{
			var group:IUIGroupable = baseGroup.GetMember(groupName);
			if (group != null)
				cast(group, UIGroup).Add(member);
		}
			
	}
	
	public function RemoveFromGroup(member:IUIGroupable, groupName:String = "UIBase"):Void
	{
		
		if (groupName == baseGroup.name) baseGroup.Remove(member);
		else
		{
			var group:IUIGroupable = baseGroup.GetMember(groupName);
			if (group != null)
				cast(group, UIGroup).Remove(member);
		}
		
		
	}
	
	public inline function GetUIComponent(componentID:String):IUIComponent
	{
		var member:IUIGroupable = baseGroup.GetMember(componentID);
		return (member != null) ? cast(member, IUIComponent) : null;
	}
	
	public inline function GetUIGroup(groupID:String):UIGroup
	{
		var member:IUIGroupable = baseGroup.GetMember(groupID);
		return (member != null) ? cast(member, UIGroup) : null;
	}
	
	public inline function HideUI():Void
	{
		UILayer.visible = false;
	}
	
	public inline function ShowUI():Void
	{
		UILayer.visible = true;		
	}
	
	public function GetTemplateData(templateID:String):DataUIGroup
	{
		
		if (templateID != null && templateID != "")
		{
			for (templateData in templates)
			{
				if (templateData.name == templateID)
				{
					return templateData.data;					
				}	
			}
		}
		
		return null;
		
	}
	
	public function AddTemplate(templateID:String):Thread
	{
		
		var templateData:DataUIGroup = GetTemplateData(templateID);
		
		if (templateData != null)
		{
			
			var thread:Thread = new Thread("TemplateLoad");
			thread.Add(new RowThreadDetail<AbstractDataUIGroup>(LoadTemplate, [templateData]));
			thread.Start();
			return thread;
		}
		
		return null;
		
	}

	public function LoadTemplate(td:RowThreadDetail<AbstractDataUIGroup>):Bool
	{
		var templateData:DataUIGroup = td.parameter;
		var savedGroups:Map<String,DataUIGroup> = (savedData != null? DataUtils.DataArrayToMap(savedData.subGroupsData) : null);
		var savedComponents:Map<String,DataUIComponent> = (savedData != null? DataUtils.DataArrayToMap(savedData.componentsData) : null);
		
		var componentData :DataUIComponent;
		var groupData:DataUIGroup;
		var group:UIGroup;
		
		if (td.progression == 0)
		{
			savedData = SaveManager.Get().GetSavedGameData(templateData.name, savedData);
			
			templateData.subGroupsData.reverse();
			templateData.subGroupsData.push(templateData);
			
			for (subGroup in templateData.subGroupsData)
				subGroup.componentsData.reverse();
				
			//td.length = templateData.subGroupsData.length + templateData.componentsData.length;
			
		}
			
						
		while (templateData.subGroupsData.length > 0)
		{
			if (savedGroups != null && savedGroups[templateData.subGroupsData[0].name] != null)
				groupData = savedGroups[templateData.subGroupsData[templateData.subGroupsData.length-1].name];
			else groupData = templateData.subGroupsData[templateData.subGroupsData.length-1];
					
			if ((group = GetUIGroup(groupData.name)) == null){
				group = new UIGroup(groupData.name);
				if(groupData.parentGroup != "") AddToGroup(group, groupData.parentGroup);				
				templateData.subGroupsData = templateData.subGroupsData.concat(groupData.subGroupsData);
			}
				
			while (groupData.componentsData.length > 0)
			{
				
				componentData = groupData.componentsData.pop();
				
				//groupData.componentsData = groupData.componentsData.concat(componentData.subComponents);
				
				var component:IUIComponent;
				
				if ((component = GetUIComponent(componentData.name)) == null)
					component = Type.createInstance(Type.resolveClass(componentData.type), []); //to be handled by pool
				
				if (savedComponents != null && savedComponents[componentData.name] != null)
					component.ParseData(savedComponents[componentData.name]);
				else
					component.ParseData(componentData);
				
				if (componentData.parent != "")
					cast(GetUIComponent(componentData.name), UIContainer).Add(component);
				else
					AddComponent(component,group.name);
				
				componentData = null;
				
				td.progression += 1 / td.length;
				
				if (td.TimeExpired()) return false;
				
			}
			
			td.progression += 1/td.length;
			templateData.subGroupsData.pop();
		}
		
		savedComponents = null;
				
		return true;		
	}
	
	public function RegisterTemplate(templateData:DataUIGroup, save:Bool=false):Void
	{
		var slot:DataSlot<DataUIGroup> = null;
		for (dataSlot in templates)
			if (dataSlot.name == templateData.name)
				slot = dataSlot;
		
		if (slot == null){
			slot = {
					address:BeardGame.Get().UI_PATH + templateData.name + StringLibrary.SAVE_EXTENSION,
					name:templateData.name,
					data: templateData
				}
		}
		else
		{
			slot.data = templateData;
		}
		
		if (save)  
		#if debug
				
			File.saveContent(slot.address, haxe.Json.stringify(slot.data));
	
			
			#else
			File.saveContent(slot.address, Crypto.EncodeData(slot.data));
		#end
		
	}
		
	public function ClearUI(td:ThreadDetail):Bool
	{
		
		if (td.progression == 0)
			baseGroup.members.reverse();
		
		var member:IUIGroupable;
		while (baseGroup.members.length > 0)
		{
			
			member = baseGroup.members.pop();
			
			if (Std.is(member, UIGroup))
			{
				baseGroup.members = baseGroup.members.concat(cast(member, UIGroup).members);
				cast(member, UIGroup).members = null;
			}
			else
			{
				
				if (Std.is(member, UIContainer))
				{
					if (cast(member, UIContainer).components != null)
					{
						while (cast(member, UIContainer).components.length > 0)
						baseGroup.members.push(cast(member, UIContainer).components.pop());
					}
					cast(member, UIContainer).components = null;
				}
				else
				{
					RemoveComponent(cast member);
					member.Clear();
				}
				
				
			}
		
			member = null;
		
			td.progression += 1 / baseGroup.members.length;
			
			if (td.TimeExpired()) return false;
			
		}
		
	
		//do stuff depending on "preserved" or not
		
		return true;
	}
	
	public function Update():Void
	{
		
		//if (templateLoadingThread != null && templateLoadingThread.isEmpty() == false) templateLoadingThread.Proceed();
	
	}
	
	//public function TraceState():Void
	//{
		//var string:String = "UI state : \n";
		//string += "UILayer visibility : " + UILayer.visible +"\n";
		//string += "Base group visibility : " + baseGroup.visible + "\n";
		//for (member in baseGroup.members)
			//string += "Group " + member.name + " visibility : " + member.visible + "\n";
		//
			//trace(string);
		//
		//
		//
		//
	//}
	//
}