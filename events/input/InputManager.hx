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
	public static inline var MOUSE_MOVE:String = "Mouse_Move";
	public static inline var MOUSE_WHEEL:String = "Mouse_Wheel";
	private var inputs:Map<String, Array<String>>;
	private var actions:Map<String, InputAction>;
	//private var toggleActions:Map<String, Array<String>>;
	private var utilMouseCoordinates:Point;
	private var utilID:String;
	
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
		//toggleActions =new Map<String, Array<String>>();
		utilMouseCoordinates = new Point();
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
			CreateAction(input.get("action"), input.get("defaultInput"), GetInputTypeFromString(input.get("defaultInputType")), [for (action in input.elements()) action.firstChild().toString()]);
		}
		
	}
	
	public function CreateAction(actionID : String, ?defaultInputID : String = "", ?defaultInputType : InputType = null, ?compatibleActionsIDs : Array<String> = null):Void
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
			for (inputDetail in actions[actionID].get_associatedInputs())
				UnlinkActionToInput(actionID, inputDetail.input, inputDetail.type);
			
			actions[actionID].UnLink();
			actions[actionID] = null;
			actions.remove(actionID);
		}
		
		
	}
	
	public function LinkActionToInput(actionID : String, inputID:String, inputType:InputType, toggleType:InputType = null, uniqueLink:Bool = false):Void 
	{
		utilID = inputID + inputType;
		
		if (actions[actionID] != null)
		{
			if (inputs[utilID] == null )
				inputs[utilID] = new Array<String>();
				
			if (inputs[utilID].indexOf(actionID) == -1){
				
				//if only one input for the action is allowed, remove the other linked inputs
				if (uniqueLink){
					
					for (linkedInput in actions[actionID].get_associatedInputs())
						UnlinkActionToInput(actionID, linkedInput.input, linkedInput.type);
				}
				
				//make sure only compatible actions share the input
				for (linkedAction in inputs[utilID]){
					
					if (actions[actionID].get_compatibleActions().indexOf(linkedAction) == -1)
						UnlinkActionToInput(linkedAction, inputID,inputType);
				}
				
				//add the new input
				inputs[utilID].push(actionID);
			
				actions[actionID].AddAssociatedInput(inputID, inputType);
			
				if (toggleType != null)
				{
					
					utilID = actionID + "toggle";
					
					actions[actionID].toggleType = toggleType;
					
					if (actions[utilID] == null) CreateAction(utilID);
					
					LinkActionToInput(utilID, inputID, toggleType);
					
					
				}
				
			}
			
			//trace(GetActionsFromInput(inputID));
		}
		else throw "Non-existing Action";
		
		
	}
	
	public function UnlinkActionToInput(actionID : String, inputID:String, inputType:InputType):Void 
	{
		if (actions[actionID] != null)
		{
			utilID = inputID + inputType;
			
			if (inputs[utilID] != null && inputs[utilID].indexOf(actionID) != -1)
			{
				inputs[utilID].remove(actionID);
				actions[actionID].RemoveAssociatedInput(inputID, inputType);
			}
				
			
		}
	}
	
	public function RegisterActionCallback(actionID : String, callback:Float -> Void, targetName:String="", once :Bool = false, active : Bool = true):Void
	{
		if (actions[actionID] != null && callback != null){
			actions[actionID].Link(callback,once,targetName, active);
			if (actions[actionID].toggleType != null){
				RegisterActionCallback(actionID + "toggle", actions[actionID].toggle, targetName,once);
			}
		}
	}
	
	public function UnregisterActionCallback(actionID : String, callback:Float -> Void = null, targetName:String = ""):Void
	{
		if (actions[actionID] != null && callback != null){
			actions[actionID].UnLink(callback,targetName);
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
		
		return actions[actionID] != null? [for(detail in actions[actionID].get_associatedInputs()) detail.input + " " + detail.type] : null;
		
	}
		
	public function OnMouseDown(mouseX:Float, mouseY:Float, clicType:Int):Void
	{
		utilID =  GetMouseInputID(clicType) + InputType.MOUSE_DOWN;
		utilMouseCoordinates.setTo(mouseX, mouseY);
		var objects:Array<DisplayObject> = BeardGame.getInstance().stage.getObjectsUnderPoint(utilMouseCoordinates);
		
		if (inputs[utilID] != null){
			
			for (action in inputs[utilID]){
				
				actions[action].Proceed(0,  objects[0] != null ? objects[0].name : "");
				//actions[action].activated = !(actions[action].toggleType != null && actions[action].toggleType != InputType.MOUSE_DOWN);
				
			}
		}
		
		
		
		
	}
	
	public function OnMouseUp(mouseX:Float, mouseY:Float, clicType:Int):Void
	{
		utilID =  GetMouseInputID(clicType) + InputType.MOUSE_UP;
		utilMouseCoordinates.setTo(mouseX, mouseY);
		var objects:Array<DisplayObject> = BeardGame.getInstance().stage.getObjectsUnderPoint(utilMouseCoordinates);
		
		if (inputs[utilID] != null){
			
			for (action in inputs[utilID]){
				
				actions[action].Proceed(0, objects[0] != null ? objects[0].name : "");
				//actions[action].activated = !(actions[action].toggleType != null && actions[action].toggleType != InputType.MOUSE_UP);
			}
		}
	}
	
	public function OnMouseMove(mouseX:Float, mouseY:Float):Void
	{
		if (inputs[MOUSE_MOVE] != null){
			
			for (action in inputs[MOUSE_MOVE]){
				
				actions[action].Proceed();
				//actions[action].activated = !(actions[action].toggleType != null && actions[action].toggleType != InputType.MOUSE_MOVE);
			}
		}
	}
	
	public function OnMouseWheel(value:Float, axisDirection:Float):Void
	{
		
		if (inputs[MOUSE_WHEEL] != null){
			
			for (action in inputs[MOUSE_WHEEL]){
				
				actions[action].Proceed(axisDirection);
				//actions[action].activated = !(actions[action].toggleType != null && actions[action].toggleType != InputType.MOUSE_WHEEL);
			}
		}
	}
		
	public function OnKeyUp(key:KeyCode, modifier:KeyModifier):Void
	{
			utilID = String.fromCharCode(key);
		if (cast (modifier, Int) > 0)
			utilID += modifier;
		utilID += InputType.KEY_UP;
		trace("key up");
		if (inputs[utilID] != null){
			
			for (action in inputs[utilID]){
				
				actions[action].Proceed();
				//actions[action].activated = !(actions[action].toggleType != null && actions[action].toggleType != InputType.KEY_UP);
			}
		}
	}
	
	public function OnKeyDown(key:KeyCode, modifier:KeyModifier):Void
	{
		utilID = String.fromCharCode(key);
		if (cast (modifier, Int) > 0)
			utilID += modifier;
		utilID += InputType.KEY_DOWN;
		trace("key down");
		if (inputs[utilID] != null){
			
			for (action in inputs[utilID]){
				
				actions[action].Proceed();
				//actions[action].activated = !(actions[action].toggleType != null && actions[action].toggleType != InputType.KEY_DOWN);
			}
			
		}
		
		
	}
	
	public function OnGamepadAxisMove(axis:GamepadAxis, value:Float):Void
	{
		utilID = axis.toString();
		
		if (inputs[utilID] != null){
			
			for (action in inputs[utilID]){
				
				actions[action].Proceed(value);
				//actions[action].activated = !(actions[action].toggleType != null && actions[action].toggleType != InputType.GAMEPAD_AXIS_MOVE);
			}
			
		}
		
	}
	
	public function OnGamepadButtonUp(button:GamepadButton):Void
	{
		
		utilID = button.toString();
		
		if (inputs[utilID] != null){
			
			for (action in inputs[utilID]){
				
				actions[action].Proceed();
				//actions[action].activated = !(actions[action].toggleType != null && actions[action].toggleType != InputType.GAMEPAD_BUTTON_UP);
			}
			
		}
		
	}
	
	public function OnGamepadButtonDown(button:GamepadButton):Void
	{
		
		utilID = button.toString();
		
		if (inputs[utilID] != null){
			
			for (action in inputs[utilID]){
				
				actions[action].Proceed();
				//actions[action].activated = !(actions[action].toggleType != null && actions[action].toggleType != InputType.GAMEPAD_BUTTON_DOWN);
			}
			
		}
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
	
	public static inline function GetMouseInputID(button : Int):String
	{
		return  "MouseButton" + button;
	}
	
	public static inline function GetInputTypeFromString(type:String):InputType
	{
		var inputType :InputType = InputType.MOUSE_DOWN;
		 switch(type)
		{
			
			case "MOUSE_DOWN" : inputType = InputType.MOUSE_DOWN; 
			case "MOUSE_UP": inputType = InputType.MOUSE_UP;
			case "MOUSE_MOVE":inputType =  InputType.MOUSE_MOVE;
			case "MOUSE_WHEEL":inputType =  InputType.MOUSE_WHEEL;
			case "KEY_UP": inputType = InputType.KEY_UP;
			case "KEY_DOWN":inputType = InputType.KEY_DOWN;
			case "GAMEPAD_AXIS_MOVE":inputType = InputType.GAMEPAD_AXIS_MOVE;
			case "GAMEPAD_BUTTON_UP": inputType = InputType.GAMEPAD_BUTTON_UP;
			case "GAMEPAD_BUTTON_DOWN": inputType = InputType.GAMEPAD_BUTTON_DOWN;
			
			
		}
		return inputType;
	}
	
	

	
}



