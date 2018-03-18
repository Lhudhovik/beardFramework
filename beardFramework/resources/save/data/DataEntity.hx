package beardFramework.resources.save.data;

/**
 * @author Ludo
 */
typedef DataEntity =
{
	>DataGeneric,
	
	var x:Float;
	var y:Float;
	var components:Array<DataComponent>;
	var additionalData:String;
}