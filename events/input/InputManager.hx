package beardFramework.events.input;
import beardFramework.events.input.InputAction;
import openfl.Assets;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.ui.GameInput;
import openfl.ui.Keyboard;




/**
 * ...
 * @author Ludo
 */
class InputManager
{

	private static var instance(get,null):InputManager;
	
	private var inputs:Map<String, Array<String>>;
	private var actions:Map<String, InputAction>;
	
	private function new() 
	{
		
	}
	
	public static function get_instance():InputManager
	{
		if (instance == null)
		{
			instance = new InputManager();
			instance.Init();
		}
		
		return instance;
	}
	
	private function Init():Void
	{
		inputs = new Map<String, Array<String>>();
		actions = new Map<String, InputAction>();
	}
	
	public function ParseInputSettings(data:Xml):Void{
			//add keys when parsing settings
	}
	
	public function CreateAction(actionID : String, ?defaultInputID : String = "", ?defaultInputType : String = "", ?compatibleActionsIDs : Array<String> = null):Void
	{
		if (actions[actionID] == null){
			actions[actionID] = new InputAction(compatibleActionsIDs);
			
			for (compatibleID in actions[actionID].get_compatibleActions())
			{
				if (actions[compatibleID] != null) actions[compatibleID].AddCompatibleAction(actionID);
			}
			
			if (defaultInputID != "")
				LinkActionToInput(actionID, defaultInputID, defaultInputType);
			
		}
		
		
	}
	
	public function DeleteAction(actionID : String):Void
	{
		if (actions[actionID] != null){
			for (linkedID in actions[actionID].get_associatedInputs())
				UnlinkActionToInput(actionID, linkedID);
			
			actions[actionID] = null;
			actions.remove(actionID);
		}
		
		
	}
	
	
	public function LinkActionToInput(actionID : String, inputID:String, inputType:String, uniqueLink:Bool = false):Void 
	{
		if (actions[actionID] != null)
		{
			if (inputs[inputID] == null )
				inputs[inputID] = new Array<String>();
				
			if (inputs[inputID].indexOf(actionID) == -1){
				
				//if only one input for the action is allowed, remove the other linked inputs
				if (uniqueLink){
					
					for (linkedInput in actions[actionID].get_associatedInputs())
						UnlinkActionToInput(actionID, linkedInput);
				}
				
				//make sure only compatible actions share the input
				for (linkedAction in inputs[inputID]){
					
					if (actions[actionID].get_compatibleActions().indexOf(linkedAction) == -1)
						UnlinkActionToInput(linkedAction, inputID);
				}
				
				//add the new input
				inputs[inputID].push(actionID);
				actions[actionID].AddAssociatedInput(inputID,inputType);
				
			}
			
			trace(GetActionsFromInput(inputID));
		}
		else throw "Non-existing Action";
		
		
	}
	
	public function UnlinkActionToInput(actionID : String, inputID:String):Void 
	{
		if (actions[actionID] != null)
		{
			if (inputs[inputID] != null && inputs[inputID].indexOf(actionID) != -1)
			{
				
				inputs[inputID].remove(actionID);
				actions[actionID].RemoveAssociatedInput(actionID);
			}
				
			
		}
	}
	
	public function RegisterActionCallback(actionID : String, callback:Event -> Void, active : Bool = true, once :Bool = false):Void
	{
		if (actions[actionID] != null && callback != null){
			actions[actionID].Link(callback, once);
			actions[actionID].activated = active;
		}

	}
	
	public function UnregisterActionCallback(actionID : String, callback:Event -> Void = null):Void
	{
		if (actions[actionID] != null && callback != null){
			actions[actionID].UnLink(callback);
		}

	}
	
	public function ActivateAction(actionID:String, activate : Bool):Void
	{
		if (actions[actionID] != null ){
			actions[actionID].activated = activate;
		}
		
	}
		
	
	public function GetActionsFromInput(inputID:String):Array<String>
	{
		
		return inputs[inputID] != null? inputs[inputID].concat([]) : null;
		
	}
	public function GetInputsFromAction(actionID:String):Array<String>
	{
		
		return actions[actionID] != null? actions[actionID].get_associatedInputs().concat([]) : null;
		
	}
	
	public function OnMouseEvent(e:MouseEvent):Void
	{
		
		if (inputs[e.type] != null){
			trace(e.type);
			for (action in inputs[e.type]){
				trace(action);
				actions[action].Proceed(e.type,"", e);
			}
		}
		
		
	}
	
	public function OnKeyboardEvent(e:KeyboardEvent):Void
	{
		var code:String =String.fromCharCode(e.charCode).toUpperCase(); 
		
		if (inputs[code] != null){
			
			for (action in inputs[code]){
				
				actions[action].Proceed(code, e.type, e);
				
			}
			
		}
		
		
		
	}
	//
	//public function OnTouchEvent(e:TouchEvent):void
	//{
	////TO DO
	//}
		
		

	
}



