package beardFramework.input;
import beardFramework.input.data.InputData;
import beardFramework.resources.MinAllocArray;

/**
 * @author Ludo
 */
typedef Action =
{
	var ID:String;
	var active:Bool;
	//var inputs:MinAllocArray<Input>;
	var callbackDetails:MinAllocArray<CallbackDetails>;	
}

typedef CallbackDetails =
{
	var callback:InputData->Void;
	var target:String;
	var once:Bool;
}

typedef ResolvedAction =
{
	var callback:InputData->Void;
	var data:InputData;
}

