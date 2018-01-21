package beardFramework.input;

/**
 * @author Ludo
 */
typedef Action =
{
	var ID:String;
	var active:Bool;
	var callbackDetails:Array<CallbackDetails>;	
}

typedef CallbackDetails =
{
	var callback:Float->Void;
	var targetName:String;
	var once:Bool;
}

