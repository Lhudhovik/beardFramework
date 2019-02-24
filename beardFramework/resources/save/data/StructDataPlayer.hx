package beardFramework.resources.save.data;

/**
 * @author Ludo
 */
typedef StructDataPlayer =
{
	>StructDataGeneric,
	
	
}
@:forward
abstract DataPlayer(StructDataPlayer) from StructDataPlayer to StructDataPlayer {
  inline public function new(data:StructDataPlayer) {
    this = data;
  }
}