package beardFramework.display.ui;
import beardFramework.core.BeardGame;
import beardFramework.core.system.thread.ParamThreadDetail;
import beardFramework.core.system.thread.RowThreadDetail;
import beardFramework.core.system.thread.Thread;
import beardFramework.core.system.thread.ThreadDetail;
import beardFramework.display.core.BeardLayer;
import beardFramework.display.core.BeardSprite;
import beardFramework.display.ui.components.UIContainer;
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
		UILayer = BeardGame.Get().GetUILayer();
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
			UILayer.addChild(cast(component, DisplayObject));
		
		AddToGroup(component, group);
	}
	
	public function RemoveComponent(component:IUIComponent):Void
	{
		if (Std.is(component, UIContainer)){
			cast(component, UIContainer).visible = false;
			for (element in cast(component, UIContainer).components)	RemoveComponent(element);
		}
		else UILayer.removeChild(cast(component, DisplayObject));
		
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
			templateData.subGroupsData.unshift(templateData);
		}
			
						
		while (templateData.subGroupsData.length > 0)
		{
			if (savedGroups != null && savedGroups[templateData.subGroupsData[0].name] != null)
				groupData = savedGroups[templateData.subGroupsData[0].name];
			else groupData = templateData.subGroupsData[0];
			
			if ((group = GetUIGroup(groupData.name)) == null){
				group = new UIGroup(groupData.name);
				if(groupData.parentGroup != "") AddToGroup(group, groupData.parentGroup);				
				templateData.subGroupsData = templateData.subGroupsData.concat(groupData.subGroupsData);
			}
				
			while (groupData.componentsData.length > 0)
			{
				
				componentData = groupData.componentsData[0];
				
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
					
				groupData.componentsData.shift();
				
				componentData = null;
				
				td.progression ++; //to handle
				
				if (td.TimeExpired()) return false;
				
			}
			
			templateData.subGroupsData.shift();
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