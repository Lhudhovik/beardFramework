package beardFramework.events.input;
import beardFramework.events.input.InputAction.InputDetails;
import msignal.Signal;
import openfl.events.Event;

/**
 * ...
 * @author Ludo
 */
class InputAction
{
	private var signal(null, null):Signal1<Event>;
	private var associatedInputs:Array<InputDetails>;
	private var compatibleActions:Array<String>;
	public var activated:Bool;
	
	
	public function new(defaultCompatibleActionsIDs : Array<String> = null) 
	{
		signal = new Signal1(Event);
		associatedInputs = new Array<InputDetails>();
		compatibleActions = defaultCompatibleActionsIDs != null ? defaultCompatibleActionsIDs : new Array<String>();
	}
	
	public inline function get_associatedInputs():Array<String>{
		
		var inputs:Array<String> = new Array<String>();
		
		for (detail in associatedInputs){
			
			inputs.push(detail.input);
			
		}
		
		
		return inputs;
	}
	public inline function get_compatibleActions():Array<String> return compatibleActions;
	
	public inline function Proceed(inputID:String, inputType:String, inputValue:Event):Void
	{
		trace(activated);
		trace(CheckInputType(inputID, inputType));
		if (activated && CheckInputType(inputID, inputType)) signal.dispatch(inputValue);
	}
	
	public function Link(callback:Event -> Void, ?once:Bool = false):Void
	{
		
		if (once) signal.addOnce(callback);
		else signal.add(callback);
		
	}
	
	public function UnLink(callback:Event -> Void = null):Void
	{
		
		if (callback != null) signal.remove(callback);
		else signal.removeAll();
		
	}
	
	public function AddAssociatedInput(addedInput:String, inputType:String):Void{
		
		if (get_associatedInputs().indexOf(addedInput) == -1){
			var detail : InputDetails = {type:inputType, input : addedInput};
			associatedInputs.push(detail);
		}
		
	}
	
	public function RemoveAssociatedInput(removedInput:String):Void
	{
		for (detail in associatedInputs){
			
			if (detail.input == removedInput) associatedInputs.remove(detail);
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
	
	private inline function CheckInputType(inputID:String, inputType:String):Bool
	{
		var success:Bool = false;
		
		for (detail in associatedInputs){
			
			if (success = (detail.input == inputID && detail.type == inputType))
				break;
		}
		
		return success;
	}
}

typedef InputDetails =
{
	var input : String;
	var type : String;
}