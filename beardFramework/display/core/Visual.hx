package beardFramework.display.core;

import beardFramework.display.rendering.VisualRenderer;
import beardFramework.resources.assets.AssetManager;
import beardFramework.resources.assets.Atlas.SubTextureData;
import haxe.ds.Vector;
import openfl.geom.Matrix;

/**
 * ...
 * @author 
 */
class Visual extends RenderedObject
{
	private static var instanceCount:Int = 0;
	
	public var atlas:String;
	public var texture:String;
	public var textureHeight(default, null):Int;
	public var textureWidth(default, null):Int;
	
	public function new(texture:String, atlas:String , name:String = "") 
	{
		super();
		
		if (name == "") name = "Visual_" + instanceCount;
		instanceCount++;
	
		this.texture = texture;
		this.atlas = atlas;
		transform = new Matrix();
		visible = true;
		alpha = 1;
		color = 0xffffff;
		
		z = -1;
		renderDepth = -2;
		
		var texture:SubTextureData = AssetManager.Get().GetSubTextureData(texture, atlas);
		textureWidth = Math.round(texture.imageArea.width);
		textureHeight = Math.round(texture.imageArea.height);
		trace(texture.atlasIndex);
		
		width = textureWidth;
		height = textureHeight;
		
		bufferIndex = -1;
		
		displayingCameras = new List<String>();
	}
	
	override function set_width(value:Float):Float 
	{
		if (value != textureWidth)			
			scaleX = value / textureWidth;
			
		else 		
			scaleX = 1;
		
		isDirty = true;
		return value;
	}
	
	override function set_height(value:Float):Float 
	{
		if (value != textureHeight)			
			scaleY = value / textureHeight;
			
		else 		
			scaleY = 1;
		
		isDirty = true;
		return value;
	}
	
	override private function set_scaleX (value:Float):Float 
	{
		
		if (cachedScaleX != value) {
			
			cachedScaleX = value;
			
			if (transform.b == 0) {
				
				transform.a = value;
				
			} else {
				
				var rotation = this.rotation;
				
				var a = rotationCosine * value;
				var b = rotationSine * value;
				
				transform.a = a;
				transform.b = b;
				
			}
			
		}
		cachedWidth = textureWidth * value;
		
		isDirty = true;
		return value;
		
	}
	
	override private function set_scaleY (value:Float):Float 
	{
		
		if (cachedScaleY != value) {
			
			cachedScaleY = value;
			
			if (transform.c == 0) {
				
				transform.d = value;
				
			} else {
				
				var rotation = this.rotation;
				
				var c = -rotationSine * value;
				var d = rotationCosine * value;
				
				transform.c = c;
				transform.d = d;
				
			}
			
		}
		
		cachedHeight = textureHeight * value;
		isDirty = true;
		
		return value;
		
	}
		
	public inline function GetTextureData():SubTextureData
	{
		return AssetManager.Get().GetSubTextureData(texture, atlas);
	}
	
	override function set_isDirty(value:Bool):Bool 
	{
		if(value == true && layer != null) layer.AddVisualDirty(this);
		return isDirty = value;
	}

}

