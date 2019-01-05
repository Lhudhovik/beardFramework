package beardFramework.resources.assets;

import beardFramework.graphics.rendering.Renderer;
import beardFramework.resources.assets.Atlas.SubTextureData;
import beardFramework.utils.DataUtils;
import beardFramework.utils.GeomUtils;
import beardFramework.utils.GeomUtils.SimpleRect;
import haxe.Utf8;
import lime.graphics.ImageBuffer;
import lime.graphics.ImageFileFormat;
import lime.graphics.PixelFormat;
import lime.utils.UInt8Array;
import lime.graphics.Image;
import lime.graphics.opengl.GL;
import lime.math.Rectangle;
import lime.math.Vector2;
import lime.text.Font;
import lime.text.Glyph;
import lime.text.GlyphMetrics;


/**
 * ...
 * @author 
 */
class FontAtlas extends Atlas 
{
	static private var MAXSIZE:Int = 2048;
		
	public var fonts:Array<AtlasFontData>;
	private var currentLineHeight:Float = 0;
	public var ordered:Array<String>;
	public function new(name:String) 
	{
		super(name, null, null);
		
		fonts = new Array();
	ordered = [];
		textureImage = new Image(null, 0, 0, MAXSIZE, MAXSIZE);
		subAreas[name].imageArea.width = MAXSIZE;
		subAreas[name].imageArea.height = MAXSIZE;
		//trace(index);
	}
	
	public function AddFont(font:Font, fontName:String, size:Int = 72):Void
	{
	
		var fontGlyphsList:Array<NativeGlyphData> = font.decompose().glyphs;
		var previousGlyphPosition:SubTextureData = null;
		var fontData:AtlasFontData = {name:fontName, size:size, firstGlyph:"", firstGlyphPosition:null, lastGlyph:"", lastGlyphPosition:null};

		var imageArea:Rectangle = new Rectangle(0,0,0,0);
		var char:String = "";
		var glyph:Glyph;
		var glyphDataIndex:Int;
		var textureDataIndex:Int;
		//trace(fontName + " --------------------------------------------------------------------------");
		//trace(fontGlyphsList);
		var keeys:Array<String> = [];
		var count:Int = 0;
		for (nativeGlyph in fontGlyphsList){
			
			//trace(nativeGlyph.char_code);
			char = String.fromCharCode(nativeGlyph.char_code);
			
			if (char != null && char != ""){
				char = Utf8.encode(char);
				
				glyph = font.getGlyph(char);
				if (glyph == 0)
					glyph = new Glyph(nativeGlyph.char_code);
				
				var glyphImage:Image = font.renderGlyph(glyph, size);
				
				if (glyphImage != null)
				{
							count++;
					if (previousGlyphPosition == null)
					{
						if (fonts.length > 0){
							
							imageArea = fonts[fonts.length - 1].lastGlyphPosition.imageArea;
							imageArea.x += imageArea.width;
							
						}
					}
					else
					{
						imageArea.x = previousGlyphPosition.imageArea.x + previousGlyphPosition.imageArea.width+2;
						imageArea.y = previousGlyphPosition.imageArea.y;				
					}
					
					imageArea.width = glyphImage.width;
					imageArea.height = glyphImage.height;
					
					if (imageArea.x > MAXSIZE || imageArea.x + imageArea.width > MAXSIZE)
					{
						imageArea.x = 0;
						imageArea.y += currentLineHeight;										
					}
					
					if (imageArea.height > currentLineHeight) currentLineHeight = imageArea.height+2;
					
					
					
					for (x in 0...cast(imageArea.width,Int))
					{
						for (y in 0...cast(imageArea.height,Int))
						{
							glyphDataIndex = (y * glyphImage.width + x);
							textureDataIndex = cast( ((y+imageArea.y) * textureImage.width + x + imageArea.x) * 4,Int);
						
							textureImage.data[textureDataIndex] = 255;
							textureImage.data[textureDataIndex + 1] =255;
							textureImage.data[textureDataIndex + 2] = 255;
							textureImage.data[textureDataIndex + 3] = glyphImage.data[glyphDataIndex];
							
						}
						
					}
					
					ordered.push(fontName + size + char);
					previousGlyphPosition = subAreas[fontName + size + char] = {
						imageArea:	imageArea.clone(),
						frame:		null,
						rotated : 	false,
						uvX: 		(imageArea.x)/MAXSIZE,
						uvY: 		(imageArea.y)/MAXSIZE,
						uvW:		(imageArea.width)/MAXSIZE,
						uvH:		(imageArea.height)/MAXSIZE,
						atlasIndex: this.index
					}
								
					if (fontData.firstGlyphPosition == null)
					{
						fontData.firstGlyph = char;
						fontData.firstGlyphPosition = previousGlyphPosition;
					}
					if (previousGlyphPosition != null)
					{
						fontData.lastGlyph = char;
						fontData.lastGlyphPosition = previousGlyphPosition;
					}
					
					glyphImage = null;
					
				}
				
				
			}
			
		}
	
		
		
		fonts.push(fontData);
		//trace(count);
		if (textureIndex < 0) textureIndex = Renderer.Get().AllocateFreeTextureIndex();
		GL.activeTexture(GL.TEXTURE0 + textureIndex);
		texture = GetTexture(textureImage);
		GL.bindTexture(GL.TEXTURE_2D, texture);
		Renderer.Get().UpdateTexture(textureIndex);
		//trace(size + " " +keeys);
	}
	
	public inline function ContainsFont(fontName:String, size:Int = 32):Bool
	{
		var containsFont:Bool = false;
		for (fontData in fonts)
		{
			if (containsFont = (fontName == fontData.name && size == fontData.size)) break;
		}
		
		return containsFont;
	}
	
	public inline function GetGlyphData(font:String, glyph:String, size:Int):SubTextureData
	{
		
		var closerSize:Int = 0;
		if (!ContainsFont(font, size)){
			
			for (_font in fonts)
				if (_font.name == font && (closerSize == 0 || Math.abs(_font.size - size) < Math.abs(closerSize -size)))
					closerSize = _font.size;
		}
		else closerSize = size;
		if (subAreas[font + closerSize + glyph] == null)
		trace("null encountered " + glyph + " " +  glyph);
		trace(glyph);
		return subAreas[font + closerSize + glyph];
		
	}
	
}

typedef AtlasFontData =
{
	public var name:String;
	public var size:Int;
	public var firstGlyph:String;
	public var firstGlyphPosition:SubTextureData;
	public var lastGlyph:String;
	public var lastGlyphPosition:SubTextureData;
	
}
