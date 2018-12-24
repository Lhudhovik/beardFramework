package beardFramework.resources.assets;

import beardFramework.graphics.rendering.Renderer;
import beardFramework.graphics.rendering.TextRenderer;
import beardFramework.graphics.rendering.VisualRenderer;
import beardFramework.resources.assets.Atlas.SubTextureData;
import beardFramework.utils.DataUtils;
import beardFramework.utils.GeomUtils;
import beardFramework.utils.GeomUtils.SimpleRect;
import lime.graphics.ImageBuffer;
import lime.graphics.ImageFileFormat;
import lime.graphics.PixelFormat;
import lime.text.harfbuzz.HBBuffer;
import lime.utils.UInt8Array;
//import extension.harfbuzz.OpenflHarbuzzCFFI;
//import extension.harfbuzz.OpenflHarbuzzCFFI.GlyphAtlas;
//import extension.harfbuzz.OpenflHarfbuzzRenderer;
//import extension.harfbuzz.ScriptIdentificator;
//import extension.harfbuzz.TextDirection;
//import extension.harfbuzz.TextScript;
import lime.graphics.Image;
import lime.graphics.opengl.GL;
import lime.math.Rectangle;
import lime.math.Vector2;
import lime.text.Font;
import lime.text.Glyph;
import lime.text.GlyphMetrics;
import lime.text.harfbuzz.HB;
import lime.text.harfbuzz.HBBlob;
import lime.text.harfbuzz.HBFTFont;
import lime.text.harfbuzz.HBFace;
import lime.text.harfbuzz.HBFont;
import openfl.display.BitmapData;
import openfl.geom.Point;

/**
 * ...
 * @author 
 */
class FontAtlas extends Atlas 
{
	static private var MAXSIZE:Int = 2048;
		
	public var fonts:Array<AtlasFontData>;
	private var currentLineHeight:Float = 0;
	
	public function new(name:String) 
	{
		super(name, null, null);
		
		fonts = new Array();
		
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
		
		for (nativeGlyph in fontGlyphsList){
			char = String.fromCharCode(nativeGlyph.char_code);
			
			if (char != null && char != ""){
				
				glyph = font.getGlyph(char);
				if (glyph == 0)
					glyph = new Glyph(nativeGlyph.char_code);
				
				var glyphImage:Image = font.renderGlyph(glyph, size);
				
				if (glyphImage != null)
				{
							
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
					
					imageArea.width = glyphImage.width;
					imageArea.height = glyphImage.height;
					
					if (imageArea.x > MAXSIZE || imageArea.x + imageArea.width > MAXSIZE)
					{
						imageArea.x = 0;
						imageArea.y += currentLineHeight;										
					}
					
					if (imageArea.height > currentLineHeight) currentLineHeight = imageArea.height;
					
					
					
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
					
					previousGlyphPosition = subAreas[fontName + size + char] = {
						imageArea:	imageArea.clone(),
						frame:		null,
						rotated : 	false,
						uvX: 		imageArea.x/MAXSIZE,
						uvY: 		imageArea.y/MAXSIZE,
						uvW:		imageArea.width/MAXSIZE,
						uvH:		imageArea.height/MAXSIZE,
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
		
		if (textureIndex < 0) textureIndex = Renderer.Get().AllocateFreeTextureIndex();
		GL.activeTexture(GL.TEXTURE0 + textureIndex);
		texture = GetTexture(textureImage);
		GL.bindTexture(GL.TEXTURE_2D, texture);
		Renderer.Get().UpdateTexture(textureIndex);
		
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


//public function AddFont(font:Font, fontName:String, size:Int = 72):Void
	//{
		////Get original glyph data
		//var fontGlyphsList:Array<NativeGlyphData> = font.decompose().glyphs;
		//var string:String = "";
		//var char:String = "";
		//var glyphs:Map<String, Image> = new Map();
		//var glyphto:Array<Glyph> = new Array();
		//var gglyph:Glyph;
		//for (glyph in fontGlyphsList){
			//char = String.fromCharCode(glyph.char_code);
			//if (char != null && char != ""){
				//
				//gglyph = font.getGlyph(char);
				//if (gglyph == 0)
				//gglyph = new Glyph(glyph.char_code);
				//var image:Image = font.renderGlyph(gglyph, 72);
				////trace(font.getGlyph(char));
				//if (image != null)
				//{
					//glyphs[char] = image;	
					//
					//string += String.fromCharCode(glyph.char_code);
					//glyphto.push(font.getGlyph(char));
				//}
				//
				////string += String.fromCharCode(glyph.char_code);
			//}
			//
		//}
		//
		////extract visuals
		////var glyphs:Map<Glyph, Image> = font.renderGlyphs(glyphto, 72);
		//var image:Image = new Image(null, 0, 0, MAXSIZE, MAXSIZE);
		//var buffer:ImageBuffer;
	//
		////for (image in glyphs){
			////buffer = image.buffer;
			////break;
		////}
		////
		////var bufferIndex:Int;
		////var imageIndex:Int;
		////
		////for (x in 0...buffer.width)
		////{
			////for (y in 0...buffer.height)
			////{
				////bufferIndex = (y * buffer.width + x);
				////imageIndex = (y * image.width + x) * 4;
				////
				////image.data[imageIndex] = 255;
				////image.data[imageIndex + 1] =255;
				////image.data[imageIndex + 2] = 255;
				////image.data[imageIndex + 3] = buffer.data[bufferIndex];
				////
			////}
			////
		////}
		//
		//var previousGlyphPosition:SubTextureData = null;
		//var imageArea:Rectangle = new Rectangle(0,10,0,0);
		//var fontData:AtlasFontData = {name:fontName, size:size, firstGlyph:"", firstGlyphPosition:null, lastGlyph:"", lastGlyphPosition:null};
		//var currentGlyph:String = "";
		////for (glyph in glyphs.keys() )
		//for (char in glyphs.keys() )
		//{
			//
			////trace(glyph + " " + String.fromCharCode(cast glyph));
			////trace(char);
			////currentGlyph = String.fromCharCode(glyph);
							//
			//if (previousGlyphPosition == null)
			//{
				//if (fonts.length > 0){
					//imageArea = fonts[fonts.length - 1].lastGlyphPosition.imageArea;
					//imageArea.x += imageArea.width;
				//}
			//}
			//else
			//{
				//imageArea.x = previousGlyphPosition.imageArea.x + previousGlyphPosition.imageArea.width+100;
				//imageArea.y = previousGlyphPosition.imageArea.y;				
			//}
			//
			////imageArea.width = glyphs[glyph].width;
			//imageArea.width = glyphs[char].width;
			////imageArea.height = glyphs[glyph].height;
			//imageArea.height = glyphs[char].height;
			//
			//if (imageArea.x > MAXSIZE || imageArea.x + imageArea.width > MAXSIZE)
			//{
				//imageArea.x = 0;
				//imageArea.y += currentLineHeight;										
			//}
			//
			//if (imageArea.height > currentLineHeight) currentLineHeight = imageArea.height;
			//
			//var bufferIndex:Int;
			//var imageIndex:Int;
			//
			//for (x in 0...cast(imageArea.width,Int))
			//{
				//for (y in 0...cast(imageArea.height,Int))
				//{
					//bufferIndex = (y * glyphs[char].width + x);
					//imageIndex = cast( ((y+imageArea.y) * image.width + x + imageArea.x) * 4,Int);
				//
					//image.data[imageIndex] = 255;
					//image.data[imageIndex + 1] =255;
					//image.data[imageIndex + 2] = 255;
					//image.data[imageIndex + 3] = glyphs[char].data[bufferIndex];
					//
				//}
				//
			//}
			//
			////previousGlyphPosition = subAreas[fontName + currentGlyph] = {
			//previousGlyphPosition = subAreas[fontName + char] = {
				//imageArea:	imageArea.clone(),
				//frame:		null,
				//rotated : 	false,
				//uvX: 		imageArea.x/MAXSIZE,
				//uvY: 		imageArea.y/MAXSIZE,
				//uvW:		imageArea.width/MAXSIZE,
				//uvH:		imageArea.height/MAXSIZE,
				//atlasIndex: this.index
			//}
			////trace(glyphs[glyph].buffer.width);
			////trace(currentGlyph + " "+ glyphs[glyph].offsetX + " " + previousGlyphPosition);
			//
			//
			//if (fontData.firstGlyphPosition == null)
			//{
				////fontData.firstGlyph = currentGlyph;
				//fontData.firstGlyph = char;
				//fontData.firstGlyphPosition = previousGlyphPosition;
			//}
			//if (previousGlyphPosition != null)
			//{
				////fontData.lastGlyph = currentGlyph;
				//fontData.lastGlyph = char;
				//fontData.lastGlyphPosition = previousGlyphPosition;
			//}
			//
			////glyphs[glyph] = null;
			//glyphs[char] = null;
				//
		//}
		//
				//
		//fonts.push(fontData);
				//
		//GL.activeTexture(GL.TEXTURE0 + FontRenderer.Get().GetFreeTextureIndex());
		//texture = GetTexture(image);
		//GL.bindTexture(GL.TEXTURE_2D, texture);
		//FontRenderer.Get().ActivateTexture(FontRenderer.Get().GetFreeTextureIndex());
		//
	//}