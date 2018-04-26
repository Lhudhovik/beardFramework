package beardFramework.resources.save.data;

/**
 * @author Ludo
 */
typedef DataPlayer =
{
	>DataGeneric,
	
	
}
@:forward
abstract AbstractDataPlayer(DataPlayer) from DataPlayer to DataPlayer {
  inline public function new(data:DataPlayer) {
    this = data;
  }
}