package beardFramework.events.input;
import beardFramework.events.input.InputAction.InputDetails;
import msignal.Signal;
//import openfl.events.Event;

/**
 * ...
 * @author Ludo
 */
class InputAction
{
	//private var signal(null, null):Signal1<Event>;
	private var callbacks:Array<CallbackDetails>;
	private var associatedInputs:Array<InputDetails>;
	private var compatibleActions:Array<String>;
	public var activated:Bool;
	public var toggleType:InputType;
	
	
	public function new(defaultCompatibleActionsIDs : Array<String> = null) 
	{
		//signal = new Signal1(Event);
		callbacks = new Array<CallbackDetails>();
		associatedInputs = new Array<InputDetails>();
		compatibleActions = defaultCompatibleActionsIDs != null ? defaultCompatibleActionsIDs : new Array<String>();
	}
	
	public inline function get_associatedInputs():Array<InputDetails>{
		
		return associatedInputs;
	}
	public inline function get_compatibleActions():Array<String> return compatibleActions;
	
	public inline function Proceed(inputValue:Float=0, targetName:String=""):Void
	{
		
		if (activated)
			for (detail in callbacks)
				if (detail.activated && (targetName == "" || detail.targetName == targetName)){
					
					detail.callback(inputValue);
					if (detail.once) callbacks.remove(detail);
					if(detail
				}
				
	}
	
	public function Link(callback:Float -> Void, once:Bool = false, targetName:String=""):Void
	{
		var callbackDetail : CallbackDetails = {callback:callback, once:once, targetName:targetName};
		
		
		if(!CheckIsExisting(callbackDetail)) callbacks.push(callbackDetail);
		trace(callbacks);
	}
	
	public function UnLink(callback:Float -> Void = null, targetName:String = ""):Void
	{
		
		for (detail in callbacks){
			if ( callback == null || ( (targetName == ""|| targetName == detail.targetName)  && detail.callback == callback) ) 
				callbacks.remove(detail);
		}
		
	}
	
	public function AddAssociatedInput(input:String, inputType:InputType):Void{
		
		var alreadyAssociated : Bool = false;
		for (detail in associatedInputs)
		{
			if(alreadyAssociated = (detail.input == input && detail.type == inputType)) break;
			
		}
		
		if (alreadyAssociated == false) {
			
			var detail : InputDetails = {type:inputType, input : input};
			associatedInputs.push(detail);
		}
		
	}
	
	public function RemoveAssociatedInput(removedInput:String, inputType:InputType):Void
	{
		for (detail in associatedInputs){
			
			if (detail.input == removedInput && detail.type == inputType) associatedInputs.remove(detail);
		}
		
	}
	
	public function AddCompatibleAction(addedAction:String):Void{
		
		if (compatibleActions.indexOf(addedAction) == -1) compatibleActions.push(addedAction);
		trace(compatibleActions);
	}
	
	public function RemoveCompatibleAction(removedAction:String):Void
	{
		compatibleActions.remove(removedAction);
	}
	
	//private inline function CheckInputType(inputID:String, inputType:InputType):Bool
	//{
		//var success:Bool = false;
		//
		//for (detail in associatedInputs){
			//
			//if (success = (detail.input == inputID && detail.type == inputType))
				//break;
		//}
		//
		//return success;
	//}
	
	private inline function CheckIsExisting(checkedDetail : CallbackDetails):Bool
	{
		var success:Bool = false;
		
		for (detail in callbacks){
			
			if (success = (detail.callback == checkedDetail.callback && detail.targetName == checkedDetail.targetName))
				break;
		}
		
		return success;
	}
	public inline function toggle(value:Float):Void
	{
		activated = true;
	}
}

typedef InputDetails =
{
	var input : String;
	var type : InputType;
}

typedef CallbackDetails =
{
	var callback:Float->Void;
	var targetName:String;
	var once:Bool;
	var activated:Bool;
	var toggleType:InputType;
}