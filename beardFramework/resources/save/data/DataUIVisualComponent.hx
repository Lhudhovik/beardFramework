package beardFramework.resources.save.data;

/**
 * @author Ludo
 */
typedef DataUIVisualComponent =
{
	>DataUIComponent,
	var atlas:String;
	var texture:String;
	
}

@:forward
abstract AbstractDataUIVisualComponent(DataUIVisualComponent) from DataUIVisualComponent to DataUIVisualComponent {
  inline public function new(data:DataUIVisualComponent) {
    this = data;
  }
}