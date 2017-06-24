package beardFramework.displaySystem.ui;
import beardFramework.core.BeardGame;
import beardFramework.displaySystem.ui.components.UIContainer;
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
	private var UILayer:Sprite;
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
		UILayer = BeardGame.Game().GetUILayer();
	}
	
	public function AddContainer(container:UIContainer):Void
	{
		for (element in container.elements)
		{
			if (Type.getClass(element) == UIContainer)
				AddContainer(cast(element, UIContainer));
			else UILayer.addChild(cast(element, DisplayObject));
		
		}
	}
	
	
	
}