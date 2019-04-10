package beardFramework.resources.save.data;

/**
 * @author Ludo
 */
typedef StructDataSound =
{
	>StructDataGeneric,
		
	
	
}
@:forward
abstract DataSound(StructDataSound) from StructDataSound to StructDataSound {
  inline public function new(data:StructDataSound) {
    this = data;
  }
}