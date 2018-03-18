package beardFramework.resources.save.data;
import beardFramework.display.cameras.Camera;

/**
 * @author Ludo
 */
typedef DataScreen =
{
  
	>DataGeneric,
	
	var cameras:Array<DataCamera>;
	var entitiesData:Array<DataEntity>;
	

}