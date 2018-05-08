package beardFramework.display.heritage;

import beardFramework.display.cameras.Camera;
import openfl.display.TileArray;
import lime.graphics.opengl.GLBuffer;
import lime.graphics.GLRenderContext;
import lime.utils.Float32Array;
import openfl.display.Tileset;
import openfl.geom.ColorTransform;
import openfl.geom.Matrix;
import openfl.geom.Rectangle;
import openfl.Vector;

@:access(openfl.display.Tileset)
@:access(openfl.geom.ColorTransform)
@:access(openfl.geom.Matrix)
@:access(openfl.geom.Rectangle)

@:access(openfl.display.TileArray)
/**
 * ...
 * @author 
 */
class BeardTileArray extends TileArray 
{
	
	public var onCamera (get, set):Bool;
	private var __onCamera:Vector<Bool>;
	public function new(length:Int=0) 
	{
		super(length);
		__onCamera = new Vector<Bool> (length);
	}
	
	private function __updateGLBufferThroughCamera (gl:GLRenderContext, defaultTileset:Tileset, worldAlpha:Float, defaultColorTransform:ColorTransform, camera:Camera):GLBuffer 
	{
		
		// TODO: More closely align internal data format with GL buffer format?
		
		var attributeLength = 25;
		var stride = attributeLength * 6;
		var bufferLength = __length * stride;
		
		if (__bufferData == null) {
			
			__bufferData = new Float32Array (bufferLength);
			__bufferSkipped = new Vector<Bool> (__length);
			__bufferDirty = true;
			
		} else if (__bufferData.length != bufferLength) {
			
			// TODO: Use newer Lime GL buffer API to pass length, do not need to recreate if size shrinks
			
			var data = new Float32Array (bufferLength);
			
			if (__bufferData.length <= data.length) {
				
				data.set (__bufferData);
				
				if (__bufferData.length == 0) {
					
					__bufferDirty = true;
					
				} else {
					
					var cacheLength = __bufferData.length;
					for (i in cacheLength...bufferLength) {
						__dirty[TileArray.ALL_DIRTY_INDEX + (position * TileArray.DIRTY_LENGTH)] = true;
					}
					
				}
				
			} else {
				
				data.set (__bufferData.subarray (0, data.length));
				
			}
			
			__bufferData = data;
			__bufferSkipped.length = __length;
			__bufferDirty = true;
			
		}
		
		if (__buffer == null || __bufferContext != gl) {
			
			__bufferContext = gl;
			__buffer = gl.createBuffer ();
			
		}
		
		gl.bindBuffer (gl.ARRAY_BUFFER, __buffer);
		
		// TODO: Handle __dirty flags, copy only changed values
		
		if (__bufferDirty || (__cacheAlpha != worldAlpha) || (__cacheDefaultTileset != defaultTileset)) {
			
			var tileMatrix, tileColorTransform, tileRect = null;
			
			// TODO: Dirty algorithm per tile?
			
			var offset = 0;
			var alpha, visible, tileset, tileData, id;
			var bitmapWidth, bitmapHeight, tileWidth:Float, tileHeight:Float;
			var uvX, uvY, uvWidth, uvHeight;
			var x, y, x2, y2, x3, y3, x4, y4;
			var redMultiplier, greenMultiplier, blueMultiplier, alphaMultiplier;
			var redOffset, greenOffset, blueOffset, alphaOffset;
			
			position = 0;
			
			var __skipTile = function (i, offset:Int):Void {
				
				for (i in 0...6) {
					
					__bufferData[offset + (attributeLength * i) + 4] = 0;
					
				}
				
				__bufferSkipped[i] = true;
				
			}
			
			for (i in 0...__length) {
				
				position = i;
				offset = i * stride;
				
				alpha = this.alpha;
				visible = this.visible;
				
				if (!visible ||!onCamera || alpha <= 0) {
					
					__skipTile (i, offset);
					continue;
					
				}
				
				tileset = this.tileset;
				if (tileset == null) tileset = defaultTileset;
				if (tileset == null) {
					
					__skipTile (i, offset);
					continue;
					
				}
				
				id = this.id;
				
				if (id > -1) {
					
					if (id >= tileset.__data.length) {
						
						__skipTile (i, offset);
						continue;
						
					}
					
					tileData = tileset.__data[id];
					
					if (tileData == null) {
						
						__skipTile (i, offset);
						continue;
						
					}
					
					

					tileWidth = tileData.width;
					tileHeight = tileData.height;
					uvX = tileData.__uvX;
					uvY = tileData.__uvY;
					uvWidth = tileData.__uvWidth;
					uvHeight = tileData.__uvHeight;
					
				} else {
					
					tileRect = this.rect;
					
					if (tileRect == null) {
						
						__skipTile (i, offset);
						continue;
						
					}
					
					tileWidth = tileRect.width;
					tileHeight = tileRect.height;
					
					if (tileWidth <= 0 || tileHeight <= 0) {
						
						__skipTile (i, offset);
						continue;
						
					}
					
					bitmapWidth = tileset.__bitmapData.width;
					bitmapHeight = tileset.__bitmapData.height;
					uvX = tileRect.x / bitmapWidth;
					uvY = tileRect.y / bitmapHeight;
					uvWidth = tileRect.right / bitmapWidth;
					uvHeight = tileRect.bottom / bitmapHeight;
					
				}
				
				
				
				tileMatrix = this.matrix;
				
				x = tileMatrix.__transformX (0, 0);
				y = tileMatrix.__transformY (0, 0);
				x2 = tileMatrix.__transformX (tileWidth, 0);
				y2 = tileMatrix.__transformY (tileWidth, 0);
				x3 = tileMatrix.__transformX (0, tileHeight);
				y3 = tileMatrix.__transformY (0, tileHeight);
				x4 = tileMatrix.__transformX (tileWidth, tileHeight);
				y4 = tileMatrix.__transformY (tileWidth, tileHeight);
				
				alpha *= worldAlpha;
				
				tileColorTransform = this.colorTransform;
				tileColorTransform.__combine (defaultColorTransform);
				
				redMultiplier = tileColorTransform.redMultiplier;
				greenMultiplier = tileColorTransform.greenMultiplier;
				blueMultiplier = tileColorTransform.blueMultiplier;
				alphaMultiplier = tileColorTransform.alphaMultiplier;
				redOffset = tileColorTransform.redOffset;
				greenOffset = tileColorTransform.greenOffset;
				blueOffset = tileColorTransform.blueOffset;
				alphaOffset = tileColorTransform.alphaOffset;
				
				__bufferData[offset + 0] = x;
				__bufferData[offset + 1] = y;
				__bufferData[offset + 2] = uvX;
				__bufferData[offset + 3] = uvY;
				
				__bufferData[offset + attributeLength + 0] = x2;
				__bufferData[offset + attributeLength + 1] = y2;
				__bufferData[offset + attributeLength + 2] = uvWidth;
				__bufferData[offset + attributeLength + 3] = uvY;
				
				__bufferData[offset + (attributeLength * 2) + 0] = x3;
				__bufferData[offset + (attributeLength * 2) + 1] = y3;
				__bufferData[offset + (attributeLength * 2) + 2] = uvX;
				__bufferData[offset + (attributeLength * 2) + 3] = uvHeight;
				
				__bufferData[offset + (attributeLength * 3) + 0] = x3;
				__bufferData[offset + (attributeLength * 3) + 1] = y3;
				__bufferData[offset + (attributeLength * 3) + 2] = uvX;
				__bufferData[offset + (attributeLength * 3) + 3] = uvHeight;
				
				__bufferData[offset + (attributeLength * 4) + 0] = x2;
				__bufferData[offset + (attributeLength * 4) + 1] = y2;
				__bufferData[offset + (attributeLength * 4) + 2] = uvWidth;
				__bufferData[offset + (attributeLength * 4) + 3] = uvY;
				
				__bufferData[offset + (attributeLength * 5) + 0] = x4;
				__bufferData[offset + (attributeLength * 5) + 1] = y4;
				__bufferData[offset + (attributeLength * 5) + 2] = uvWidth;
				__bufferData[offset + (attributeLength * 5) + 3] = uvHeight;
				
				for (i in 0...6) {
					
					__bufferData[offset + (attributeLength * i) + 4] = alpha;
					
					// 4 x 4 matrix
					__bufferData[offset + (attributeLength * i) + 5] = redMultiplier;
					__bufferData[offset + (attributeLength * i) + 10] = greenMultiplier;
					__bufferData[offset + (attributeLength * i) + 15] = blueMultiplier;
					__bufferData[offset + (attributeLength * i) + 20] = alphaMultiplier;
					
					__bufferData[offset + (attributeLength * i) + 21] = redOffset / 255;
					__bufferData[offset + (attributeLength * i) + 22] = greenOffset / 255;
					__bufferData[offset + (attributeLength * i) + 23] = blueOffset / 255;
					__bufferData[offset + (attributeLength * i) + 24] = alphaOffset / 255;
					
				}
				
				__bufferSkipped[i] = false;
				
			}
			
			gl.bufferData (gl.ARRAY_BUFFER, __bufferData.byteLength, __bufferData, gl.DYNAMIC_DRAW);
			
			__cacheAlpha = worldAlpha;
			__cacheDefaultTileset = defaultTileset;
			__bufferDirty = false;
			
		}
		
		return __buffer;
		
	}
	
	override private function set_length (value:Int):Int 
	{
		
		__onCamera.length = value;
		super.set_length(value);
		return value;
		
	}
	
	private inline function get_onCamera ():Bool 
	{
		
		return __onCamera[position];
		
	}
	
	private inline function set_onCamera (value:Bool):Bool 
	{
		
		__onCamera[position] = value;
		return value;
		
	}
	
	public static function FromTileArray(tileArray:TileArray):BeardTileArray
	{
		var beardTileArray:BeardTileArray = new BeardTileArray(tileArray.length);
		
		beardTileArray.__cacheAlpha = tileArray.__cacheAlpha;
		beardTileArray.__data = tileArray.__data ;
		beardTileArray.__dirty = tileArray.__dirty;
		beardTileArray.__shaders = tileArray.__shaders;
		beardTileArray.__tilesets = tileArray.__tilesets;
		beardTileArray.__visible = tileArray.__visible;
		
		
		return beardTileArray;
	}
}