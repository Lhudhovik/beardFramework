package beardFramework.input;

/**
 * ...
 * @author 
 */
abstract Input(String) from String to String
{
	public static inline var  DELIMITER:String = "_";
	public static inline function FromInputData(inputID:String, inputType:InputType) :Input
	{
		return inputID + DELIMITER + InputManager.InputTypeToString(inputType);		
	}
	public inline function new(string:String) {
        this = string;
    }
	
	public inline function GetInputID():String
	{
		return this.split(DELIMITER)[0];
	}
	
	
	
	public inline function GetInputType():InputType
	{
		return InputManager.StringToInputType(this.split(DELIMITER)[1]);
	}
}