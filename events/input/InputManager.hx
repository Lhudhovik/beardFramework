package beardFramework.events.input;
import beardFramework.core.BeardGame;
import beardFramework.events.input.InputAction;
import lime.ui.Gamepad;
import lime.ui.GamepadAxis;
import lime.ui.GamepadButton;
import lime.ui.KeyCode;
import lime.ui.KeyModifier;
import lime.ui.Window;
import openfl.Assets;
import openfl.display.DisplayObject;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.geom.Point;
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
	
	public function Activate(window:Window):Void
	{
		window.onKeyDown.add(OnKeyDown);
		window.onKeyUp.add(OnKeyUp);
		window.onMouseDown.add(OnMouseDown);
		window.onMouseMove.add(OnMouseMove);
		window.onMouseUp.add(OnMouseUp);
		window.onMouseWheel.add(OnMouseWheel);
		
		for (gamepad in Gamepad.devices)
			OnGamepadConnect(gamepad);
			
		Gamepad.onConnect.add(OnGamepadConnect);
		
		
	}
	
	public function ParseInputSettings(data:Xml):Void
	{
		
		for (input in data.elementsNamed("input"))
		{
			CreateAction(input.get("action"), input.get("defaultInput"), [for (action in input.elements()) action.firstChild().toString()]);
		}
		
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
			
			//trace(GetActionsFromInput(inputID));
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
	
	public function OnMouseDown(mouseX:Float, mouseY:Float, clicType:Int):Void
	{
		
		//if (inputs[e.type] != null){
			//trace(e.type);
			//for (action in inputs[e.type]){
				//trace(action);
				//actions[action].Proceed(e.type,"", e);
			//}
		//}
		trace(mouseX + "  " + mouseY + " " +clicType);
		var objects:Array<DisplayObject> = BeardGame.getInstance().stage.getObjectsUnderPoint(new Point(mouseX, mouseY));
		trace( objects[0] != null ? objects[0].name : objects);
	}
	
	public function OnMouseUp(mouseX:Float, mouseY:Float, clicType:Int):Void
	{
		
		//if (inputs[e.type] != null){
			//trace(e.type);
			//for (action in inputs[e.type]){
				//trace(action);
				//actions[action].Proceed(e.type,"", e);
			//}
		//}
		
		trace(mouseX + "  " + mouseY + " " +clicType);
	}
	
	public function OnMouseMove(mouseX:Float, mouseY:Float):Void
	{
		
		//if (inputs[e.type] != null){
			//trace(e.type);
			//for (action in inputs[e.type]){
				//trace(action);
				//actions[action].Proceed(e.type,"", e);
			//}
		//}
		
		//trace(mouseX + "  " + mouseY );
	}
	
	public function OnMouseWheel(value:Float, axisDirection:Float):Void
	{
		
		//if (inputs[e.type] != null){
			//trace(e.type);
			//for (action in inputs[e.type]){
				//trace(action);
				//actions[action].Proceed(e.type,"", e);
			//}
		//}
		
		trace(value + "  " + axisDirection );
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
	
	public function OnKeyUp(key:KeyCode, modifier:KeyModifier):Void
	{
		//need to do the separation with modifier
		//var code:String =String.fromCharCode(key).toUpperCase(); 
		//
		//if (inputs[code] != null){
			//
			//for (action in inputs[code]){
				//
				//actions[action].Proceed(code, e.type, e);
				//
			//}
			//
		//}
		
		trace(key);
		
	}
	
	public function OnKeyDown(key:KeyCode, modifier:KeyModifier):Void
	{
		//need to do the separation with modifier
		//var code:String =String.fromCharCode(key).toUpperCase(); 
		//
		//if (inputs[code] != null){
			//
			//for (action in inputs[code]){
				//
				//actions[action].Proceed(code, e.type, e);
				//
			//}
			//
		//}
			trace(key);
		
		
	}
	
	public function OnGamepadAxisMove(axis:GamepadAxis, value:Float):Void
	{
		
		trace(value);
		
	}
	
	public function OnGamepadButtonUp(button:GamepadButton):Void
	{
		
		//gamepad.onAxisMove
		trace(button.toString());
		
	}
	
	public function OnGamepadButtonDown(button:GamepadButton):Void
	{
		
		//gamepad.onAxisMove
		trace(button.toString());
	}
	
	public function OnGamepadConnect(gamepad:Gamepad):Void
	{
		trace('gamepad ' + gamepad.id + ' ('+ gamepad.name + ') connected');
		gamepad.onAxisMove.add(OnGamepadAxisMove);
		gamepad.onButtonDown.add(OnGamepadButtonDown);
		gamepad.onButtonUp.add(OnGamepadButtonUp);
		gamepad.onDisconnect.add(OnGamepadDisconnect);
	}
	
	public function OnGamepadDisconnect():Void
	{
		
		
		
	}
	
	//
	//public function OnTouchEvent(e:TouchEvent):void
	//{
	////TO DO
	//}
		
		

	
}



