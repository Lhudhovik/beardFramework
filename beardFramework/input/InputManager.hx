package beardFramework.input;


import beardFramework.core.BeardGame;
import beardFramework.input.Action.CallbackDetails;
import beardFramework.utils.StringLibrary;
import lime.ui.Gamepad;
import lime.ui.GamepadAxis;
import lime.ui.GamepadButton;
import lime.ui.KeyCode;
import lime.ui.KeyModifier;
import lime.ui.Touch;
import lime.ui.Window;
import openfl.Assets;
import openfl.display.DisplayObject;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.geom.Point;
import openfl.ui.GameInput;
import openfl.ui.Keyboard;

using beardFramework.input.GamepadHandler;

/**
 * ...
 * @author Ludo
 */
class InputManager
{

	private static var instance(default,null):InputManager;
	public static var directMode(default,null):Bool = false;
	public static inline var CLICK_DELAY:Float = 250;
	public static inline var TAP_DELAY:Float = 250;
	public static inline var GAMEPAD_PRESS_DELAY:Float = 250;
	public static inline var KEY_PRESS_DELAY:Float = 250;
	public static inline var GAMEPAD_AXIS_MOVEMENT_CEIL:Float = 0.1;

	private var inputActions:Map<String, Map<InputType, Array<String>>>;
	private var actions:Map<String, Action>;
	private var handledInputs:Map<String, Input>;
	private var touches:Map<Int, Touch>;
	private var timeCounters:Map<String, Float>;
	private var utilPoint:Point;
	private var utilString:String;
	private var mouseMoveTargetName:String;
	private var mouseDownTargetName:String;
	
	
	private function new() 
	{
		
	}
	
	public static function Get():InputManager
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
		touches = new Map<Int, Touch>();
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
		Touch.onStart.add();
		Touch.onMove.add();
		Touch.onEnd.add();
	
		for (gamepad in Gamepad.devices)
			OnGamepadConnect(gamepad);
			
		Gamepad.onConnect.add(OnGamepadConnect);
		
		
	}
	
	public function ParseInputSettings(data:Xml):Void
	{
		
		for (input in data.elementsNamed(StringLibrary.INPUT))
		{
			if (input.get(StringLibrary.INPUT_DEFAULT_TYPE).indexOf(StringLibrary.GAMEPAD) != -1)				
				if (Std.parseInt(input.get(StringLibrary.GAMEPAD_ID)) == -1)
					for (i in 0...(Std.parseInt(data.get(StringLibrary.GAMEPAD_MAX))))
						LinkActionToInput(input.get(StringLibrary.ACTION), GetGamepadInputID(i, input.get(StringLibrary.INPUT_DEFAULT)) , GetInputTypeFromString(input.get(StringLibrary.INPUT_DEFAULT_TYPE)));
					
				else
					LinkActionToInput(input.get(StringLibrary.ACTION), GetGamepadInputID(Std.parseInt(input.get(StringLibrary.GAMEPAD_ID)), input.get(StringLibrary.INPUT_DEFAULT)) , GetInputTypeFromString(input.get(StringLibrary.INPUT_DEFAULT_TYPE)));
			else 
				LinkActionToInput(input.get(StringLibrary.ACTION), input.get(StringLibrary.INPUT_DEFAULT), GetInputTypeFromString(input.get(StringLibrary.INPUT_DEFAULT_TYPE)));
		}
		
		if (data.get(StringLibrary.MOUSE) == "true"){
			
			//action : StringLibrary.MOUSE_OVER --> "Mouse_Over"
			//inputID :StringLibrary.MOUSE_OVER --> "Mouse_Over"
			LinkActionToInput(StringLibrary.MOUSE_OVER,StringLibrary.MOUSE_OVER, InputType.MOUSE_OVER);
			LinkActionToInput(StringLibrary.MOUSE_OUT,StringLibrary.MOUSE_OUT, InputType.MOUSE_OUT);
			LinkActionToInput(StringLibrary.MOUSE_MOVE,StringLibrary.MOUSE_MOVE, InputType.MOUSE_MOVE);
			LinkActionToInput(StringLibrary.MOUSE_WHEEL, StringLibrary.MOUSE_WHEEL, InputType.MOUSE_WHEEL);
			
			for (i in 0...(Std.parseInt(data.get(StringLibrary.MOUSE_BUTTONS)))){
				// action : StringLibrary.MOUSE_CLICK+i --> "Mouse_Click" + i 
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
		
		
		trace(actionID + " linked to " + inputID + "  on " + GetStringFromInputType(inputType) );
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
		//
	public function OnMouseDown(mouseX:Float, mouseY:Float, mouseButton:Int):Void
	{
		
		utilString = GetMouseInputID(mouseButton);
		
		if (handledInputs[utilString] != null)
		{
			
			timeCounters[utilString] = Date.now().getTime();
		
			var object:DisplayObject= BeardGame.Get().getTargetUnderPoint(utilPoint);
		
			mouseDownTargetName = object != null ? object.name : "";
			
			handledInputs[utilString].state = InputType.MOUSE_DOWN;		
			
			handledInputs[utilString].target = mouseDownTargetName;
			
			if (directMode) DirectResolveInput(	handledInputs[utilString]);
			
		}
		
		
	}
	
	public function OnMouseUp(mouseX:Float, mouseY:Float, mouseButton:Int):Void
	{
		//Mouse UP
		utilString =  GetMouseInputID(mouseButton);
		utilPoint.setTo(mouseX, mouseY);
		
		var object:DisplayObject = BeardGame.Get().getTargetUnderPoint(utilPoint);
		mouseDownTargetName = object != null ? object.name : "";
		
		if (handledInputs[utilString] != null)
		{
			
			handledInputs[utilString].state = InputType.MOUSE_UP;		
			
			handledInputs[utilString].target = mouseDownTargetName;
			
			if (directMode) DirectResolveInput(	handledInputs[utilString]);
			
		}
	
		
		//Mouse Click
		
		if (Date.now().getTime() - timeCounters[utilString]  <= CLICK_DELAY && 	handledInputs[utilString] != null )
		{
			handledInputs[utilString].state = InputType.MOUSE_CLICK;		
			if (directMode) DirectResolveInput(	handledInputs[utilString]);
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
			if (directMode) DirectResolveInput(	handledInputs[utilString]);
		}
		
		if (CheckInputHandled(GetStringFromInputType(InputType.MOUSE_OVER)) || CheckInputHandled(GetStringFromInputType( InputType.MOUSE_OUT)) ){
			
			
			var object:DisplayObject = BeardGame.Get().getTargetUnderPoint(utilPoint);
			
			
			if (object != null && mouseMoveTargetName != object.name){
				
				//trace("previous  " +mouseMoveTargetName);
				//trace("new " +objects[0].name);
				handledInputs[StringLibrary.MOUSE_OVER].state = InputType.MOUSE_OVER;
				handledInputs[StringLibrary.MOUSE_OVER].target = object.name;
				
				
				handledInputs[StringLibrary.MOUSE_OUT].state = InputType.MOUSE_OUT;
				handledInputs[StringLibrary.MOUSE_OUT].target = mouseMoveTargetName;
		
				mouseMoveTargetName = object.name;
				
				if (directMode) DirectResolveInput(	handledInputs[StringLibrary.MOUSE_OVER]);
				if (directMode) DirectResolveInput(	handledInputs[StringLibrary.MOUSE_OUT]);
				
			}
			else if (object == null){
				
				handledInputs[StringLibrary.MOUSE_OUT].state = InputType.MOUSE_OUT;
				handledInputs[StringLibrary.MOUSE_OUT].target = mouseMoveTargetName;
					
				mouseMoveTargetName = "";
				
				if (directMode) DirectResolveInput(	handledInputs[StringLibrary.MOUSE_OUT]);
			}
			
			
		}
		
		
	}	
	
	public function OnMouseWheel(value:Float, axisDirection:Float):Void
	{
			handledInputs[StringLibrary.MOUSE_WHEEL].state = InputType.MOUSE_WHEEL;
			handledInputs[StringLibrary.MOUSE_WHEEL].value = axisDirection;
			handledInputs[StringLibrary.MOUSE_WHEEL].target = mouseMoveTargetName;
			if (directMode) DirectResolveInput(	handledInputs[StringLibrary.MOUSE_WHEEL]);
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
			if (directMode) DirectResolveInput(	handledInputs[utilString]);
		}
	
		
		//Check Key Pressed
		
		utilString = String.fromCharCode(key); 
		
		if (Date.now().getTime() - timeCounters[utilString] <= KEY_PRESS_DELAY){
			
			modifier.capsLock = modifier.numLock = false;
			if (cast(modifier,Int) > 0) utilString += modifier;
		
			if (handledInputs[utilString] != null){
			
				handledInputs[utilString].state = InputType.KEY_PRESS;
				handledInputs[utilString].value = 0.5;
				if (directMode) DirectResolveInput(	handledInputs[utilString]);
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
			if (directMode) DirectResolveInput(	handledInputs[utilString]);
		}
		
		
	}
	
	public function OnGamepadAxisMove(gamepadID:Int, axis:GamepadAxis, value:Float):Void
	{
		utilString = GetGamepadInputID(gamepadID, axis.toString());
		if (handledInputs[utilString] != null){
				
			handledInputs[utilString].state = InputType.GAMEPAD_AXIS_MOVE;
			handledInputs[utilString].value = value;
			if (directMode) DirectResolveInput(	handledInputs[utilString]);	
		}
		trace(utilString);
		
	}
	
	public function OnGamepadButtonUp(gamepadID:Int, button:GamepadButton):Void
	{
		utilString = GetGamepadInputID(gamepadID, button.toString());
		if (handledInputs[utilString] != null){
				
			handledInputs[utilString].state = InputType.GAMEPAD_BUTTON_UP;
			handledInputs[utilString].value = 0;
			if (directMode) DirectResolveInput(	handledInputs[utilString]);
		}
		
		if (Date.now().getTime() - timeCounters[utilString] <= GAMEPAD_PRESS_DELAY){
		
			if (handledInputs[utilString] != null){
			
				handledInputs[utilString].state = InputType.KEY_PRESS;
				handledInputs[utilString].value = 0.5;
				if (directMode) DirectResolveInput(	handledInputs[utilString]);
			}
		}
	
		timeCounters[utilString] = 0;
		
	}
	
	public function OnGamepadButtonDown(gamepadID:Int,button:GamepadButton):Void
	{
		utilString = GetGamepadInputID(gamepadID, button.toString());
	
		
		if ( timeCounters[utilString] == null || timeCounters[utilString] == 0) timeCounters[utilString] = Date.now().getTime();
		
		if (handledInputs[utilString] != null){
				
			handledInputs[utilString].state = InputType.GAMEPAD_BUTTON_DOWN;
			handledInputs[utilString].value = 1;
			if (directMode) DirectResolveInput(	handledInputs[utilString]);	
		}
		
		
	}
	
	public function OnGamepadConnect(gamepad:Gamepad):Void
	{
		gamepad.onAxisMove.add(gamepad.AxisMove);
		gamepad.onButtonDown.add(gamepad.ButtonDown);
		gamepad.onButtonUp.add(gamepad.ButtonUp);
		gamepad.onDisconnect.add(gamepad.Disconnect);
		
	}
	
	public function OnGamepadDisconnect(gamepad:Gamepad):Void
	{
		
		gamepad.onAxisMove.remove(gamepad.AxisMove);
		gamepad.onButtonDown.remove(gamepad.ButtonDown);
		gamepad.onButtonUp.remove(gamepad.ButtonUp);
		gamepad.onDisconnect.remove(gamepad.Disconnect);
		
	}
	
	public function OnTouchStart(touch:Touch):Void
	{
		utilString = StringLibrary.TOUCH + touch.id;
		
		if (handledInputs[utilString] != null)
		{
			
			timeCounters[utilString] = Date.now().getTime();
		
			var object:DisplayObject= BeardGame.Get().getTargetUnderPoint(utilPoint);
		
			mouseDownTargetName = object != null ? object.name : "";
			
			handledInputs[utilString].state = InputType.TOUCH_START;		
			
			handledInputs[utilString].target = mouseDownTargetName;
			
			if (directMode) DirectResolveInput(	handledInputs[utilString]);
			
		}
		
	}
	
	public function OnTouchMove(touch:Touch):Void
	{
		utilString = StringLibrary.TOUCH + touch.id;
		utilPoint.setTo(mouseX, mouseY);
		
		if (handledInputs[utilString] != null)
		{
			
			handledInputs[utilString].state = InputType.TOUCH_MOVE;		
			if (directMode) DirectResolveInput(	handledInputs[utilString]);
		}
		
		//if (CheckInputHandled(GetStringFromInputType(InputType.TOUCH_OVER)) || CheckInputHandled(GetStringFromInputType( InputType.TOUCH_OUT)) ){
			//
			//
			//var object:DisplayObject = BeardGame.Get().getTargetUnderPoint(utilPoint);
			//
			//
			//if (object != null && mouseMoveTargetName != object.name){
				//
				////trace("previous  " +mouseMoveTargetName);
				////trace("new " +objects[0].name);
				//handledInputs[StringLibrary.TOUCH_OVER].state = InputType.TOUCH_OVER;
				//handledInputs[StringLibrary.TOUCH_OVER].target = object.name;
				//
				//
				//handledInputs[StringLibrary.TOUCH_OUT].state = InputType.MOUSE_OUT;
				//handledInputs[StringLibrary.TOUCH_OUT].target = mouseMoveTargetName;
		//
				//mouseMoveTargetName = object.name;
				//
				//if (directMode) DirectResolveInput(	handledInputs[StringLibrary.MOUSE_OVER]);
				//if (directMode) DirectResolveInput(	handledInputs[StringLibrary.MOUSE_OUT]);
				//
			//}
			//else if (object == null){
				//
				//handledInputs[StringLibrary.MOUSE_OUT].state = InputType.MOUSE_OUT;
				//handledInputs[StringLibrary.MOUSE_OUT].target = mouseMoveTargetName;
					//
				//mouseMoveTargetName = "";
				//
				//if (directMode) DirectResolveInput(	handledInputs[StringLibrary.MOUSE_OUT]);
			//}
			//
			//
		//}
		
		
	}
	
	public function OnTouchEnd(touch:Touch):Void
	{
		
		utilString =  StringLibrary.TOUCH + touch.id;
		utilPoint.setTo(touch.x, touch.y);
		
		var object:DisplayObject = BeardGame.Get().getTargetUnderPoint(utilPoint);
		mouseDownTargetName = object != null ? object.name : "";
		
		if (handledInputs[utilString] != null)
		{
			
			handledInputs[utilString].state = InputType.TOUCH_END;		
			
			handledInputs[utilString].target = mouseDownTargetName;
			
			if(directMode) DirectResolveInput(handledInputs[utilString]);
			
		}
	
		
		//Mouse Click
		
		if (Date.now().getTime() - timeCounters[utilString]  <= TAP_DELAY && 	handledInputs[utilString] != null )
		{
			handledInputs[utilString].state = InputType.TOUCH_TAP;		
			if(directMode) DirectResolveInput(handledInputs[utilString]);
		}
		
		timeCounters[utilString] = 0;
		
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
	
	private function DirectResolveInput(input:Input):Void
	{
		
		if (input.active){
			var i:Int = 0;
			var detail:CallbackDetails;
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
		return  StringLibrary.MOUSE + button;
	}
	
	public static inline function GetGamepadInputID(gamepadID:Int, inputID : String):String
	{
		return  StringLibrary.GAMEPAD + inputID+ gamepadID;
	}
	
	public static inline function GetInputTypeFromString(type:String):InputType
	{
		var inputType :InputType = InputType.MOUSE_DOWN;
		 switch(type)
		{
			
			case StringLibrary.MOUSE_DOWN: 				inputType = InputType.MOUSE_DOWN ; 
			case StringLibrary.MOUSE_CLICK: 			inputType = InputType.MOUSE_CLICK ; 
			case StringLibrary.MOUSE_UP: 				inputType = InputType.MOUSE_UP;
			case StringLibrary.MOUSE_MOVE: 				inputType = InputType.MOUSE_MOVE;
			case StringLibrary.MOUSE_OUT: 				inputType = InputType.MOUSE_OUT;
			case StringLibrary.MOUSE_OVER:				inputType = InputType.MOUSE_OVER;
			case StringLibrary.MOUSE_WHEEL:				inputType = InputType.MOUSE_WHEEL;
			case StringLibrary.KEY_UP:					inputType = InputType.KEY_UP;
			case StringLibrary.KEY_PRESS: 				inputType = InputType.KEY_PRESS;
			case StringLibrary.KEY_DOWN:				inputType = InputType.KEY_DOWN;
			case StringLibrary.GAMEPAD_AXIS_MOVE:		inputType = InputType.GAMEPAD_AXIS_MOVE;
			case StringLibrary.GAMEPAD_BUTTON_UP: 		inputType = InputType.GAMEPAD_BUTTON_UP;
			case StringLibrary.GAMEPAD_BUTTON_DOWN: 	inputType = InputType.GAMEPAD_BUTTON_DOWN;
			case StringLibrary.GAMEPAD_BUTTON_PRESS: 	inputType = InputType.GAMEPAD_BUTTON_PRESS;
			case StringLibrary.TOUCH_END: 				inputType = InputType.TOUCH_END;
			case StringLibrary.TOUCH_MOVE: 				inputType = InputType.TOUCH_MOVE;
			case StringLibrary.TOUCH_START: 			inputType = InputType.TOUCH_START;
			case StringLibrary.TOUCH_TAP: 				inputType = InputType.TOUCH_TAP;
			
			
		}
		return inputType;
	}
	public static inline function GetStringFromInputType(type:InputType):String
	{
		var string :String = StringLibrary.UNKNOWN;
		switch(type)
		{
			
			case InputType.MOUSE_DOWN: 				string = StringLibrary.MOUSE_DOWN ; 
			case InputType.MOUSE_CLICK: 			string = StringLibrary.MOUSE_CLICK ; 
			case InputType.MOUSE_UP: 				string = StringLibrary.MOUSE_UP;
			case InputType.MOUSE_MOVE: 				string = StringLibrary.MOUSE_MOVE;
			case InputType.MOUSE_OUT: 				string = StringLibrary.MOUSE_OUT;
			case InputType.MOUSE_OVER:				string = StringLibrary.MOUSE_OVER;
			case InputType.MOUSE_WHEEL:				string = StringLibrary.MOUSE_WHEEL;
			case InputType.KEY_UP:					string = StringLibrary.KEY_UP;
			case InputType.KEY_PRESS: 				string = StringLibrary.KEY_PRESS;
			case InputType.KEY_DOWN:				string = StringLibrary.KEY_DOWN;
			case InputType.GAMEPAD_AXIS_MOVE:		string = StringLibrary.GAMEPAD_AXIS_MOVE;
			case InputType.GAMEPAD_BUTTON_UP: 		string = StringLibrary.GAMEPAD_BUTTON_UP;
			case InputType.GAMEPAD_BUTTON_DOWN: 	string = StringLibrary.GAMEPAD_BUTTON_DOWN;
			case InputType.GAMEPAD_BUTTON_PRESS: 	string = StringLibrary.GAMEPAD_BUTTON_PRESS;
			case InputType.NONE: 					string = StringLibrary.NONE;
			case InputType.TOUCH_END: 				string = StringLibrary.TOUCH_END;
			case InputType.TOUCH_MOVE: 				string = StringLibrary.TOUCH_MOVE;
			case InputType.TOUCH_START: 			string = StringLibrary.TOUCH_START;
			case InputType.TOUCH_TAP: 				string = StringLibrary.TOUCH_TAP;
			
			
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
			case InputType.TOUCH_END: 				toggleType = InputType.TOUCH_END;
			case InputType.TOUCH_MOVE: 				toggleType = InputType.TOUCH_MOVE;
			case InputType.TOUCH_START: 			toggleType = InputType.TOUCH_END;
			case InputType.TOUCH_TAP: 				toggleType = InputType.TOUCH_TAP;
			
			
		}
		return toggleType;
	}
	
	

	
}




