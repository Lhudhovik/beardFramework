package beardFramework.interfaces;

/**
 * @author Ludo
 */
interface IPool<TClass>
{
  
	public function Get<TClass>():TClass;
	
	public function Release<TClass>(instance:TClass):TClass;
	
	public function Populate<TClass>(elements:Array<TClass>):TClass;
	
	public function GetFreeInstancesCount():Int;
	
	public function GetUsedInstancesCount():Int;
	
	public function HasFreeInstances():Bool;
	

}