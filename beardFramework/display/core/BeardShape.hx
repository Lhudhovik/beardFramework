package beardFramework.display.core;
import beardFramework.display.core.BeardDisplayObject;
import openfl.display.Graphics;


#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end

@:access(openfl.display.Graphics)


class BeardShape extends BeardDisplayObject {
	
	
	public var graphics (get, never):Graphics;
	
	
	public function new () {
		
		super ();
		
	}
	
	
	
	
	// Get & Set Methods
	
	
	
	
	private function get_graphics ():Graphics {
		
		if (__graphics == null) {
			
			__graphics = new Graphics (this);
			
		}
		
		return __graphics;
		
	}
	
	
}