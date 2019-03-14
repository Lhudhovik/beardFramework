package beardFramework.input;


import beardFramework.core.BeardGame;
import beardFramework.graphics.core.RenderedObject;
import beardFramework.input.Action.CallbackDetails;
import beardFramework.input.Action.ResolvedAction;
import beardFramework.input.data.InputData;
import beardFramework.input.data.AxisInputData;
import beardFramework.input.data.ButtonInputData;
import beardFramework.input.data.AbstractGamepadInputData;
import beardFramework.input.data.GamepadInputData;
import beardFramework.input.data.KeyboardInputData;
import beardFramework.input.data.MouseInputData;
import beardFramework.input.data.WheelInputData;
import beardFramework.interfaces.IFocusable;
import beardFramework.resources.MinAllocArray;
import beardFramework.resources.pool.ListPool;
import beardFramework.resources.save.data.StructDataUIComponent;
import beardFramework.utils.libraries.StringLibrary;
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
	

	private var controls:Map<Input,MinAllocArray<String>>;
	private var actions:Map<String, Action>;
	private var resolveQueue:List<ResolvedAction>;
	private var touches:Map<Int, Touch>;
	private var timeCounters:Map<String, Float>;
	private var utilPoint:Point;
	private var utilString:String;
	private var utilInput:Input;
	private var mouseMoveTargetName:String;
	private var mouseTargetName:String;
	private var touchTargets:Map<String, String>;
	public var focusedObject:IFocusable;
	
	private var mouseInputData:ListPool<MouseInputData>;
	private var wheelInputData:ListPool<WheelInputData>;
	private var keyboardInputData:ListPool<KeyboardInputData>;
	private var gamepadInputData:ListPool<GamepadInputData>;
	private var buttonInputData:ListPool<ButtonInputData>;
	private var axisInputData:ListPool<AxisInputData>;
	
	private var MIDUtil:MouseInputData;
	private var WIDUtil:WheelInputData;
	private var KIDUtil:KeyboardInputData;
	private var GIDUtil:GamepadInputData;
	private var BIDUtil:ButtonInputData;
	private var AIDUtil:AxisInputData;
	
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
		actions = new Map<String, Action>();
		controls = new Map<Input,MinAllocArray<String>>();
		touches = new Map<Int, Touch>();
		timeCounters = new Map<String, Float>();
		utilPoint = new Point();
		touchTargets = new Map<String, String>();
		resolveQueue = new List();
			
		mouseInputData = new ListPool(4);
		mouseInputData.Populate([for (i in 0...4) {type:InputType.MOUSE_CLICK, target:"", buttonID:0}]);
		wheelInputData = new ListPool(2);
		wheelInputData.Populate([for (i in 0...2) {type:InputType.MOUSE_WHEEL, target:"", value:0.0, axisDirection:0.0, wheelMode:MouseWheelMode.LINES}]);
		keyboardInputData = new ListPool(4);
		keyboardInputData.Populate([for (i in 0...4) {type:InputType.KEY_DOWN, target:"", keyCode:0, modifier:0}]);
		gamepadInputData = new ListPool(4);
		gamepadInputData.Populate([for (i in 0...4) {type:InputType.GAMEPAD_CONNECT, target:"", gamepad:null}]);
		buttonInputData = new ListPool(4);
		buttonInputData.Populate([for (i in 0...4) {type:InputType.GAMEPAD_BUTTON_UP, target:"", gamepadID:0, button:0}]);
		axisInputData = new ListPool(4);
		axisInputData.Populate([for (i in 0...4) {type:InputType.GAMEPAD_AXIS_MOVE, target:"", gamepadID:0, axis:0, value:0.0}]);
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
					//LinkActionToInput(StringLibrary.MOUSE_CLICK+i, GetMouseInputID(i), InputType.MOUSE_CLICK);
					//LinkActionToInput(StringLibrary.MOUSE_DOWN+i, GetMouseInputID(i), InputType.MOUSE_DOWN);
					//LinkActionToInput(StringLibrary.MOUSE_UP+i, GetMouseInputID(i), InputType.MOUSE_UP);
					//
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
		utilInput = Input.FromInputData(inputID, inputType);
		
		if (actions[actionID] == null)	actions[actionID] = {ID:actionID, active:true, callbackDetails:new MinAllocArray()};	
	
		if (controls[utilInput] == null) controls[utilInput] = new MinAllocArray<String>();
		
		controls[utilInput].Push(actionID);
	
	}
		
	public function UnlinkActionFromInput(actionID:String, inputID:String, inputType:InputType):Void 
	{
		controls[Input.FromInputData(inputID, inputType)].Remove(actionID);		
	}
	
	public function BindToAction(actionID : String, callback:InputData -> Void, targetName:String="", once :Bool = false, active : Bool = true):Void
	{
		
		if (actions[actionID] == null){
			actions[actionID] = { ID:actionID, active:true, callbackDetails:new MinAllocArray()};	
		}
		
		if (!CheckDetailExisting(actions[actionID] , callback, targetName))
		{
			actions[actionID].callbackDetails.Push({ callback:callback, target:targetName,once:once });
			
			
		}
		
		actions[actionID].active = active;
		
		
		
	}
	
	public function BindToInput(inputID:String, inputType:InputType, callback:InputData -> Void, targetName:String="", once:Bool = false, active : Bool = true):Void
	{
		
		BindToAction(Input.FromInputData(inputID, inputType), callback, targetName, once, active);
		
		
	} 
		
	public function UnbindFromAction(actionID : String, callback:InputData -> Void = null, targetName:String = ""):Void
	{
		var detail:CallbackDetails;
		if (actions[actionID] != null)	
			for (i in 0...actions[actionID].callbackDetails.length){
				
				detail = actions[actionID].callbackDetails.get(i); 
				if (detail.callback == callback && detail.target == targetName)
				{
			
					
					actions[actionID].callbackDetails.Remove(detail);
					
					detail.callback = null;
					detail = null;
					break;
				}
			
			}
	}
	
	public function UnbindFromInput(inputID:String, inputType:InputType, callback:InputData -> Void = null, targetName:String = ""):Void
	{
		UnbindFromAction(Input.FromInputData(inputID, inputType), callback, targetName);
		
	}
	
	public function ActivateAction(actionID:String, activate : Bool):Void
	{
		
		if (actions[actionID] != null) actions[actionID].active = activate;
	}
		
	public function OnMouseDown(mouseX:Float, mouseY:Float, mouseButton:Int):Void
	{
		
		utilString = GetMouseInputID(mouseButton);
				
		var object:RenderedObject= BeardGame.Get().GetTargetUnderPoint(mouseX,mouseY);
		mouseTargetName = object != null ? object.name : "";
				
		MIDUtil = mouseInputData.Get();
		MIDUtil.buttonID = mouseButton;
		MIDUtil.target = mouseTargetName;
		MIDUtil.type = InputType.MOUSE_DOWN;
		
		//MIDUtil = {type:InputType.MOUSE_DOWN, target:mouseTargetName, buttonID:mouseButton};
		FetchActions(utilString, MIDUtil);
		
		timeCounters[utilString] =  Sys.preciseTime();
		
		


	}
	
	public function OnMouseUp(mouseX:Float, mouseY:Float, mouseButton:Int):Void
	{
		//Mouse UP
		utilString = GetMouseInputID(mouseButton);
		
		var object:RenderedObject= BeardGame.Get().GetTargetUnderPoint(mouseX,mouseY);
		mouseTargetName = object != null ? object.name : "";
		
		MIDUtil = mouseInputData.Get();
		MIDUtil.buttonID = mouseButton;
		MIDUtil.target = mouseTargetName;
		MIDUtil.type = InputType.MOUSE_UP;
		
		
		//MIDUtil = {type:InputType.MOUSE_UP, target:mouseTargetName, buttonID:mouseButton};
		FetchActions(utilString, MIDUtil);
		
		if ( Sys.preciseTime() - timeCounters[utilString]  <= CLICK_DELAY )
		{
			
			MIDUtil = mouseInputData.Get();
			MIDUtil.buttonID = mouseButton;
			MIDUtil.target = mouseTargetName;
			MIDUtil.type = InputType.MOUSE_CLICK;
				//MIDUtil = {type:InputType.MOUSE_CLICK, target:mouseTargetName, buttonID:mouseButton};
			FetchActions(utilString, MIDUtil);			
		
		}
		
		timeCounters[utilString] = 0;
		
	}
	
	public function OnMouseMove(mouseX:Float, mouseY:Float):Void
	{
		
		//
		utilString = StringLibrary.MOUSE;
	
		
		MousePos.previous.x = MousePos.current.x;
		MousePos.previous.y = MousePos.current.y;
		MousePos.current.x = mouseX;
		MousePos.current.y = mouseY;
		
		var object:RenderedObject = BeardGame.Get().GetTargetUnderPoint(mouseX, mouseY);
		
		MIDUtil = mouseInputData.Get();
		MIDUtil.buttonID = 0;
		MIDUtil.target = (object != null? object.name : "") ;
		MIDUtil.type = InputType.MOUSE_MOVE;
		
		//MIDUtil = {type:InputType.MOUSE_MOVE, target:mouseTargetName, buttonID:0};
		
		FetchActions(utilString, MIDUtil);
			
		if (actions[Input.FromInputData(utilString, InputType.MOUSE_OVER)] != null || actions[Input.FromInputData(utilString, InputType.MOUSE_OUT)] != null  ){
			
			
			
			
			if (object != null && mouseMoveTargetName != object.name){
				
				MIDUtil = mouseInputData.Get();
				MIDUtil.buttonID = 0;
				MIDUtil.target = object.name ;
				MIDUtil.type = InputType.MOUSE_OVER;
				//MIDUtil = {type:InputType.MOUSE_OVER, target:object.name, buttonID:0};
				FetchActions(utilString, MIDUtil);
				//
				MIDUtil = mouseInputData.Get();
				MIDUtil.buttonID = 0;
				MIDUtil.target = mouseMoveTargetName ;
				MIDUtil.type = InputType.MOUSE_OUT;
				//MIDUtil = {type:InputType.MOUSE_OUT, target:mouseMoveTargetName, buttonID:0};
				FetchActions(utilString, MIDUtil);
						
				mouseMoveTargetName = object.name;	
				
			}
			else if (object == null){
				
				//
				MIDUtil = mouseInputData.Get();
				MIDUtil.buttonID = 0;
				MIDUtil.target = mouseMoveTargetName ;
				MIDUtil.type = InputType.MOUSE_OUT;
				//MIDUtil = {type:InputType.MOUSE_OUT, target:mouseMoveTargetName, buttonID:0};
				FetchActions(utilString, MIDUtil);
								
				mouseMoveTargetName = "";
			}
			
			
		}
		
		
	}	
	
	public function OnMouseWheel(value:Float, axisDirection:Float, mode:MouseWheelMode):Void
	{
			
		
		WIDUtil = wheelInputData.Get();
		WIDUtil.value = value;
		WIDUtil.target = mouseMoveTargetName ;
		WIDUtil.axisDirection = axisDirection;
		WIDUtil.wheelMode = mode;
		
		//WIDUtil = {type:InputType.MOUSE_WHEEL, target:mouseMoveTargetName, value:value, axisDirection:axisDirection, wheelMode:mode};
		FetchActions(StringLibrary.MOUSE, WIDUtil);
			
	}
		
	public function OnKeyUp(key:KeyCode, modifier:KeyModifier):Void
	{
		
		//Key Up
		utilString = String.fromCharCode(key);
		
		modifier.capsLock = modifier.numLock = false;
		
		
		if (cast(modifier,Int) > 0) utilString += modifier;
		
		KIDUtil = keyboardInputData.Get();
		KIDUtil.keyCode = key;
		KIDUtil.modifier = modifier;
		KIDUtil.type = InputType.KEY_UP;
		KIDUtil.target = focusedObject.name;
		//KIDUtil = {type:InputType.KEY_UP, target:focusedObject, keyCode:key, modifier:modifier};
		FetchActions(utilString, KIDUtil);
		
		
		//Check Key Pressed
		
		utilString = String.fromCharCode(key); 
		
		if ( Sys.preciseTime() - timeCounters[utilString] <= KEY_PRESS_DELAY){
			
			modifier.capsLock = modifier.numLock = false;
			if (cast(modifier,Int) > 0) utilString += modifier;
		
			KIDUtil = keyboardInputData.Get();
			KIDUtil.keyCode = key;
			KIDUtil.modifier = modifier;
			KIDUtil.type = InputType.KEY_PRESS;
			KIDUtil.target = focusedObject.name;
			//KIDUtil = {type:InputType.KEY_PRESS, target:focusedObject, keyCode:key, modifier:modifier};
			FetchActions(utilString, KIDUtil);
			
			
		}
		
		
		timeCounters[String.fromCharCode(key)] = 0;
		
		
	}
	
	public function OnKeyDown(key:KeyCode, modifier:KeyModifier):Void
	{
		utilString = String.fromCharCode(key) ;
		//utilString = String.fromCharCode(key) + focusedObject;
	
		if( timeCounters[utilString] == null || timeCounters[utilString] == 0) timeCounters[utilString] = Sys.preciseTime();
		
		modifier.capsLock = modifier.numLock = false;
		if (cast(modifier,Int) > 0)utilString += modifier;
		
		KIDUtil = keyboardInputData.Get();
		KIDUtil.keyCode = key;
		KIDUtil.modifier = modifier;
		KIDUtil.type = InputType.KEY_DOWN;
		KIDUtil.target = focusedObject.name;
		//KIDUtil = {type:InputType.KEY_DOWN, target:focusedObject, keyCode:key, modifier:modifier};
		FetchActions(utilString, KIDUtil);
		
	}
	
	public function OnGamepadAxisMove(gamepadID:Int, axis:GamepadAxis, value:Float):Void
	{
		utilString = GetGamepadInputID(gamepadID, axis.toString());
		
		AIDUtil = axisInputData.Get();
		AIDUtil.value = value;
		AIDUtil.axis = axis ;
		AIDUtil.gamepadID = gamepadID;
		AIDUtil.target = focusedObject.name;
		AIDUtil.type = InputType.GAMEPAD_AXIS_MOVE;
		//AIDUtil = {type:InputType.GAMEPAD_AXIS_MOVE, target:focusedObject, gamepadID:gamepadID, axis:axis, value:value}
		FetchActions(utilString, AIDUtil);
		//trace(utilString);
		
	}
	
	public function OnGamepadButtonUp(gamepadID:Int, button:GamepadButton):Void
	{
		utilString = GetGamepadInputID(gamepadID, button.toString());
		
		BIDUtil = buttonInputData.Get();
		BIDUtil.button = button;
		BIDUtil.gamepadID = gamepadID;
		BIDUtil.target = focusedObject.name;
		BIDUtil.type = InputType.GAMEPAD_BUTTON_UP;
		//BIDUtil = {type:InputType.GAMEPAD_BUTTON_UP, target:focusedObject, gamepadID:gamepadID, button:button};
		FetchActions(utilString, BIDUtil);
		
		if ( Sys.preciseTime() - timeCounters[utilString] <= GAMEPAD_PRESS_DELAY){
		
			BIDUtil = buttonInputData.Get();
			BIDUtil.button = button;
			BIDUtil.gamepadID = gamepadID;
			BIDUtil.target = focusedObject.name;
			BIDUtil.type = InputType.GAMEPAD_BUTTON_PRESS;
			//BIDUtil = {type:InputType.GAMEPAD_BUTTON_PRESS, target:focusedObject, gamepadID:gamepadID, button:button};
			FetchActions(utilString, BIDUtil);
		}
	
		timeCounters[utilString] = 0;
		
	}
	
	public function OnGamepadButtonDown(gamepadID:Int,button:GamepadButton):Void
	{
		utilString = GetGamepadInputID(gamepadID, button.toString());
	
		
		if ( timeCounters[utilString] == null || timeCounters[utilString] == 0) timeCounters[utilString] =  Sys.preciseTime();
		
		BIDUtil = buttonInputData.Get();
		BIDUtil.button = button;
		BIDUtil.gamepadID = gamepadID;
		BIDUtil.target = focusedObject.name;
		BIDUtil.type = InputType.GAMEPAD_BUTTON_DOWN;
		//BIDUtil = {type:InputType.GAMEPAD_BUTTON_DOWN, target:focusedObject, gamepadID:gamepadID, button:button};
		FetchActions(utilString, BIDUtil);
		
		
	}
	
	public function OnGamepadConnect(gamepad:Gamepad):Void
	{
		gamepad.onAxisMove.add(gamepad.AxisMove);
		gamepad.onButtonDown.add(gamepad.ButtonDown);
		gamepad.onButtonUp.add(gamepad.ButtonUp);
		gamepad.onDisconnect.add(gamepad.Disconnect);
		
		GIDUtil = gamepadInputData.Get();
		GIDUtil.gamepad = gamepad;
		GIDUtil.type = InputType.GAMEPAD_CONNECT;
		//GIDUtil = {type:InputType.GAMEPAD_CONNECT, target:"", gamepad:gamepad};
		FetchActions(StringLibrary.GAMEPAD, GIDUtil);
	}
	
	public function OnGamepadDisconnect(gamepad:Gamepad):Void
	{
		
		gamepad.onAxisMove.remove(gamepad.AxisMove);
		gamepad.onButtonDown.remove(gamepad.ButtonDown);
		gamepad.onButtonUp.remove(gamepad.ButtonUp);
		gamepad.onDisconnect.remove(gamepad.Disconnect);
		
		GIDUtil = gamepadInputData.Get();
		GIDUtil.gamepad = gamepad;
		GIDUtil.type = InputType.GAMEPAD_DISCONNECT;
		//GIDUtil = {type:InputType.GAMEPAD_DISCONNECT, target:"", gamepad:gamepad};
		FetchActions(StringLibrary.GAMEPAD, GIDUtil);
	}
	
	public function OnTouchStart(touch:Touch):Void
	{
		/*utilString = StringLibrary.TOUCH_START + touch.id;
		
		if (handledInputs[utilString] != null)
		{
			utilPoint.setTo(touch.x * BeardGame.Get().window.width, touch.y*BeardGame.Get().window.height);
			timeCounters[StringLibrary.TOUCH + touch.id] =  Sys.preciseTime();
		
			var object:RenderedObject = null;//BeardGame.Get().getTargetUnderPoint(utilPoint); // !Update!
		
			touchTargets[utilString] = object != null ? object.name : "";
			
			handledInputs[utilString].state = InputType.TOUCH_START;		
			
			handledInputs[utilString].target = touchTargets[utilString];
			
			if (directMode) DirectResolveInput(	handledInputs[utilString]);
			
		}*/
		
	}
	
	public function OnTouchMove(touch:Touch):Void
	{
		/*utilString = StringLibrary.TOUCH_MOVE + touch.id;
		utilPoint.setTo(touch.x * BeardGame.Get().window.width, touch.y*BeardGame.Get().window.height);
			
		if (touchTargets[utilString] == null) touchTargets[utilString] = "";
		
		if (handledInputs[utilString] != null)
		{
			
			handledInputs[utilString].state = InputType.TOUCH_MOVE;		
			if (directMode) DirectResolveInput(	handledInputs[utilString]);
		}
		
		
		var object:RenderedObject = null;//BeardGame.Get().getTargetUnderPoint(utilPoint); // !Update!
	
		
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
	
			
		
		*/
		
	}
	
	public function OnTouchEnd(touch:Touch):Void
	{
		
		/*utilString =  StringLibrary.TOUCH_END + touch.id;
		utilPoint.setTo(touch.x * BeardGame.Get().window.width, touch.y*BeardGame.Get().window.height);
			
		var object:RenderedObject = null;//BeardGame.Get().getTargetUnderPoint(utilPoint); // !Update!
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
		
		timeCounters[StringLibrary.TOUCH + touch.id] = 0;*/
		
	}
	
	public function Update():Void
	{
		
		var resolve:ResolvedAction;
		
		while (resolveQueue.length > 0)
		{
			resolve = resolveQueue.pop();
			resolve.callback(resolve.data);		
			FreeData(resolve.data);
		}
	
	
	

		
	}
	
	private inline function FetchActions(inputId:String, inputData:InputData):Void
	{
		utilInput = Input.FromInputData(inputId, inputData.type);
		var detail:CallbackDetails;
		var j:Int = 0;
		var success:Bool = false;
		if (controls[utilInput] != null)
		{
			for (i in 0...controls[utilInput].length)
			{
				utilString = controls[utilInput].get(i);
				if (actions[utilString] != null)
				{
					j = actions[utilString].callbackDetails.length-1;
					while (j >= 0)
					{
						detail = actions[utilString].callbackDetails.get(j);
						if (detail != null && detail.target == inputData.target){
							success = true;
							if (directMode) detail.callback(inputData);
							resolveQueue.add({callback:detail.callback, data:inputData});
							if (detail.once == true) actions[utilString].callbackDetails.Remove(detail);
							
						}
						
						j--;
					}
				}
			}
			
		}
		
		if (actions[utilInput] != null)
		{
			trace("not empty");
			
			j = actions[utilInput].callbackDetails.length-1;
			while (j >= 0)
			{
				detail = actions[utilInput].callbackDetails.get(j);
				if(detail != null) trace(detail.target);
				if (detail != null && detail.target == inputData.target){
					success = true;
					resolveQueue.add({callback:detail.callback, data:inputData});
					if (directMode) detail.callback(inputData);
					if (detail.once == true) actions[utilInput].callbackDetails.Remove(detail);
					
				}
				
				j--;
			}
			
		}
		
		utilInput = Input.FromInputData(StringLibrary.ANY, inputData.type);
		if (actions[utilInput] != null)
		{
			
			j = actions[utilInput].callbackDetails.length-1;
			
			while (j >= 0)
			{
				
				detail = actions[utilInput].callbackDetails.get(j);
				if (detail != null && detail.target == inputData.target){
					success = true;
					resolveQueue.add({callback:detail.callback, data:inputData});
					if (directMode) detail.callback(inputData);
					if (detail.once == true) actions[utilInput].callbackDetails.Remove(detail);
					
				}
				
				j--;
			}
			
		}
		if (success == false)
		{
			FreeData(inputData);
		}
		
		
	}
		
	private inline function  CheckDetailExisting(action:Action, callback:InputData->Void, target:String):Bool
	{
		var exist:Bool = false;
	
		
		for (i in 0...action.callbackDetails.length)
		{
			
			if ( exist = (action.callbackDetails.get(i).callback == callback && action.callbackDetails.get(i).target == target)) 
				break;
			
		}
	
		return exist;
		
	}
	
	public static inline function GetMouseInputID(button : Int):String
	{
		return  StringLibrary.MOUSE + button;
	}
	
	public static inline function GetGamepadInputID(gamepadID:Int, inputID : String):String
	{
		return  StringLibrary.GAMEPAD + inputID+ gamepadID;
	}
	
	public static inline function GetTouchInputID(touchID:Int, type:InputType):String
	{
		return "";
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
			case StringLibrary.GAMEPAD_CONNECT: 		inputType = InputType.GAMEPAD_CONNECT;
			case StringLibrary.GAMEPAD_DISCONNECT: 		inputType = InputType.GAMEPAD_DISCONNECT;
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
			case InputType.GAMEPAD_DISCONNECT: 		string = StringLibrary.GAMEPAD_DISCONNECT;
			case InputType.GAMEPAD_CONNECT: 		string = StringLibrary.GAMEPAD_CONNECT;
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
	
	private inline function FreeData(data:InputData):Void
	{
		switch(data.type)
		{
			case InputType.MOUSE_DOWN: 				mouseInputData.Release(cast data) ; 
			case InputType.MOUSE_CLICK: 			mouseInputData.Release(cast data) ;  
			case InputType.MOUSE_UP: 				mouseInputData.Release(cast data) ; 
			case InputType.MOUSE_MOVE: 				mouseInputData.Release(cast data) ; 
			case InputType.MOUSE_OUT: 				mouseInputData.Release(cast data) ; 
			case InputType.MOUSE_OVER:				mouseInputData.Release(cast data) ; 
			case InputType.MOUSE_WHEEL:				wheelInputData.Release(cast data) ; 
			case InputType.KEY_UP:					keyboardInputData.Release(cast data) ; 
			case InputType.KEY_PRESS: 				keyboardInputData.Release(cast data) ; 
			case InputType.KEY_DOWN:				keyboardInputData.Release(cast data) ; 
			case InputType.GAMEPAD_AXIS_MOVE:		axisInputData.Release(cast data);
			case InputType.GAMEPAD_BUTTON_UP: 		buttonInputData.Release(cast data);
			case InputType.GAMEPAD_BUTTON_DOWN: 	buttonInputData.Release(cast data);
			case InputType.GAMEPAD_BUTTON_PRESS: 	buttonInputData.Release(cast data);
			case InputType.GAMEPAD_DISCONNECT: 		gamepadInputData.Release(cast data);
			case InputType.GAMEPAD_CONNECT: 		gamepadInputData.Release(cast data);
			case InputType.NONE: 					
			case InputType.TOUCH_END: 				
			case InputType.TOUCH_MOVE: 				
			case InputType.TOUCH_OUT: 				
			case InputType.TOUCH_OVER: 				
			case InputType.TOUCH_START: 			
			case InputType.TOUCH_TAP: 				
			
			
		}
	}
	
	

	
}
