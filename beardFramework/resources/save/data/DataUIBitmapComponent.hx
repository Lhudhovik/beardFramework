package beardFramework.resources.save.data;

/**
 * @author Ludo
 */
typedef DataUIBitmapComponent =
{
	>DataUIComponent,
	var atlas:String;
	var texture:String;
	
}

@:forward
abstract AbstractDataUIBitmapComponent(DataUIBitmapComponent) from DataUIBitmapComponent to DataUIBitmapComponent {
  inline public function new(data:DataUIBitmapComponent) {
    this = data;
  }
}