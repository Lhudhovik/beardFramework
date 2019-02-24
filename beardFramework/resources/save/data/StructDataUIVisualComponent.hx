package beardFramework.resources.save.data;

/**
 * @author Ludo
 */
typedef StructDataUIVisualComponent =
{
	>StructDataUIComponent,
	var atlas:String;
	var texture:String;
	
}

@:forward
abstract DataUIVisualComponent(StructDataUIVisualComponent) from StructDataUIVisualComponent to StructDataUIVisualComponent {
  inline public function new(data:StructDataUIVisualComponent) {
    this = data;
  }
}