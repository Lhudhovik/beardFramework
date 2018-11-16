package beardFramework.resources.assets;
import beardFramework.utils.GeomUtils.SimpleRect;
import lime.graphics.Image;
import lime.text.Font;
import lime.text.Glyph;

/**
 * ...
 * @author 
 */
class FontAtlas extends Atlas 
{

	private var fonts:Map<String, SimpleRect>;
	public function new(name:String) 
	{
		super(name, null, null);
		
		fonts = new Map<String, SimpleRect>();
		
		
	}
	
	public function AddFont(font:Font, fontName:String, size:Int = 72):Void
	{
		trace("add Font to atlas");
		var glyphs:Map<Glyph, Image> = font.renderGlyphs(font.getGlyphs(), 32);
		var image:Image = font.renderGlyph(font.getGlyph("a"), 32);
	trace(font.getGlyphs());
		trace(image);
		for (glyph in glyphs.keys())
		{
			
			trace(font.getGlyphMetrics(glyph));
			
			
		}
		
		
		
		
		
		
	}
	
	public inline function ContainsFont(fontName:String):Bool
	{
		var containsFont:Bool = false;
		for (name in fonts.keys())
		{
			if (containsFont = (name == fontName)) break;
		}
		
		return containsFont;
	}
	
}

