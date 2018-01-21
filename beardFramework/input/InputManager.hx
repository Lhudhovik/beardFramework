package beardFramework.input;


import beardFramework.core.BeardGame;
import beardFramework.input.Action.CallbackDetails;
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
	private static var directMode:Bool = false;
	public static inline var CLICK_DELAY:Float = 250;
	public static inline var GAMEPAD_PRESS_DELAY:Float = 250;
	public static inline var KEY_PRESS_DELAY:Float = 250;
	private var inputActions:Map<String, Map<InputType, Array<String>>>;
	//private var actions:Map<String, Map<InputType, Map<String, Action>>>;
	private var actions:Map<String, Action>;
	private var handledInputs:Map<String, Input>;
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
		actions = new Map<String,Action>();
		handledInputs = new Map<String, Input>();
		inputActions = new Map<String, Map<InputType, Array<String>>>();
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
			
			//action : StringLibrary.MOUSE_OVER --> "Mouse_Over"
			//inputID :StringLibrary.BASE_MOUSE --> "Mouse"
			LinkActionToInput(StringLibrary.MOUSE_OVER,StringLibrary.MOUSE_OVER, InputType.MOUSE_OVER);
			LinkActionToInput(StringLibrary.MOUSE_OUT,StringLibrary.MOUSE_OUT, InputType.MOUSE_OUT);
			LinkActionToInput(StringLibrary.MOUSE_MOVE,StringLibrary.MOUSE_MOVE, InputType.MOUSE_MOVE);
			LinkActionToInput(StringLibrary.MOUSE_WHEEL, StringLibrary.MOUSE_WHEEL, InputType.MOUSE_WHEEL);
			
			for (i in 0...(Std.parseInt(data.get("mouseButtons")))){
				// action : StringLibrary.MOUSE_CLICK+i --> "Mouse_Up" + i 
				// inputID : GetMouseInputID(i) --> "MouseButton" + i; 
				LinkActionToInput(StringLibrary.MOUSE_CLICK+i, GetMouseInputID(i), InputType.MOUSE_CLICK);
				LinkActionToInput(StringLibrary.MOUSE_DOWN+i, GetMouseInputID(i), InputType.MOUSE_DOWN);
				LinkActionToInput(StringLibrary.MOUSE_UP+i, GetMouseInputID(i), InputType.MOUSE_UP);
			}
			
		}
		
	}
	
		
	public function DeleteAction(actionID : String):Void
	{
		
		
	}
	
	public function LinkActionToInput(actionID : String, inputID:String, inputType:InputType, ?compatibleActionsIDs : Array<String> = null):Void 
	{
		//create the input if not existing
		
		if (handledInputs[inputID] == null){
			var input:Input = {ID:inputID, state:InputType.NONE, value:0, target:"", toggle:GetToggleType(inputType), active:true};
			handledInputs[inputID] = input;
		}
		
		//create the action if not existing
		if(actions[actionID] == null ) actions[actionID] = { ID:actionID, active:true, callbackDetails:[]};	
		
		//create the link if not existing
		if (inputActions[inputID] == null) inputActions[inputID] = new Map<InputType, Array<String>>();
		if (inputActions[inputID][inputType] == null) inputActions[inputID][inputType] = new Array<String>();
		
		if(inputActions[inputID][inputType].indexOf(actionID) == -1) inputActions[inputID][inputType].push(actionID);
		
		
		trace(handledInputs);
	}
	
	public function UnlinkActionFromInput(actionID:String, inputID:String, inputType:InputType):Void 
	{
		
		if (inputActions[inputID] != null && inputActions[inputID][inputType] != null && inputActions[inputID][inputType].indexOf(actionID) != -1)
		{
			inputActions[inputID][inputType].remove(actionID);
		
		}
		
		
	}
	
	public function BindAction(actionID : String, callback:Float -> Void, targetName:String="", once :Bool = false, active : Bool = true):Void
	{
		
		if (actions[actionID] == null){
			actions[actionID] = { ID:actionID, active:true, callbackDetails:[]};	
			
			trace("/!\\ New action created via BindAction");
		}
		
		if (!CheckDetailExisting(actions[actionID] , callback, targetName))
		{
			actions[actionID].callbackDetails.push({ callback:callback, targetName:targetName,once:once });
			
			
		}
		
		actions[actionID].active = active;
		
		
	}
	
	public function UnbindAction(actionID : String, callback:Float -> Void = null, targetName:String = ""):Void
	{
		
		if (actions[actionID] != null)			
			for (detail in actions[actionID].callbackDetails)
				if (detail.callback == callback && detail.targetName == targetName)
				{
					
					actions[actionID].callbackDetails.remove(detail);
					
					detail.callback = null;
					detail = null;
				}
	}
	
	public function ActivateAction(actionID:String, activate : Bool):Void
	{
		
		
	}
	
	//public function GetActionsFromInput(inputID:String):Array<String>
	//{
		//
		//
		//
	//}
	//
	//public function GetInputsFromAction(actionID:String):Array<String>
	//{
		//
		//
	//}
		
	public function OnMouseDown(mouseX:Float, mouseY:Float, mouseButton:Int):Void
	{
		
		utilString = GetMouseInputID(mouseButton);
		
		if (handledInputs[utilString] != null)
		{
			
			
			
			
			timeCounters[utilString] = Date.now().getTime();
		
			var object:DisplayObject= BeardGame.Game().getTargetUnderPoint(utilPoint);
		
			mouseDownTargetName = object != null ? object.name : "";
			
			handledInputs[utilString].state = InputType.MOUSE_DOWN;		
			
			handledInputs[utilString].target = mouseDownTargetName;
			
		}
		
		
	}
	
	public function OnMouseUp(mouseX:Float, mouseY:Float, mouseButton:Int):Void
	{
		//Mouse UP
		utilString =  GetMouseInputID(mouseButton);
		utilPoint.setTo(mouseX, mouseY);
		
		var object:DisplayObject = BeardGame.Game().getTargetUnderPoint(utilPoint);
		mouseDownTargetName = object != null ? object.name : "";
		
		if (handledInputs[utilString] != null)
		{
			
			handledInputs[utilString].state = InputType.MOUSE_UP;		
			
			handledInputs[utilString].target = mouseDownTargetName;
			
		}
	
		
		//Mouse Click
		
		if (Date.now().getTime() - timeCounters[utilString]  <= CLICK_DELAY && 	handledInputs[utilString] != null )
		{
			handledInputs[utilString].state = InputType.MOUSE_CLICK;		
			
		}
		
		timeCounters[utilString] = 0;
		
	}
	
	public function OnMouseMove(mouseX:Float, mouseY:Float):Void
	{
		
		//
		utilString = StringLibrary.MOUSE_MOVE;
		utilPoint.setTo(mouseX, mouseY);
		
		if (handledInputs[utilString] != null)
		{
			
			handledInputs[utilString].state = InputType.MOUSE_MOVE;		
			
		}
		
		if (CheckInputHandled(GetStringFromInputType(InputType.MOUSE_OVER)) || CheckInputHandled(GetStringFromInputType( InputType.MOUSE_OUT)) ){
			
			
			var object:DisplayObject = BeardGame.Game().getTargetUnderPoint(utilPoint);
			
			
			if (object != null && mouseMoveTargetName != object.name){
				
				//trace("previous  " +mouseMoveTargetName);
				//trace("new " +objects[0].name);
				handledInputs[StringLibrary.MOUSE_OVER].state = InputType.MOUSE_OVER;
				handledInputs[StringLibrary.MOUSE_OVER].target = object.name;
				
				
				handledInputs[StringLibrary.MOUSE_OUT].state = InputType.MOUSE_OUT;
				handledInputs[StringLibrary.MOUSE_OUT].target = mouseMoveTargetName;
		
				mouseMoveTargetName = object.name;
			}
			else if (object == null){
				
				handledInputs[StringLibrary.MOUSE_OUT].state = InputType.MOUSE_OUT;
				handledInputs[StringLibrary.MOUSE_OUT].target = mouseMoveTargetName;
					
				mouseMoveTargetName = "";
			}
			
			
		}
		
		
	}	
	
	public function OnMouseWheel(value:Float, axisDirection:Float):Void
	{
			handledInputs[StringLibrary.MOUSE_WHEEL].state = InputType.MOUSE_WHEEL;
			handledInputs[StringLibrary.MOUSE_WHEEL].value = axisDirection;
				
	}
		
	public function OnKeyUp(key:KeyCode, modifier:KeyModifier):Void
	{
		//Key Up
		utilString = String.fromCharCode(key);
		
		modifier.capsLock = modifier.numLock = false;
		
		if (cast(modifier,Int) > 0) utilString += modifier;
		
		
		if (handledInputs[utilString] != null){
			
			handledInputs[utilString].state = InputType.KEY_UP;
			handledInputs[utilString].value = 0;
			
		}
	
		
		//Check Key Pressed
		
		utilString = String.fromCharCode(key); 
		
		if (Date.now().getTime() - timeCounters[utilString] <= KEY_PRESS_DELAY){
			
			modifier.capsLock = modifier.numLock = false;
			if (cast(modifier,Int) > 0)utilString += modifier;
		
			if (handledInputs[utilString] != null){
			
				handledInputs[utilString].state = InputType.KEY_PRESS;
				handledInputs[utilString].value = 0.5;
			
			}
			
		}
		
		
		timeCounters[String.fromCharCode(key)] = 0;
		
		
	}
	
	public function OnKeyDown(key:KeyCode, modifier:KeyModifier):Void
	{
		utilString = String.fromCharCode(key);
		trace(String.fromCharCode(key));
		if( timeCounters[utilString] == null || timeCounters[utilString] == 0) timeCounters[utilString] = Date.now().getTime();
		
		modifier.capsLock = modifier.numLock = false;
		if (cast(modifier,Int) > 0)utilString += modifier;
		
		if (handledInputs[utilString] != null){
			
			handledInputs[utilString].state = InputType.KEY_DOWN;
			handledInputs[utilString].value = 1;
			
		}
		
		
	}
	//TEMP
	public function OnGamepadAxisMove(axis:GamepadAxis, value:Float):Void
	{
		
	}
	
	public function OnGamepadButtonUp(button:GamepadButton):Void
	{
		
		
	}
	
	public function OnGamepadButtonDown(button:GamepadButton):Void
	{
		
		
	}
	
	public function OnGamepadConnect(gamepad:Gamepad):Void
	{
		
		//BeardGame.Game().stage.window.application.
		//trace('gamepad ' + gamepad.id + ' ('+ gamepad.name + ') connected');
		gamepad.onAxisMove.add(	
			function(axis:GamepadAxis, value:Float):Void
			{
				utilString = GetGamepadInputID(gamepad.id, axis.toString());
				if (handledInputs[utilString] != null){
						
					handledInputs[utilString].state = InputType.GAMEPAD_AXIS_MOVE;
					handledInputs[utilString].value = value;
						
				}
				
				
			}
		);
		
		
		gamepad.onButtonDown.add(
			function(button:GamepadButton):Void
			{
				utilString = GetGamepadInputID(gamepad.id, button.toString());
				if ( timeCounters[utilString] == null || timeCounters[utilString] == 0) timeCounters[utilString] = Date.now().getTime();
				
				if (handledInputs[utilString] != null){
						
					handledInputs[utilString].state = InputType.GAMEPAD_BUTTON_DOWN;
					handledInputs[utilString].value = 1;
						
				}
				
				
			}
		);
		
		
		gamepad.onButtonUp.add(
			function(button:GamepadButton):Void
			{
				utilString = GetGamepadInputID(gamepad.id, button.toString());
				if (handledInputs[utilString] != null){
						
					handledInputs[utilString].state = InputType.GAMEPAD_BUTTON_UP;
					handledInputs[utilString].value = 0;
						
				}
				
				if (Date.now().getTime() - timeCounters[utilString] <= GAMEPAD_PRESS_DELAY){
				
					if (handledInputs[utilString] != null){
					
						handledInputs[utilString].state = InputType.KEY_PRESS;
						handledInputs[utilString].value = 0.5;
				
					}
				}
			
				timeCounters[utilString] = 0;
			
			}
		
		);
		gamepad.onDisconnect.add(OnGamepadDisconnect);
		//gamepad.onAxisMove.
		
		
	}
	
	public function OnGamepadDisconnect():Void
	{
		
		
		
	}
	
	public function Update():Void
	{
		var i:Int = 0;
		var detail:CallbackDetails;
		
		for (input in handledInputs)
		{
			
			if (!input.active) continue;
			
			if (inputActions[input.ID] != null && inputActions[input.ID][input.state] != null)
			{
				for (actionID in inputActions[input.ID][input.state])
				{
					
					if (actions[actionID] != null){
						if (actions[actionID].active)
						{
							
							i = actions[actionID].callbackDetails.length;
							while (--i >= 0)
							{
								detail = actions[actionID].callbackDetails[i];
								
								if (detail.targetName == input.target || detail.targetName == "")
								{
									detail.callback(input.value);
									if (detail.once) 
									{
										actions[actionID].callbackDetails.remove(detail);
										detail = null;
									}
									
								}
								
							}
							
						}
					}
					
					
				}
			}
			
			if (input.state == input.toggle){
				input.state = InputType.NONE;
				input.value = 0;
			}
		}
	
		
	}
		
	private inline function  CheckDetailExisting(action:Action, callback:Float->Void, target:String):Bool
	{
		var exist:Bool = false;
	
		
		for (detail in action.callbackDetails)
		{
			
			if ( exist = (detail.callback == callback && detail.targetName == target)) 
				break;
			
		}
	
		return exist;
		
	}
	
	private inline function CheckInputHandled(inputID:String):Bool
	{
		return handledInputs[inputID] != null;
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
	public static inline function GetGamepadInputID(gamepadID:Int, inputID : String):String
	{
		return  "Gamepad" +gamepadID + inputID;
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
			case InputType.MOUSE_MOVE: 				string = "MOUSE_MOVE";
			case InputType.MOUSE_OUT: 				string = "MOUSE_OUT";
			case InputType.MOUSE_OVER:				string = "MOUSE_OVER";
			case InputType.MOUSE_WHEEL:				string = "MOUSE_WHEEL";
			case InputType.KEY_UP:					string = "KEY_UP";
			case InputType.KEY_PRESS: 				string = "KEY_PRESS";
			case InputType.KEY_DOWN:				string = "KEY_DOWN";
			case InputType.GAMEPAD_AXIS_MOVE:		string = "GAMEPAD_AXIS_MOVE";
			case InputType.GAMEPAD_BUTTON_UP: 		string = "GAMEPAD_BUTTON_UP";
			case InputType.GAMEPAD_BUTTON_DOWN: 	string = "GAMEPAD_BUTTON_DOWN";
			case InputType.GAMEPAD_BUTTON_PRESS: 	string = "GAMEPAD_BUTTON_PRESS";
			case InputType.NONE: 					string = "NONE";
			
			
		}
		return string;
	}
	
	public static inline function GetToggleType(type:InputType):InputType
	{
		var toggleType :InputType = InputType.NONE;
		switch(type)
		{
			
			case InputType.MOUSE_DOWN: 				toggleType = InputType.MOUSE_UP ; 
			case InputType.MOUSE_CLICK: 			toggleType = InputType.MOUSE_CLICK ; 
			case InputType.MOUSE_UP: 				toggleType = InputType.MOUSE_UP;
			case InputType.MOUSE_MOVE: 				toggleType = InputType.MOUSE_MOVE;
			case InputType.MOUSE_OUT: 				toggleType = InputType.MOUSE_OUT;
			case InputType.MOUSE_OVER:				toggleType = InputType.MOUSE_OVER;
			case InputType.MOUSE_WHEEL:				toggleType = InputType.MOUSE_WHEEL;
			case InputType.KEY_UP:					toggleType = InputType.KEY_UP;
			case InputType.KEY_PRESS: 				toggleType = InputType.KEY_PRESS;
			case InputType.KEY_DOWN:				toggleType = InputType.KEY_UP;
			case InputType.GAMEPAD_AXIS_MOVE:		toggleType = InputType.NONE;
			case InputType.GAMEPAD_BUTTON_UP: 		toggleType = InputType.GAMEPAD_BUTTON_UP;
			case InputType.GAMEPAD_BUTTON_DOWN: 	toggleType = InputType.GAMEPAD_BUTTON_UP;
			case InputType.GAMEPAD_BUTTON_PRESS: 	toggleType = InputType.GAMEPAD_BUTTON_PRESS;
			case InputType.NONE: 					toggleType = InputType.NONE;
			
			
		}
		return toggleType;
	}
	

	
}

