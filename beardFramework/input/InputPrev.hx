package beardFramework.input;

/**
 * @author Ludo
 */

 typedef InputPrev =
{
	var ID:String;
	var state:InputType;
	var value:Float;
	var target:String;
	var toggle:InputType;
	var active:Bool;
	
}






//******************************************************************V1
//package beardFramework.input;
//import beardFramework.input.InputAction;
//import beardFramework.input.InputAction.InputDetails;
//import msignal.Signal;
////import openfl.events.Event;
//
///**
 //* ...
 //* @author Ludo
 //*/
//class InputAction
//{
	//
	//private var callbacks:Array<CallbackDetails>;
	//private var associatedInputs:Array<InputDetails>;
	//private var compatibleActions:Array<String>;
	//public var activated:Bool;
	//
	//public function new(defaultCompatibleActionsIDs : Array<String> = null) 
	//{
		//callbacks = new Array<CallbackDetails>();
		//associatedInputs = new Array<InputDetails>();
		//compatibleActions = defaultCompatibleActionsIDs != null ? defaultCompatibleActionsIDs : new Array<String>();
	//}
	//
	//public inline function get_associatedInputs():Array<InputDetails>return associatedInputs;
	//public inline function get_compatibleActions():Array<String> return compatibleActions;
	//
	//public inline function Proceed(inputValue:Float=0, targetName:String=""):Void
	//{
		//
		//for (detail in callbacks){
			//
			//if (detail.targetName == targetName){
				//detail.callback(inputValue);
				//if (detail.once) callbacks.remove(detail);
			//}
		//}
			//
	//}
	//
	//public function Link(callback:Float -> Void, once:Bool = false, targetName:String=""):Void
	//{
		//var callbackDetail : CallbackDetails = {callback:callback, once:once, targetName:targetName};
		//
		//
		//if(!CheckIsExisting(callbackDetail)) callbacks.push(callbackDetail);
		//trace(callbacks);
	//}
	//
	//public function UnLink(callback:Float -> Void = null, targetName:String = ""):Void
	//{
		//
		//for (detail in callbacks){
			//if ( callback == null || ( (targetName == ""|| targetName == detail.targetName)  && detail.callback == callback) ) 
				//callbacks.remove(detail);
		//}
		//
	//}
	//
	//public function AddAssociatedInput(input:String, inputType:InputType):Void{
		//
		//for (detail in associatedInputs)
		//{
			//if(detail.input == input && detail.type == inputType) return;
			//
		//}
		//
		//var detail : InputDetails = {type:inputType, input : input};
		//associatedInputs.push(detail);
		//
		//
	//}
	//
	//public function RemoveAssociatedInput(removedInput:String, inputType:InputType):Void
	//{
		//for (detail in associatedInputs){
			//
			//if (detail.input == removedInput && detail.type == inputType) associatedInputs.remove(detail);
		//}
		//
	//}
	//
	//public function AddCompatibleAction(addedAction:String):Void{
		//
		//if (compatibleActions.indexOf(addedAction) == -1) compatibleActions.push(addedAction);
		//
	//}
	//
	//public function RemoveCompatibleAction(removedAction:String):Void
	//{
		//compatibleActions.remove(removedAction);
	//}
	//
	//private inline function CheckIsExisting(checkedDetail : CallbackDetails):Bool
	//{
		//var success:Bool = false;
		//
		//for (detail in callbacks){
			//
			//if (success = (detail.callback == checkedDetail.callback && detail.targetName == checkedDetail.targetName))
				//break;
		//}
		//
		//return success;
	//}
	//
//}
//
//typedef InputDetails =
//{
	//var input : String;
	//var type : InputType;
//}
//
//typedef CallbackDetails =
//{
	//var callback:Float->Void;
	//var targetName:String;
	//var once:Bool;
//}