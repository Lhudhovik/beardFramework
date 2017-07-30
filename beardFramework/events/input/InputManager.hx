package beardFramework.events.input;
import beardFramework.core.BeardGame;
import beardFramework.events.input.InputAction;
import beardFramework.utils.StringLibrary;
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
	public static inline var CLICK_DELAY:Float = 250;
	public static inline var GAMEPAD_PRESS_DELAY:Float = 250;
	public static inline var KEY_PRESS_DELAY:Float = 250;
	private var inputs:Map<String, Array<String>>;
	private var actions:Map<String, InputAction>;
	private var timeCounters:Map<String, Float>;
	private var utilPoint:Point;
	private var utilString:String;
	private var mouseMoveTargetName:String;
	private var mouseDownTargetName:String;
	
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
		timeCounters = new Map<String, Float>();
		utilPoint = new Point();
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
			LinkActionToInput(input.get("action"), input.get("defaultInput"), GetInputTypeFromString(input.get("defaultInputType")), [for (action in input.elements()) action.firstChild().toString()]);
		}
		
		if (data.get("mouse") == "true"){
			
			LinkActionToInput(StringLibrary.MOUSE_OVER, "", InputType.MOUSE_OVER);
			LinkActionToInput(StringLibrary.MOUSE_OUT, "", InputType.MOUSE_OUT);
			LinkActionToInput(StringLibrary.MOUSE_MOVE, "", InputType.MOUSE_MOVE);
			LinkActionToInput(StringLibrary.MOUSE_WHEEL, "", InputType.MOUSE_WHEEL);
			
			for (i in 0...(Std.parseInt(data.get("mouseButtons")))){
				LinkActionToInput(StringLibrary.MOUSE_CLICK+i, GetMouseInputID(i), InputType.MOUSE_CLICK);
				LinkActionToInput(StringLibrary.MOUSE_DOWN+i, GetMouseInputID(i), InputType.MOUSE_DOWN);
				LinkActionToInput(StringLibrary.MOUSE_UP+i, GetMouseInputID(i), InputType.MOUSE_UP);
			}
			
		}
		
	}
	
		
	public function DeleteAction(actionID : String):Void
	{
		if (actions[actionID] != null){
			for (inputDetail in actions[actionID].get_associatedInputs())
				UnlinkActionFromInput(actionID, inputDetail.input, inputDetail.type);
			
			actions[actionID].UnLink();
			actions[actionID] = null;
			actions.remove(actionID);
		}
		
		
	}
	
	public function LinkActionToInput(actionID : String, inputID:String, inputType:InputType, ?compatibleActionsIDs : Array<String> = null):Void 
	{
		utilString = inputID != "" ? inputID + inputType : GetStringFromInputType(inputType);
		//trace("added input link : " + actionID + " linked to " + utilString);  
		//Create the action if non-existing
		if (actions[actionID] == null){
			actions[actionID] = new InputAction(compatibleActionsIDs);
			
			//make sure every compatible action is aware of each other
			for (compatibleID in actions[actionID].get_compatibleActions())	if (actions[compatibleID] != null) actions[compatibleID].AddCompatibleAction(actionID);
			
		}
		
		//create input action list if non existing
		if (inputs[utilString] == null )
			inputs[utilString] = new Array<String>();
			
		//si l'action n'est pas déjà liée
		if (inputs[utilString].indexOf(actionID) == -1){
			
			
			//make sure only compatible actions share the input
			for (linkedAction in inputs[utilString]){
				
				if (actions[actionID].get_compatibleActions().indexOf(linkedAction) == -1)
					UnlinkActionFromInput(linkedAction, inputID,inputType);
			}
			
			//add the new input
			inputs[utilString].push(actionID);
			actions[actionID].AddAssociatedInput(inputID, inputType);
		
			
			
		}
		
		
	}
	
	public function UnlinkActionFromInput(actionID:String, inputID:String, inputType:InputType):Void 
	{
		if (actions[actionID] != null)
		{
			utilString = inputID + inputType;
			
			if (inputs[utilString] != null && inputs[utilString].indexOf(actionID) != -1)
			{
				inputs[utilString].remove(actionID);
				actions[actionID].RemoveAssociatedInput(inputID, inputType);
			}
				
			
		}
	}
	
	public function RegisterActionCallback(actionID : String, callback:Float -> Void, targetName:String="", once :Bool = false, active : Bool = true):Void
	{
		if (actions[actionID] != null && callback != null){
			actions[actionID].Link(callback, once, targetName);
			actions[actionID].activated = active;
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
		
	public function OnMouseDown(mouseX:Float, mouseY:Float, mouseButton:Int):Void
	{
		utilString =  GetMouseInputID(mouseButton) + InputType.MOUSE_DOWN;
		utilPoint.setTo(mouseX, mouseY);
		
		timeCounters[GetMouseInputID(mouseButton)] = Date.now().getTime();
		
		var object:DisplayObject= BeardGame.Game().getTargetUnderPoint(utilPoint);
		
		mouseDownTargetName = object != null ? object.name : "";
		//trace("mouse down target : " + mouseDownTargetName);
		if (inputs[utilString] != null){
			
			for (action in inputs[utilString])
				if (actions[action].activated)	
					actions[action].Proceed(mouseButton, mouseDownTargetName);
				
		}
		
		
		
		
	}
	
	public function OnMouseUp(mouseX:Float, mouseY:Float, mouseButton:Int):Void
	{
		
		//mouse UP 
		utilString =  GetMouseInputID(mouseButton) + InputType.MOUSE_UP;
		
		utilPoint.setTo(mouseX, mouseY);
		
		var object:DisplayObject = BeardGame.Game().getTargetUnderPoint(utilPoint);
		
		
		if (inputs[utilString] != null){
			
			for (action in inputs[utilString]) 
				if (actions[action].activated) 
					actions[action].Proceed(mouseButton, object != null ? object.name : "");
		}
		
		//Mouse Click
		utilString = GetMouseInputID(mouseButton);
		
		
		
		if (Date.now().getTime() - timeCounters[utilString]  <= CLICK_DELAY)
		{
			utilString += InputType.MOUSE_CLICK;
			
			if( inputs[utilString] != null){
				for (action in inputs[utilString]) 
					if (actions[action].activated) 
						actions[action].Proceed(mouseButton, (object != null && mouseDownTargetName == object.name) ? mouseDownTargetName : "" );
			}
		}
		
		timeCounters[GetMouseInputID(mouseButton)] = 0;
		
		
	}
	
	public function OnMouseMove(mouseX:Float, mouseY:Float):Void
	{
		
		if (inputs[GetStringFromInputType(InputType.MOUSE_MOVE)] != null){
			
			for (action in inputs[GetStringFromInputType(InputType.MOUSE_MOVE)]) 
				if (actions[action].activated) 
					actions[action].Proceed();
			
		}
		
		if (inputs[GetStringFromInputType(InputType.MOUSE_OVER)] != null || inputs[GetStringFromInputType(InputType.MOUSE_OUT)] != null){
			
			utilPoint.setTo(mouseX, mouseY);
			
			var object:DisplayObject = BeardGame.Game().getTargetUnderPoint(utilPoint);
			
			
			if (object != null && mouseMoveTargetName != object.name){
				
				//trace("previous  " +mouseMoveTargetName);
				//trace("new " +objects[0].name);
				if (inputs[GetStringFromInputType(InputType.MOUSE_OVER)] != null){
			
					for (action in inputs[GetStringFromInputType(InputType.MOUSE_OVER)])
						if (actions[action].activated)	
							actions[action].Proceed(0, object.name);
				
				}
				if (inputs[GetStringFromInputType(InputType.MOUSE_OUT)] != null){
			
					for (action in inputs[GetStringFromInputType(InputType.MOUSE_OUT)])
						if (actions[action].activated)	
							actions[action].Proceed(0, mouseMoveTargetName);
				
				}
				
				mouseMoveTargetName = object.name;
			}
			else if (object == null){
				
				if (inputs[GetStringFromInputType(InputType.MOUSE_OUT)] != null){
			
					for (action in inputs[GetStringFromInputType(InputType.MOUSE_OUT)])
						if (actions[action].activated)	
							actions[action].Proceed(0, mouseMoveTargetName);
				
				}
					
				mouseMoveTargetName = "";
			}
			
			
		}
		
	}	
	
	public function OnMouseWheel(value:Float, axisDirection:Float):Void
	{
		
		if (inputs[StringLibrary.MOUSE_WHEEL] != null){
			
			for (action in inputs[StringLibrary.MOUSE_WHEEL])	
				if (actions[action].activated) 
					actions[action].Proceed(axisDirection);

		}
	}
		
	public function OnKeyUp(key:KeyCode, modifier:KeyModifier):Void
	{
		
		//Key Up
		utilString = String.fromCharCode(key);
		
		modifier.capsLock = modifier.numLock = false;
		if (cast(modifier,Int) > 0) utilString += modifier;
		
		utilString += InputType.KEY_UP;
		
		if (inputs[utilString] != null){
			
			for (action in inputs[utilString]) 
				if (actions[action].activated) 
					actions[action].Proceed();
			
		}
		
		//Check Key Pressed
		
		utilString = String.fromCharCode(key);
		
		
		if (Date.now().getTime() - timeCounters[utilString] <= KEY_PRESS_DELAY){
			
			modifier.capsLock = modifier.numLock = false;
			if (cast(modifier,Int) > 0)utilString += modifier;
		
			utilString += InputType.KEY_PRESS;
		
		
			if (inputs[utilString] != null){
			
				for (action in inputs[utilString]) 
					if (actions[action].activated) 
						actions[action].Proceed();
			}
				
		}
		timeCounters[String.fromCharCode(key)] = 0;
		
		
		
	}
	
	public function OnKeyDown(key:KeyCode, modifier:KeyModifier):Void
	{
		utilString = String.fromCharCode(key);
		
		if( timeCounters[utilString] == null || timeCounters[utilString] == 0) timeCounters[utilString] = Date.now().getTime();
		
		modifier.capsLock = modifier.numLock = false;
		if (cast(modifier,Int) > 0)utilString += modifier;
		
		utilString += InputType.KEY_DOWN;
			
		if (inputs[utilString] != null){
			
			for (action in inputs[utilString])
				if (actions[action].activated)	
					actions[action].Proceed();
			
		}
		
		
	}
	
	public function OnGamepadAxisMove(axis:GamepadAxis, value:Float):Void
	{
		utilString = axis.toString();
		
		if (inputs[utilString] != null)
			
			for (action in inputs[utilString]) 
				if (actions[action].activated)
					actions[action].Proceed(value);
		
	}
	
	public function OnGamepadButtonUp(button:GamepadButton):Void
	{
		
		utilString = button.toString() + InputType.GAMEPAD_BUTTON_UP;
		
		if (inputs[utilString] != null){
			
			for (action in inputs[utilString])
				if(actions[action].activated)
					actions[action].Proceed();
			
			
		}
		
		//Check button press
		utilString = button.toString();
		
		if (Date.now().getTime() - timeCounters[utilString] <= GAMEPAD_PRESS_DELAY){
			
			utilString += InputType.GAMEPAD_BUTTON_PRESS;
			
			if (inputs[utilString] != null){
			
				for (action in inputs[utilString]) 
					if (actions[action].activated) 
						actions[action].Proceed();
			}
				
		}
		
		timeCounters[button.toString()] = 0;
		
		
	}
	
	public function OnGamepadButtonDown(button:GamepadButton):Void
	{
		
		utilString = button.toString();
		
		if(timeCounters[utilString] == null || timeCounters[utilString] ==0) timeCounters[utilString] = Date.now().getTime();
		
		utilString += InputType.GAMEPAD_BUTTON_DOWN;
		
		if (inputs[utilString] != null){
			
			for (action in inputs[utilString])
				if(actions[action].activated)
					actions[action].Proceed();
				
		}
	}
	
	public function OnGamepadConnect(gamepad:Gamepad):Void
	{
		//trace('gamepad ' + gamepad.id + ' ('+ gamepad.name + ') connected');
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
			
			case "MOUSE_DOWN" : 		inputType = InputType.MOUSE_DOWN; 
			case "MOUSE_CLICK" : 		inputType = InputType.MOUSE_CLICK; 
			case "MOUSE_UP": 			inputType = InputType.MOUSE_UP;
			case "MOUSE_MOVE":			inputType = InputType.MOUSE_MOVE;
			case "MOUSE_OUT":			inputType = InputType.MOUSE_OUT;
			case "MOUSE_OVER":			inputType = InputType.MOUSE_OVER;
			case "MOUSE_WHEEL":			inputType = InputType.MOUSE_WHEEL;
			case "KEY_UP": 				inputType = InputType.KEY_UP;
			case "KEY_PRESS":			inputType = InputType.KEY_PRESS;
			case "KEY_DOWN":			inputType = InputType.KEY_DOWN;
			case "GAMEPAD_AXIS_MOVE":	inputType = InputType.GAMEPAD_AXIS_MOVE;
			case "GAMEPAD_BUTTON_UP":	inputType = InputType.GAMEPAD_BUTTON_UP;
			case "GAMEPAD_BUTTON_DOWN":	inputType = InputType.GAMEPAD_BUTTON_DOWN;
			case "GAMEPAD_BUTTON_PRESS":inputType = InputType.GAMEPAD_BUTTON_PRESS;
			
			
		}
		return inputType;
	}
	public static inline function GetStringFromInputType(type:InputType):String
	{
		var string :String = "Unknown";
		switch(type)
		{
			
			case InputType.MOUSE_DOWN: 				string = "MOUSE_DOWN" ; 
			case InputType.MOUSE_CLICK: 			string = "MOUSE_CLICK" ; 
			case InputType.MOUSE_UP: 				string = "MOUSE_UP";
			case InputType.MOUSE_MOVE: 				string =  "MOUSE_MOVE";
			case InputType.MOUSE_OUT: 				string =  "MOUSE_OUT";
			case InputType.MOUSE_OVER:				string =  "MOUSE_OVER";
			case InputType.MOUSE_WHEEL:				string =  "MOUSE_WHEEL";
			case InputType.KEY_UP:					string = "KEY_UP";
			case InputType.KEY_PRESS: 				string = "KEY_PRESS";
			case InputType.KEY_DOWN:				string = "KEY_DOWN";
			case InputType.GAMEPAD_AXIS_MOVE:		string = "GAMEPAD_AXIS_MOVE";
			case InputType.GAMEPAD_BUTTON_UP: 		string = "GAMEPAD_BUTTON_UP";
			case InputType.GAMEPAD_BUTTON_DOWN: 	string = "GAMEPAD_BUTTON_DOWN";
			case InputType.GAMEPAD_BUTTON_PRESS: 	string = "GAMEPAD_BUTTON_PRESS";
			
			
		}
		return string;
	}
	

	
}



