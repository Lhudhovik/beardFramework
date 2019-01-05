package beardFramework.input;


import beardFramework.core.BeardGame;
import beardFramework.graphics.core.RenderedObject;
import beardFramework.input.Action.CallbackDetails;
import beardFramework.utils.MinAllocArray;
import beardFramework.utils.StringLibrary;
import lime.app.Application;
import lime.ui.Gamepad;
import lime.ui.GamepadAxis;
import lime.ui.GamepadButton;
import lime.ui.KeyCode;
import lime.ui.KeyModifier;
import lime.ui.MouseWheelMode;
import lime.ui.Touch;
import lime.ui.Window;
import msignal.Signal.Signal1;
import openfl.geom.Point;
import openfl.ui.GameInput;
import openfl.ui.Keyboard;

using beardFramework.input.GamepadHandler;
using beardFramework.utils.SysPreciseTime;
/**
 * ...
 * @author Ludo
 */
class InputManager
{

	private static var instance(default,null):InputManager;
	public static var directMode(default,null):Bool = false;
	public static var defaultActionsEnabled(default,null):Bool = false;
	public static var maxGamepads(default,null):Int = 8;
	public static var maxTouches(default,null):Int = 8;
	public static var maxMouseButtons(default,null):Int = 8;
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
	private var utilInput:Input;
	private var mouseMoveTargetName:String;
	private var mouseTargetName:String;
	private var touchTargets:Map<String, String>;
	private var currentInput:Input;
	private var defaultActions:Map<InputType, Signal1<Input>>;
	
	private var triggeredInputs:MinAllocArray<Input>;
	
	private function new() 
	{
		
	}
	
	public static inline function Get():InputManager
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
		touchTargets = new Map<String, String>();
		triggeredInputs = new MinAllocArray<Input>(25);
		
		#if mobile
		
		//directMode = true;
		
		#end 
	}
	
	public function Activate(window:Window):Void
	{
		
		window.onMouseDown.add(OnMouseDown);
		window.onMouseMove.add(OnMouseMove);
		window.onMouseUp.add(OnMouseUp);
		window.onMouseWheel.add(OnMouseWheel);
			
		//action : StringLibrary.MOUSE_OVER --> "Mouse_Over"
		//inputID :StringLibrary.MOUSE_OVER --> "Mouse_Over"
		LinkActionToInput(StringLibrary.MOUSE_OVER,StringLibrary.MOUSE_OVER, InputType.MOUSE_OVER);
		LinkActionToInput(StringLibrary.MOUSE_OUT,StringLibrary.MOUSE_OUT, InputType.MOUSE_OUT);
		LinkActionToInput(StringLibrary.MOUSE_MOVE,StringLibrary.MOUSE_MOVE, InputType.MOUSE_MOVE);
		LinkActionToInput(StringLibrary.MOUSE_WHEEL, StringLibrary.MOUSE_WHEEL, InputType.MOUSE_WHEEL);
		
		for (i in 0...3){
			// action : StringLibrary.MOUSE_CLICK+i --> "Mouse_Click" + i 
			// inputID : GetMouseInputID(i) --> "MouseButton" + i; 
			LinkActionToInput(StringLibrary.MOUSE_CLICK+i, GetMouseInputID(i), InputType.MOUSE_CLICK);
			LinkActionToInput(StringLibrary.MOUSE_DOWN+i, GetMouseInputID(i), InputType.MOUSE_DOWN);
			LinkActionToInput(StringLibrary.MOUSE_UP+i, GetMouseInputID(i), InputType.MOUSE_UP);
		}
			
		
		for (gamepad in Gamepad.devices)
			OnGamepadConnect(gamepad);
			
		Gamepad.onConnect.add(OnGamepadConnect);
			
		window.onKeyDown.add(OnKeyDown);
		window.onKeyUp.add(OnKeyUp);
			
		Touch.onStart.add(OnTouchStart);
		Touch.onMove.add(OnTouchMove);
		Touch.onEnd.add(OnTouchEnd);			
		
	}
	
	public function ParseInputSettings(data:Xml):Void
	{
		
		directMode = (data.get(StringLibrary.DIRECT_MODE) == "true");
		
		if (data.get(StringLibrary.MOUSE) == "true")
		{
			maxMouseButtons = Std.parseInt(data.get(StringLibrary.MOUSE_BUTTONS_MAX));
			if (maxMouseButtons > 3)
			{
				for (i in 3...maxMouseButtons){
			
					// action : StringLibrary.MOUSE_CLICK+i --> "Mouse_Click" + i 
					// inputID : GetMouseInputID(i) --> "MouseButton" + i; 
					LinkActionToInput(StringLibrary.MOUSE_CLICK+i, GetMouseInputID(i), InputType.MOUSE_CLICK);
					LinkActionToInput(StringLibrary.MOUSE_DOWN+i, GetMouseInputID(i), InputType.MOUSE_DOWN);
					LinkActionToInput(StringLibrary.MOUSE_UP+i, GetMouseInputID(i), InputType.MOUSE_UP);
					
				}
			}
		}
			
		if (data.get(StringLibrary.GAMEPAD) == "true")	maxGamepads = Std.parseInt(data.get(StringLibrary.GAMEPAD_MAX));
		if (data.get(StringLibrary.TOUCH) == "true") maxTouches = Std.parseInt(data.get(StringLibrary.TOUCH_MAX));
		
		//**************************************Specific actions
			
		for (input in data.elementsNamed(StringLibrary.INPUT))
		{
			if (data.get(StringLibrary.GAMEPAD) == "true"  && input.get(StringLibrary.INPUT_DEFAULT_TYPE).indexOf(StringLibrary.GAMEPAD) != -1){
				
				
				if (Std.parseInt(input.get(StringLibrary.GAMEPAD_ID)) == -1){
					
					for (i in 0...(Std.parseInt(data.get(StringLibrary.GAMEPAD_MAX))))
						LinkActionToInput(input.get(StringLibrary.ACTION), GetGamepadInputID(i, input.get(StringLibrary.INPUT_DEFAULT)) , StringToInputType(input.get(StringLibrary.INPUT_DEFAULT_TYPE)));
				}
				else
					LinkActionToInput(input.get(StringLibrary.ACTION), GetGamepadInputID(Std.parseInt(input.get(StringLibrary.GAMEPAD_ID)), input.get(StringLibrary.INPUT_DEFAULT)) , StringToInputType(input.get(StringLibrary.INPUT_DEFAULT_TYPE)));
							
			}
			else if (data.get(StringLibrary.TOUCH) == "true" && input.get(StringLibrary.INPUT_DEFAULT_TYPE).indexOf(StringLibrary.TOUCH) != -1){
				
				for (i in 0...(Std.parseInt(data.get(StringLibrary.TOUCH_MAX))))
					LinkActionToInput(input.get(StringLibrary.ACTION), StringLibrary.TOUCH + i, StringToInputType(input.get(StringLibrary.INPUT_DEFAULT_TYPE)));
			}
			else 
				LinkActionToInput(input.get(StringLibrary.ACTION), input.get(StringLibrary.INPUT_DEFAULT), StringToInputType(input.get(StringLibrary.INPUT_DEFAULT_TYPE)));
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
		
		
		//trace(actionID + " linked to " + inputID + "  on " + InputTypeToString(inputType) );
	}
		
	public function UnlinkActionFromInput(actionID:String, inputID:String, inputType:InputType):Void 
	{
		
		if (inputActions[inputID] != null && inputActions[inputID][inputType] != null && inputActions[inputID][inputType].indexOf(actionID) != -1)
		{
			inputActions[inputID][inputType].remove(actionID);
		
		}
		
		
	}
	
	public function BindToAction(actionID : String, callback:Float -> Void, targetName:String="", once :Bool = false, active : Bool = true):Void
	{
		//trace(actionID);
		//for (key in actions.keys())
			//if(key == actionID ) trace(key);
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
	
	public function BindToInput(inputID:String, inputType:InputType, callback:Float -> Void, targetName:String="", once:Bool = false, active : Bool = true):Void
	{
		
		var inputToBind:Array<String> = [];
		var specificInput:Bool = false;
		if (InputTypeToString(inputType).indexOf(StringLibrary.GAMEPAD) != -1)
		{
			
			for (i in 0...maxGamepads)
				if (inputID.indexOf(Std.string(i)) != -1){
					specificInput = true;
					break;
				}
			
			if(!specificInput)
				for (i in 0...maxGamepads)
					inputToBind.push(GetGamepadInputID(i, inputID));
			else
				inputToBind.push(inputID);
			
			
		}
		else if (InputTypeToString(inputType).indexOf(StringLibrary.TOUCH) != -1)
		{
			
			for (i in 0...maxTouches)
				inputToBind.push(InputTypeToString(inputType) + i);
			
		}
		else if (InputTypeToString(inputType).indexOf(StringLibrary.MOUSE) != -1 && (inputType == InputType.MOUSE_CLICK || inputType == InputType.MOUSE_DOWN || inputType == InputType.MOUSE_UP))
		{
			for (i in 0...maxMouseButtons)
				if (inputID.indexOf(Std.string(i)) != -1){
					specificInput = true;
					break;
				}
			
			if(!specificInput)
				for (i in 0...maxMouseButtons)
					inputToBind.push(GetMouseInputID(i));
			else
				inputToBind.push(inputID);
			
		}
		else
			inputToBind.push(inputID);
		
		for (ID in inputToBind)
		{
			
			utilString = GetDefaultInputActionID(ID, inputType);
	
			if (handledInputs[ID] == null || actions[utilString] == null){
				LinkActionToInput(utilString, ID, inputType);
			}
				
			if (!CheckDetailExisting(actions[utilString] , callback, targetName))
			{
				actions[utilString].callbackDetails.push({ callback:callback, targetName:targetName,once:once });
			}
			
			actions[utilString].active = active;
			
			
		}
		
	} 
		
	public function UnbindFromAction(actionID : String, callback:Float -> Void = null, targetName:String = ""):Void
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
	
	public function UnbindFromInput(inputID:String, inputType:InputType, callback:Float -> Void = null, targetName:String = ""):Void
	{
		
		var inputToUnbind:Array<String> = [];
		var specificInput:Bool = false;
		if (InputTypeToString(inputType).indexOf(StringLibrary.GAMEPAD) != -1)
		{
			
			for (i in 0...maxGamepads)
				if (inputID.indexOf(Std.string(i)) != -1){
					specificInput = true;
					break;
				}
			
			if(!specificInput)
				for (i in 0...maxGamepads)
					inputToUnbind.push(GetGamepadInputID(i, inputID));
			else
				inputToUnbind.push(inputID);
			
			
		}
		else if (InputTypeToString(inputType).indexOf(StringLibrary.TOUCH) != -1)
		{
			
			for (i in 0...maxTouches)
				inputToUnbind.push(InputTypeToString(inputType) + i);			
		}
		else if (InputTypeToString(inputType).indexOf(StringLibrary.MOUSE) != -1 && (inputType == InputType.MOUSE_CLICK || inputType == InputType.MOUSE_DOWN || inputType == InputType.MOUSE_UP))
		{
			for (i in 0...maxMouseButtons)
				if (inputID.indexOf(Std.string(i)) != -1){
					specificInput = true;
					break;
				}
			
			if(!specificInput)
				for (i in 0...maxMouseButtons)
					inputToUnbind.push(GetMouseInputID(i));
			else
				inputToUnbind.push(inputID);
			
		}
		else
			inputToUnbind.push(inputID);
		
		for (ID in inputToUnbind)
		{
		
			utilString = GetDefaultInputActionID(ID, inputType);
			
			if (actions[utilString] != null){
				
				for (detail in actions[utilString].callbackDetails)
					if (detail.callback == callback && detail.targetName == targetName)
					{
			
						
						actions[utilString].callbackDetails.remove(detail);
						
						detail.callback = null;
						detail = null;
					}
					
					
				if (actions[utilString].callbackDetails.length == 0){
					actions[utilString].callbackDetails = null;
					actions[utilString] = null;
					actions.remove(utilString);
				}
			}
		}
	}
	
	public function ActivateAction(actionID:String, activate : Bool):Void
	{
		
		
	}
		
	public function OnMouseDown(mouseX:Float, mouseY:Float, mouseButton:Int):Void
	{
		
		utilString = GetMouseInputID(mouseButton);
		
		
		if (defaultActionsEnabled || handledInputs[utilString] != null)
		{
			var object:RenderedObject= BeardGame.Get().GetTargetUnderPoint(mouseX,mouseY);
			mouseTargetName = object != null ? object.name : "";
			
		}
		
		if (handledInputs[utilString] != null)
		{
			
			timeCounters[utilString] =  Sys.preciseTime();
			
			var object:RenderedObject = null;/*BeardGame.Get().getTargetUnderPoint(utilPoint);*/ // !Update!
			mouseTargetName = object != null ? object.name : "";
			
			handledInputs[utilString].state = InputType.MOUSE_DOWN;		
			
			handledInputs[utilString].target = mouseTargetName;
			
			if (directMode) DirectResolveInput(	handledInputs[utilString]);
			else triggeredInputs.Push(handledInputs[utilString]);
			
		}
		
		//if (defaultActionsEnabled)
		//{
			//
			//utilInput.ID = utilString;
			//utilInput.state = InputType.MOUSE_DOWN;
			//utilInput.target = mouseTargetName;
			//utilInput.value = 0;
		//
			//defaultActions[InputType.MOUSE_DOWN].dispatch(utilInput);
		//}
		
	}
	
	public function OnMouseUp(mouseX:Float, mouseY:Float, mouseButton:Int):Void
	{
		//Mouse UP
		utilString =  GetMouseInputID(mouseButton);
		utilPoint.setTo(mouseX, mouseY);
		
		var object:RenderedObject = null;/*BeardGame.Get().getTargetUnderPoint(utilPoint);*/ // !Update!
		mouseTargetName = object != null ? object.name : "";
		
		if (handledInputs[utilString] != null)
		{
			
			handledInputs[utilString].state = InputType.MOUSE_UP;		
			
			handledInputs[utilString].target = mouseTargetName;
			
			if (directMode) DirectResolveInput(	handledInputs[utilString]);
			
		}
		
		//
		//if (defaultActionsEnabled)
		//{
			//
			//utilInput.ID = utilString;
			//utilInput.state = InputType.MOUSE_UP;
			//utilInput.target = mouseTargetName;
			//utilInput.value = 0;
		//
			//defaultActions[InputType.MOUSE_CLICK].dispatch(utilInput);
		//}
		//
	//
		
		//Mouse Click
		
		if ( Sys.preciseTime() - timeCounters[utilString]  <= CLICK_DELAY && 	handledInputs[utilString] != null )
		{
			handledInputs[utilString].state = InputType.MOUSE_CLICK;		
			if (directMode) DirectResolveInput(	handledInputs[utilString]);
			
			//if (defaultActionsEnabled)
			//{
			//
				//utilInput.ID = utilString;
				//utilInput.state = InputType.MOUSE_CLICK;
				//utilInput.target = mouseTargetName;
				//utilInput.value = 0;
			//
				//defaultActions[InputType.MOUSE_CLICK].dispatch(utilInput);
			//}
		
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
		
		//if (defaultActionsEnabled)
		//{
			//
			//utilInput.ID = utilString;
			//utilInput.state = InputType.MOUSE_MOVE;
			//utilInput.target = "";
			//utilInput.value = 0;
		//
			//defaultActions[InputType.MOUSE_MOVE].dispatch(utilInput);
		//}
		
		
		if (CheckInputHandled(InputTypeToString(InputType.MOUSE_OVER)) || CheckInputHandled(InputTypeToString( InputType.MOUSE_OUT)) ){
			
			
		var object:RenderedObject = null;/*BeardGame.Get().getTargetUnderPoint(utilPoint);*/ // !Update!
			
			
			if (object != null && mouseMoveTargetName != object.name){
				
				//trace("previous  " +mouseMoveTargetName);
				//trace("new " +objects[0].name);
				handledInputs[StringLibrary.MOUSE_OVER].state = InputType.MOUSE_OVER;
				handledInputs[StringLibrary.MOUSE_OVER].target = object.name;
				
				
				handledInputs[StringLibrary.MOUSE_OUT].state = InputType.MOUSE_OUT;
				handledInputs[StringLibrary.MOUSE_OUT].target = mouseMoveTargetName;
		
				
				//if (defaultActionsEnabled)
				//{
					//
					//utilInput.ID = StringLibrary.MOUSE_OVER;
					//utilInput.state = InputType.MOUSE_OVER;
					//utilInput.target = object.name;
					//utilInput.value = 0;
				//
					//defaultActions[InputType.MOUSE_OVER].dispatch(utilInput);
					//
					//utilInput.ID = StringLibrary.MOUSE_OUT;
					//utilInput.state = InputType.MOUSE_OUT;
					//utilInput.target = mouseMoveTargetName;
					//utilInput.value = 0;
				//
					//defaultActions[InputType.MOUSE_OUT].dispatch(utilInput);
					//
					//
				//}
				
				
				mouseMoveTargetName = object.name;
				
				if (directMode) DirectResolveInput(	handledInputs[StringLibrary.MOUSE_OVER]);
				if (directMode) DirectResolveInput(	handledInputs[StringLibrary.MOUSE_OUT]);
				
				
				
				
			}
			else if (object == null){
				
				handledInputs[StringLibrary.MOUSE_OUT].state = InputType.MOUSE_OUT;
				handledInputs[StringLibrary.MOUSE_OUT].target = mouseMoveTargetName;
				
				//if (defaultActionsEnabled)
				//{
					//
					//utilInput.ID = StringLibrary.MOUSE_OUT;
					//utilInput.state = InputType.MOUSE_OUT;
					//utilInput.target = mouseMoveTargetName;
					//utilInput.value = 0;
					//defaultActions[InputType.MOUSE_OUT].dispatch(utilInput);
					//
				//}
				//
				//
				
				mouseMoveTargetName = "";
				
				
				
				if (directMode) DirectResolveInput(	handledInputs[StringLibrary.MOUSE_OUT]);
			}
			
			
		}
		
		
	}	
	
	public function OnMouseWheel(value:Float, axisDirection:Float, mode:MouseWheelMode):Void
	{
			handledInputs[StringLibrary.MOUSE_WHEEL].state = InputType.MOUSE_WHEEL;
			handledInputs[StringLibrary.MOUSE_WHEEL].value = axisDirection;
			handledInputs[StringLibrary.MOUSE_WHEEL].target = mouseMoveTargetName;
			if (directMode) DirectResolveInput(	handledInputs[StringLibrary.MOUSE_WHEEL]);
			
			
			//if (defaultActionsEnabled)
			//{
				//
				//utilInput.ID = StringLibrary.MOUSE_WHEEL;
				//utilInput.state = InputType.MOUSE_WHEEL;
				//utilInput.target = "";
				//utilInput.value = axisDirection;
				//defaultActions[InputType.MOUSE_WHEEL].dispatch(utilInput);
				//
			//}
			//
	}
		
	public function OnKeyUp(key:KeyCode, modifier:KeyModifier):Void
	{
		
		//Key Up
		utilString = String.fromCharCode(key);
		//trace(utilString);
		modifier.capsLock = modifier.numLock = false;
		
		if (cast(modifier,Int) > 0) utilString += modifier;
		
		
		if (handledInputs[utilString] != null){
			
			handledInputs[utilString].state = InputType.KEY_UP;
			handledInputs[utilString].value = 0;
			if (directMode) DirectResolveInput(	handledInputs[utilString]);
		}
	
		
		//if (defaultActionsEnabled)
			//{
				//
				//utilInput.ID = utilString;
				//utilInput.state = InputType.KEY_UP;
				//utilInput.target = "";
				//utilInput.value = 0;
				//defaultActions[InputType.KEY_UP].dispatch(utilInput);
				//
			//}
		//
		
		//Check Key Pressed
		
		utilString = String.fromCharCode(key); 
		
		if ( Sys.preciseTime() - timeCounters[utilString] <= KEY_PRESS_DELAY){
			
			modifier.capsLock = modifier.numLock = false;
			if (cast(modifier,Int) > 0) utilString += modifier;
		
			if (handledInputs[utilString] != null){
			
				handledInputs[utilString].state = InputType.KEY_PRESS;
				handledInputs[utilString].value = 0.5;
				if (directMode) DirectResolveInput(	handledInputs[utilString]);
			}
			
			//if (defaultActionsEnabled)
			//{
				//
				//utilInput.ID = utilString;
				//utilInput.state = InputType.KEY_PRESS;
				//utilInput.target = "";
				//utilInput.value = 0;
				//defaultActions[InputType.KEY_PRESS].dispatch(utilInput);
				//
			//}
			
			
		}
		
		
		timeCounters[String.fromCharCode(key)] = 0;
		
		
	}
	
	public function OnKeyDown(key:KeyCode, modifier:KeyModifier):Void
	{
		utilString = String.fromCharCode(key);
		//trace(String.fromCharCode(key));
		if( timeCounters[utilString] == null || timeCounters[utilString] == 0) timeCounters[utilString] = Sys.preciseTime();
		
		modifier.capsLock = modifier.numLock = false;
		if (cast(modifier,Int) > 0)utilString += modifier;
		
		if (handledInputs[utilString] != null){
			
			handledInputs[utilString].state = InputType.KEY_DOWN;
			handledInputs[utilString].value = 1;
			if (directMode) DirectResolveInput(	handledInputs[utilString]);
		}
		
		//if (defaultActionsEnabled)
			//{
				//
				//utilInput.ID = utilString;
				//utilInput.state = InputType.KEY_DOWN;
				//utilInput.target = "";
				//utilInput.value = 0;
				//defaultActions[InputType.KEY_DOWN].dispatch(utilInput);
				//
			//}
		
	}
	
	public function OnGamepadAxisMove(gamepadID:Int, axis:GamepadAxis, value:Float):Void
	{
		utilString = GetGamepadInputID(gamepadID, axis.toString());
		if (handledInputs[utilString] != null){
				
			handledInputs[utilString].state = InputType.GAMEPAD_AXIS_MOVE;
			handledInputs[utilString].value = value;
			if (directMode) DirectResolveInput(	handledInputs[utilString]);	
		}
		//trace(utilString);
		
	}
	
	public function OnGamepadButtonUp(gamepadID:Int, button:GamepadButton):Void
	{
		utilString = GetGamepadInputID(gamepadID, button.toString());
		if (handledInputs[utilString] != null){
				
			handledInputs[utilString].state = InputType.GAMEPAD_BUTTON_UP;
			handledInputs[utilString].value = 0;
			if (directMode) DirectResolveInput(	handledInputs[utilString]);
		}
		
		if ( Sys.preciseTime() - timeCounters[utilString] <= GAMEPAD_PRESS_DELAY){
		
			if (handledInputs[utilString] != null){
			
				handledInputs[utilString].state = InputType.GAMEPAD_BUTTON_PRESS;
				handledInputs[utilString].value = 0.5;
				if (directMode) DirectResolveInput(	handledInputs[utilString]);
			}
		}
	
		timeCounters[utilString] = 0;
		
	}
	
	public function OnGamepadButtonDown(gamepadID:Int,button:GamepadButton):Void
	{
		utilString = GetGamepadInputID(gamepadID, button.toString());
	
		
		if ( timeCounters[utilString] == null || timeCounters[utilString] == 0) timeCounters[utilString] =  Sys.preciseTime();
		
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
		utilString = StringLibrary.TOUCH_START + touch.id;
		
		if (handledInputs[utilString] != null)
		{
			utilPoint.setTo(touch.x * BeardGame.Get().window.width, touch.y*BeardGame.Get().window.height);
			timeCounters[StringLibrary.TOUCH + touch.id] =  Sys.preciseTime();
		
			var object:RenderedObject = null;/*BeardGame.Get().getTargetUnderPoint(utilPoint);*/ // !Update!
		
			touchTargets[utilString] = object != null ? object.name : "";
			
			handledInputs[utilString].state = InputType.TOUCH_START;		
			
			handledInputs[utilString].target = touchTargets[utilString];
			
			if (directMode) DirectResolveInput(	handledInputs[utilString]);
			
		}
		
	}
	
	public function OnTouchMove(touch:Touch):Void
	{
		utilString = StringLibrary.TOUCH_MOVE + touch.id;
		utilPoint.setTo(touch.x * BeardGame.Get().window.width, touch.y*BeardGame.Get().window.height);
			
		if (touchTargets[utilString] == null) touchTargets[utilString] = "";
		
		if (handledInputs[utilString] != null)
		{
			
			handledInputs[utilString].state = InputType.TOUCH_MOVE;		
			if (directMode) DirectResolveInput(	handledInputs[utilString]);
		}
		
		
		var object:RenderedObject = null;/*BeardGame.Get().getTargetUnderPoint(utilPoint);*/ // !Update!
	
		
		if (object != null &&  touchTargets[utilString] != object.name){
			
			if (handledInputs[StringLibrary.TOUCH_OVER + touch.id] != null){
				handledInputs[StringLibrary.TOUCH_OVER + touch.id].state = InputType.TOUCH_OVER;
				handledInputs[StringLibrary.TOUCH_OVER + touch.id].target = object.name;
				if (directMode) DirectResolveInput(	handledInputs[StringLibrary.TOUCH_OVER + touch.id]);
			}
			
			if (handledInputs[StringLibrary.TOUCH_OUT + touch.id] != null){
				//trace("touchOut");
				//trace("touchtarget"+ utilString + " " + touchTargets[utilString]);
				handledInputs[StringLibrary.TOUCH_OUT+touch.id].state = InputType.TOUCH_OUT;
				handledInputs[StringLibrary.TOUCH_OUT+touch.id].target = touchTargets[utilString];
				if (directMode) DirectResolveInput(	handledInputs[StringLibrary.TOUCH_OUT + touch.id]);
			}
			
			
			touchTargets[utilString]  = object.name;
			
			//trace("new touch target" + utilString + " " +  touchTargets[utilString]);
			
			
		}
		else if (object == null ){
			if (handledInputs[StringLibrary.TOUCH_OUT + touch.id] != null){
					//trace("touchOut2");
					//trace("touchtarget"+ utilString + " " + touchTargets[utilString]);
				handledInputs[StringLibrary.TOUCH_OUT+touch.id].state = InputType.TOUCH_OUT;
				handledInputs[StringLibrary.TOUCH_OUT + touch.id].target = touchTargets[utilString];
				
				if (directMode) DirectResolveInput(	handledInputs[StringLibrary.TOUCH_OUT+touch.id]);
			}
			touchTargets[utilString] = "";
			//trace("new touch target" + utilString + " " +  touchTargets[utilString]);
			//if (handledInputs[utilString] != null) handledInputs[utilString].target = "";
			
			
		}
	
			
		
		
		
	}
	
	public function OnTouchEnd(touch:Touch):Void
	{
		
		utilString =  StringLibrary.TOUCH_END + touch.id;
		utilPoint.setTo(touch.x * BeardGame.Get().window.width, touch.y*BeardGame.Get().window.height);
			
		var object:RenderedObject = null;/*BeardGame.Get().getTargetUnderPoint(utilPoint);*/ // !Update!
		touchTargets[utilString] = object != null ? object.name : "";
		
		if (handledInputs[utilString] != null)
		{
			
			handledInputs[utilString].state = InputType.TOUCH_END;		
			
			handledInputs[utilString].target = touchTargets[utilString];
			
			if(directMode) DirectResolveInput(handledInputs[utilString]);
			
		}
	
		
		//Mouse Click
		
		if (handledInputs[StringLibrary.TOUCH_TAP + touch.id] != null  &&  Sys.preciseTime() - timeCounters[StringLibrary.TOUCH + touch.id]  <= TAP_DELAY )
		{
			handledInputs[StringLibrary.TOUCH_TAP + touch.id].state = InputType.TOUCH_TAP;		
			handledInputs[StringLibrary.TOUCH_TAP + touch.id].target = touchTargets[utilString];		
			if(directMode) DirectResolveInput(handledInputs[utilString]);
		}
		
		timeCounters[StringLibrary.TOUCH + touch.id] = 0;
		
	}
	
	public function Update():Void
	{
		
		var i:Int = 0;
		var detail:CallbackDetails;
		
		
		for (input in handledInputs)
		//for (i in 0...triggeredInputs.length)
		{
			currentInput = input;
			//currentInput = triggeredInputs[i];
						
			if (!currentInput.active) continue;
			
			if (inputActions[currentInput.ID] != null && inputActions[currentInput.ID][currentInput.state] != null)
			{
				for (actionID in inputActions[currentInput.ID][currentInput.state])
				{
					
					if (actions[actionID] != null){
						if (actions[actionID].active)
						{
							
							i = actions[actionID].callbackDetails.length;
							
							while (--i >= 0)
							{
								detail = actions[actionID].callbackDetails[i];
								
								if (detail.targetName == currentInput.target || detail.targetName == "")
								{
									detail.callback(currentInput.value);
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
					//trace(input.ID + "    " + input.state + "    " + input.toggle);
			}
			
			if (currentInput.state == GetToggleType(currentInput.state)){
				currentInput.state = InputType.NONE;
				currentInput.value = 0;
			}
		}
	
		
	}
	
	private function DirectResolveInput(input:Input):Void
	{
		//trace("direct");
		if (input.active){
			currentInput = input;
			
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
			//trace(input.ID + "    " + input.state + "    " + input.toggle);
			if (input.state == GetToggleType(input.state)){
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
		
	public static inline function GetMouseInputID(button : Int):String
	{
		return  StringLibrary.MOUSE + button;
	}
	
	public static inline function GetCallingInput():Input
	{
		return instance.currentInput;
		
		
	}
	
	public static inline function GetGamepadInputID(gamepadID:Int, inputID : String):String
	{
		return  StringLibrary.GAMEPAD + inputID+ gamepadID;
	}
	
	public static inline function GetTouchInputID(touchID:Int, type:InputType):String
	{
		return "";
	}
	
	public static inline function GetDefaultInputActionID(inputID:String, inputType:InputType):String
	{
		
		return InputTypeToString(inputType) + inputID;
		
	}
	
	public static inline function StringToInputType(type:String):InputType
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
			case StringLibrary.TOUCH_OUT: 				inputType = InputType.TOUCH_OUT;
			case StringLibrary.TOUCH_OVER: 				inputType = InputType.TOUCH_OVER;
			case StringLibrary.TOUCH_START: 			inputType = InputType.TOUCH_START;
			case StringLibrary.TOUCH_TAP: 				inputType = InputType.TOUCH_TAP;
			
			
		}
		return inputType;
	}
	
	public static inline function InputTypeToString(type:InputType):String
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
			case InputType.TOUCH_OUT: 				string = StringLibrary.TOUCH_OUT;
			case InputType.TOUCH_OVER: 				string = StringLibrary.TOUCH_OVER;
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
			case InputType.TOUCH_OUT: 				toggleType = InputType.TOUCH_OUT;
			case InputType.TOUCH_OVER: 				toggleType = InputType.TOUCH_OVER;
			case InputType.TOUCH_START: 			toggleType = InputType.TOUCH_START;
			case InputType.TOUCH_TAP: 				toggleType = InputType.TOUCH_TAP;
			
			
		}
		return toggleType;
	}
	
	
	
	

	
}
