package beardFramework.display.ui;
import beardFramework.core.BeardGame;
import beardFramework.display.core.BeardSprite;
import beardFramework.display.ui.components.UIContainer;
import beardFramework.interfaces.IUIComponent;
import openfl.display.DisplayObject;
import openfl.display.Sprite;

/**
 * ...
 * @author Ludo
 */
class UIManager 
{
	private static var instance(get,null):UIManager;
	private var UILayer:BeardSprite;
	private var templates:Map<String, IUIComponent>;
	private function new() 
	{
		
	}
	public static inline function get_instance():UIManager
	{
		if (instance == null){
			instance = new UIManager();
			instance.Init();
		}
		return instance;
	}
	
	private function Init():Void
	{
		UILayer = BeardGame.get_game().GetUILayer();
		templates = new Map<String, IUIComponent>();
	}
	
	public function AddComponent(component:IUIComponent):Void
	{
		if (Std.is(component, UIContainer))	for (element in cast(component, UIContainer).elements)	AddComponent(element);
		else UILayer.addChild(cast(component, DisplayObject));
	}
	
	
	
	public function DisplayTemplate(templateID:String):Bool
	{
		if (templates[templateID] == null)
		{
			if(/*check if the template exists in the XML*/true)
				templates[templateID] = InstanciateTemplate(templateID);			
			else return false;
		}
		
		AddComponent(templates[templateID]);
		
		return true;
		
	}
	
	private function InstanciateTemplate(templateID:String):IUIComponent
	{
		
		//instantiate the thing based on the XML
	return null;
	}
	
	
	public function RegisterTemplate(template:IUIComponent, templateID:String):Void
	{
		if (templates[templateID] != null) templates[templateID].Clear();
		templates[templateID] = template;
		
		//register in XML of file
		
	}
	
	public function ClearUI():Bool
	{
		return true;
		
	}
	//public function DisplayPopup
	
}