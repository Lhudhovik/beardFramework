package beardFramework.resources.assets;

import beardFramework.display.rendering.FontRenderer;
import beardFramework.display.rendering.VisualRenderer;
import beardFramework.resources.assets.Atlas.SubTextureData;
import beardFramework.utils.GeomUtils;
import beardFramework.utils.GeomUtils.SimpleRect;
import lime.graphics.Image;
import lime.graphics.opengl.GL;
import lime.math.Rectangle;
import lime.text.Font;
import lime.text.Glyph;
import lime.text.GlyphMetrics;
import openfl.display.BitmapData;
import openfl.geom.Point;

/**
 * ...
 * @author 
 */
class FontAtlas extends Atlas 
{
	static private var MAXSIZE:Int = 2048;
	
	private var fonts:Array<AtlasFontData>;
	private var currentLineHeight:Float = 0;
	
	public function new(name:String) 
	{
		super(name, null, null);
		
		fonts = new Array();
		
		atlasBitmapData = new BitmapData(MAXSIZE, MAXSIZE);
		
	}
	
	public function AddFont(font:Font, fontName:String, size:Int = 72):Void
	{
		trace("Add Font");
		var glyphs:Map<Glyph, Image> = font.renderGlyphs(font.getGlyphs(), 32);
		var tempBD:BitmapData;
		var previousGlyphPosition:SubTextureData = null;
		var currentGlyph:String = "";
		var imageArea:Rectangle = new Rectangle();
		var copyPoint:Point = new Point();
		//var frame:Rectangle = new Rectangle();
		var fontData:AtlasFontData = {name:fontName, firstGlyph:"", firstGlyphPosition:null, lastGlyph:"", lastGlyphPosition:null};
					
		for (glyph in glyphs.keys())
		{
			//metrics = font.getGlyphMetrics(glyph);
		
			currentGlyph = String.fromCharCode(glyph);
				trace("Creating bitmap for " + fontName + "character : "  + currentGlyph);
			tempBD = BitmapData.fromImage(glyphs[glyph]);
			
			if (previousGlyphPosition == null)
			{
				if (fonts.length > 0){
					imageArea = fonts[fonts.length - 1].lastGlyphPosition.imageArea;
					imageArea.x += imageArea.width;
				}
			}
			else
			{
				imageArea.x = previousGlyphPosition.imageArea.x + previousGlyphPosition.imageArea.width;
				imageArea.y = previousGlyphPosition.imageArea.y;				
			}
			
			imageArea.width = tempBD.width;
			imageArea.height = tempBD.height;
				
			if (imageArea.x > atlasBitmapData.width || imageArea.x + imageArea.width > atlasBitmapData.width)
			{
				imageArea.x = 0;
				imageArea.y += currentLineHeight;										
			}
			
			if (imageArea.height > currentLineHeight) currentLineHeight = imageArea.height;
			
						
			previousGlyphPosition = subAreas[fontName + currentGlyph] = {
				imageArea:	imageArea.clone(),
				frame:		null,
				rotated : 	false,
				uvX: 		imageArea.x/atlasBitmapData.width,
				uvY: 		imageArea.y/atlasBitmapData.height,
				uvW:		imageArea.width/atlasBitmapData.width,
				uvH:		imageArea.height/atlasBitmapData.height,
				atlasIndex: this.index
			}
				
			copyPoint.setTo(imageArea.x, imageArea.y);
			atlasBitmapData.copyPixels(tempBD, tempBD.rect, copyPoint);
			
			if (fontData.firstGlyphPosition == null)
			{
				fontData.firstGlyph = currentGlyph;
				fontData.firstGlyphPosition = previousGlyphPosition;
			}
			
			glyphs[glyph] = null;
			tempBD.disposeImage();
			tempBD.dispose();
			
		}
		
		if (previousGlyphPosition != null)
		{
			fontData.lastGlyph = currentGlyph;
			fontData.lastGlyphPosition = previousGlyphPosition;
		}
		
		fonts.push(fontData);
		//
		GL.activeTexture(GL.TEXTURE0 + FontRenderer.Get().GetFreeTextureIndex());
		
		texture = GetTexture(atlasBitmapData.image);
		
		GL.bindTexture(GL.TEXTURE_2D, texture);
		FontRenderer.Get().ActivateTexture(FontRenderer.Get().GetFreeTextureIndex());
		
		
	}
	
	
	//public function OnFontLoaded():Void
	//{
		//
	//}
	//private function GetFreeSpace():SimpleRect
	//{
		//
		//var freeSpace:SimpleRect = GeomUtils.utilSimpleRect;
		//
		//freeSpace.height = freeSpace.width = freeSpace.x = freeSpace.y;
		//
		//
		//
		//
		//
	//}
	
	public inline function ContainsFont(fontName:String):Bool
	{
		var containsFont:Bool = false;
		for (fontData in fonts)
		{
			if (containsFont = (name == fontData.name)) break;
		}
		
		return containsFont;
	}
	
	public inline function GetGlyphData(font:String, glyph:String):SubTextureData
	{
		
		return subAreas[font + glyph];
		
	}
	
}

typedef AtlasFontData =
{
	public var name:String;
	public var firstGlyph:String;
	public var firstGlyphPosition:SubTextureData;
	public var lastGlyph:String;
	public var lastGlyphPosition:SubTextureData;
	
}