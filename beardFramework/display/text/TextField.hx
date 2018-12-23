package beardFramework.display.text;
import beardFramework.display.cameras.Camera;
import beardFramework.display.core.BeardLayer;
import beardFramework.display.core.RenderedObject;
import beardFramework.display.rendering.TextRenderer;
import beardFramework.interfaces.ICameraDependent;
import beardFramework.resources.assets.AssetManager;
import beardFramework.resources.assets.Atlas.SubTextureData;
import haxe.Json;
import lime.math.Vector2;
import lime.text.Font;
import lime.text.GlyphMetrics;
import openfl.geom.Matrix;

/**
 * ...
 * @author Ludo
 */
class TextField extends RenderedObject {
	
	private static var instanceCount:Int = 0;
	public static var defaultFont:String="";
	
	public var autoAdjust:AutoAdjust;
	public var alignment:Alignment;
	public var spacingV(default, set):Float = 0;
	public var spacingH(default, set):Float = 0;
	
	public var text(default, null):String;
	public var fontAtlas:String;
	@:isVar public var font(get, set):String;
	@:isVar public var atlas(get, set):String;
	public var textSize:Int;
	
	
	//private var linesHeight:Array<Float>;
	private var linesHeight:Float;
	private var textChangesStart:Int=-1;
	public var glyphsData:Array<RenderedGlyphData>;
	
	
	public function new(text:String="", font:String="", size:Int = 32 ) 
	{
		super();
		
		if (name == "") name = "TextField_" + instanceCount;
		instanceCount++;
		
		this.text = "";
	
		glyphsData = new Array<RenderedGlyphData>();
		autoAdjust = AutoAdjust.NONE;
		alignment = Alignment.LEFT;
		
		linesHeight = textSize = size;
		
		if (font != "") this.font = font;
		else this.font = defaultFont;
	
		if(text != "") AppendText(text);
		//linesHeight = Array<Float>();
		fontAtlas = AssetManager.Get().FONT_ATLAS_NAME;
		
		renderer = TextRenderer.Get();
		
		
	}
	
	public function RemoveText(index:Int, count:Int = 1):String{
		
		isDirty = true;
		if (text.length > 0 && index < text.length)
		{
			var before:String = text.substr(0, (index - count + 1 >= 0 ? index - count +1 : 0));
			var after:String = text.substr((index + 1 < text.length? index + 1: text.length - 1), text.length-1 - index);
			
			text = before+after;
			
			
			for (i in 0...count)
			{
				if (glyphsData.length-1 >= i && glyphsData[glyphsData.length-i-1] != null)
				glyphsData[glyphsData.length-1-i].bufferIndex = renderer.FreeBufferIndex(glyphsData[glyphsData.length-1-i].bufferIndex);
			}
			
		}
		
 		return this.text;
		
	}
	
	public function ClearGlyphData(full:Bool = false):Void
	{
		var j:Int = 0;
		for (i in 0...glyphsData.length)
		{
			if (glyphsData[j] != null)
			{
				if (full || glyphsData[j].bufferIndex < 0){
					glyphsData[j] = null;
					glyphsData.splice(j, 1);
				}
				else j++;
			}
		}	
		
		trace(glyphsData);
	}
	
	public function AppendText( addedText:String, index:Int = -1):String{
		
		isDirty = true;
		if (index == -1 || index > text.length)
			this.text += addedText;
		else{
			
			var before:String = text.substr(0, index);
			var after:String = text.substr(index, text.length - index);
			
			text = before+addedText + after;
		}
		
		UpdateLayout();
 		return this.text;
		
	}
	
	inline function get_font():String 
	{
		return font;
	}
	
	function set_font(value:String):String 
	{
		if (font != value) isDirty = true;
		return font = value;
	}
	
	inline function get_atlas():String 
	{
		return atlas;
	}
	
	function set_atlas(value:String):String 
	{
		if (atlas != value) isDirty = true;
		return atlas = value;
	}
	
	/*private function UpdateLayoutFromAddedText():Void
	{
		
		var glyphMetrics:GlyphMetrics=null;
		var glyphData:RenderedGlyphData=null;
		var previousglyphData:RenderedGlyphData =  (textChangesStart > 0 ? glyphsData[textChangesStart - 1] : null);
		var glyphDataIndex:Int = textChangesStart;
		
		var isEmbedded:Bool = false;
		var isAttribute:Bool = false;
		var currentEmbedded : EmbeddedVisual = null;
		var currentAttribute : GlyphAttribute = null;
		var tag:String="";	
		
		var char:String="";
		var currentLine:Int = (previousglyphData != null? previousglyphData.line : 0);
		var addedChars:Array<String> = text.substr(textChangesStart,addedCharCount).split("");
		
		var textureData:SubTextureData = null;
		var glyphScale:Float=0;
		var glyphHeight:Float=0;
		var currentFont:Font=null;
		
	
		for (i in 0...addedChars.length)
		{
			char = addedChars[i];
					
			if (isEmbedded)
			{
				isEmbedded = !(char == "}");
				continue;
			}	
			else if (isAttribute)
			{
				isAttribute = !(char == ">");
				continue;
			}
			else if (isEmbedded = (char == "{" && addedChars[i + 1] == "\""))
			{
							
				tag = char;
				
				for (j in (i+1)...(addedChars.indexOf("}", i) + 1)){
					trace(tag);
					tag += addedChars[j];
				}
				
				currentEmbedded = haxe.Json.parse(tag);
				
				if (currentEmbedded == null || currentEmbedded.visual == null || currentEmbedded.visual == "" || currentEmbedded.atlas == null || currentEmbedded.atlas == "") continue;
				
				textureData = AssetManager.Get().GetSubTextureData(currentEmbedded.visual,currentEmbedded.atlas);
				glyphScale = textureData.uvH * textureData.uvW;
				glyphHeight = (currentEmbedded.height > 0 ? currentEmbedded.height : this.textSize);
				
				
				glyphData = {
					x:0,
					y: currentLine * linesHeight,
					width:glyphHeight / glyphScale,
					height:glyphHeight,
					color: (currentAttribute != null ? currentAttribute.color : this.color),
					line:currentLine,
					textureData: textureData,
					bufferIndex:TextRenderer.Get().AllocateBufferIndex()
				};
				
			}
			else if (isAttribute = (char == "<" && addedChars[i + 1] == "{"))
			{
				
				tag =  addedChars[i + 1];
				
				for (j in (i+1)...(addedChars.indexOf("}", i) + 1)){
					trace(tag);
					tag += addedChars[j];
				}
				
				currentAttribute = haxe.Json.parse(tag);
				continue;				
			}
			else if (isAttribute = (char == "<" && addedChars[i + 1] == "/"))
			{
				currentAttribute = null;	
				currentFont = AssetManager.Get().GetFont(font);
				continue;
			}
			else
			{
				if (currentAttribute != null)
				{
					var usedFont:String = ((currentAttribute.font != null && currentAttribute.font != "") ? currentAttribute.font : font);
					var usedAtlas : String;
					
					if (currentAttribute.atlas != "") usedAtlas = currentAttribute.atlas;
					else if( currentAttribute.size > 0 ) usedAtlas = usedFont + currentAttribute.size;
					else usedAtlas = usedFont + textSize;
					
					textureData = AssetManager.Get().GetSubTextureData(usedFont+char, usedAtlas);
					
					if (currentAttribute.size > 0)
						glyphHeight = currentAttribute.size;
					
					currentFont = AssetManager.Get().GetFont(usedFont);
	
				}
				else
				{
					textureData = AssetManager.Get().GetSubTextureData(font + char, this.atlas);
					glyphHeight = cast(textSize, Float);
				}
				
				glyphScale = textureData.uvH * textureData.uvW;
				
				glyphMetrics = currentFont.getGlyphMetrics(currentFont.getGlyph(char));				
				
				glyphData = {
					x:0,
					y: (currentLine * linesHeight) + glyphHeight - glyphMetrics.verticalBearing.y ,
					width:glyphHeight / glyphScale,
					height:glyphHeight,
					color: (currentAttribute != null ? currentAttribute.color : this.color),
					line: currentLine,
					textureData: textureData,
					bufferIndex:TextRenderer.Get().AllocateBufferIndex()
				};
				
				
				
			}
				
			if (previousglyphData != null)
			{
				glyphData.x = previousglyphData.x + previousglyphData.width + spacingH;
				
				if (glyphData.x > this.width || glyphData.x + glyphData.width > this.width)
				{
					
					if (autoAdjust == AutoAdjust.ADJUST_FIELD)
					{
						
					}
					else if (autoAdjust == AutoAdjust.ADJUST_TEXT)
					{
						
						glyphData.y += linesHeight;
						glyphData.x = 0;
						glyphData.line = ++currentLine;
					}
					
				}
				
			}
			
			previousglyphData = glyphData;
			
			
			
			glyphsData.insert(glyphDataIndex, glyphData);
			glyphDataIndex++;
			
			
		}
		
		if (glyphDataIndex < text.length -1 && addedCharCount > 0)
		{
			for (i in glyphDataIndex...text.length-1)
			{
				
				glyphData = glyphsData[i];
				if (previousglyphData != null)
				{
					
					
					glyphData.x = previousglyphData.x + previousglyphData.width + spacingH;
					
					if (glyphData.x > this.width || glyphData.x + glyphData.width > this.width)
					{
						
						if (autoAdjust == AutoAdjust.ADJUST_FIELD)
						{
							
						}
						else if (autoAdjust == AutoAdjust.ADJUST_TEXT)
						{
							
							glyphData.y += linesHeight;
							glyphData.x = 0;
							glyphData.line = ++currentLine;
						}
						
					}
					
				}
				
			}
			
			
			
		}
		
		
	}
	
	
	*/
	private function UpdateLayout():Void
	{
		
		var glyphMetrics:GlyphMetrics=null;
		var glyphData:RenderedGlyphData = null;
		var previousglyphData:RenderedGlyphData =  null;
		var glyphDataIndex:Int = 0;
		
		var isEmbedded:Bool = false;
		var isAttribute:Bool = false;
		var currentEmbedded : EmbeddedVisual = null;
		var currentAttribute : GlyphAttribute = null;
		var tag:String="";	
		
		var char:String="";
		var currentLine:Int = (previousglyphData != null? previousglyphData.line : 0);
		var chars:Array<String> = text.split("");
		
		var textureData:SubTextureData = null;
		var glyphScale:Float=0;
		var glyphHeight:Float=0;
		var currentFont:Font= AssetManager.Get().GetFont(font);
		
		
		
	
		for (i in 0...chars.length)
		{
			char = chars[i];
							
			
			if (isEmbedded)
			{
				isEmbedded = !(char == "}");
				continue;
			}	
			else if (isAttribute)
			{
				isAttribute = !(char == ">");
				continue;
			}
			else if (isEmbedded = (char == "{" && chars[i + 1] == "\""))
			{
							
				tag = char;
				
				for (j in (i+1)...(chars.indexOf("}", i) + 1)){
					trace(tag);
					tag += chars[j];
				}
				
				currentEmbedded = haxe.Json.parse(tag);
				
				if (currentEmbedded == null || currentEmbedded.visual == null || currentEmbedded.visual == "" || currentEmbedded.atlas == null || currentEmbedded.atlas == "") continue;
				
				textureData = AssetManager.Get().GetSubTextureData(currentEmbedded.visual,currentEmbedded.atlas);
				glyphScale = textureData.uvH * textureData.uvW;
				glyphHeight = (currentEmbedded.height > 0 ? currentEmbedded.height : this.textSize);
			
				if (glyphsData.length > glyphDataIndex){
					glyphData = glyphsData[glyphDataIndex];
					glyphData.y = currentLine * linesHeight;
				}
				else {
						glyphData = {
						x:0,
						y: currentLine * linesHeight,
						width:glyphHeight / glyphScale,
						height:glyphHeight,
						color: (currentAttribute != null ? currentAttribute.color : this.color),
						line:currentLine,
						textureData: textureData,
						bufferIndex: (i == 0 ? this.bufferIndex : TextRenderer.Get().AllocateBufferIndex())
					};
					
					glyphsData.push(glyphData);
				}

				
				
			}
			else if (isAttribute = (char == "<" && chars[i + 1] == "{"))
			{
				
				tag =  chars[i + 1];
				
				for (j in (i+1)...(chars.indexOf("}", i) + 1)){
					trace(tag);
					tag += chars[j];
				}
				
				currentAttribute = haxe.Json.parse(tag);
				continue;				
			}
			else if (isAttribute = (char == "<" && chars[i + 1] == "/"))
			{
				currentAttribute = null;	
				currentFont = AssetManager.Get().GetFont(font);
				continue;
			}
			else
			{
				if (currentAttribute != null)
				{
					var usedFont:String = ((currentAttribute.font != null && currentAttribute.font != "") ? currentAttribute.font : font);
					var usedAtlas : String;
					
					if (currentAttribute.atlas != "") usedAtlas = currentAttribute.atlas;
					else usedAtlas = fontAtlas;
					
					textureData = AssetManager.Get().GetFontGlyphTextureData(usedFont, char, textSize, usedAtlas);
					
					if (currentAttribute.size > 0)
						glyphHeight = currentAttribute.size;
					
					currentFont = AssetManager.Get().GetFont(usedFont);
	
				}
				else
				{
					
					textureData = AssetManager.Get().GetFontGlyphTextureData(font, char, textSize, fontAtlas);
					glyphHeight = cast(textSize, Float);
				
				}
				
				glyphScale = textureData.uvH / textureData.uvW;
				
				glyphMetrics = currentFont.getGlyphMetrics(currentFont.getGlyph(char));				
				
				
				if (glyphsData.length > glyphDataIndex){
					glyphData = glyphsData[glyphDataIndex];
					glyphData.y = (currentLine * linesHeight) ;
					//glyphData.y = (currentLine * linesHeight) + glyphHeight - glyphMetrics.verticalBearing.y;
				}
				else{
					glyphData = {
						x:0,
						y: (currentLine * linesHeight)  ,
						//y: (currentLine * linesHeight) + glyphHeight - glyphMetrics.verticalBearing.y ,
						width:glyphHeight / glyphScale,
						height:glyphHeight,
						color: (currentAttribute != null ? currentAttribute.color : this.color),
						line: currentLine,
						textureData: textureData,
						bufferIndex:(i == 0 ? this.bufferIndex : TextRenderer.Get().AllocateBufferIndex())
					};
					
					glyphsData.push(glyphData);
				}
				
				
				
			}
		
			glyphData.width = glyphHeight / glyphScale;
			glyphData.height = glyphHeight;
			glyphData.color = (currentAttribute != null ? currentAttribute.color : this.color);
			glyphData.line = currentLine;
			glyphData.textureData = textureData;
			if (glyphData.bufferIndex < 0) glyphData.bufferIndex = (i == 0 ? this.bufferIndex : TextRenderer.Get().AllocateBufferIndex());
				
			if (previousglyphData != null)
			{
				glyphData.x = previousglyphData.x + previousglyphData.width + spacingH;
				
				if (glyphData.x > this.width || glyphData.x + glyphData.width > this.width)
				{
					
					if (autoAdjust == AutoAdjust.ADJUST_FIELD)
					{
						this.width = glyphData.x + glyphData.width ;
					}
					else if (autoAdjust == AutoAdjust.ADJUST_TEXT)
					{
						
						glyphData.y += linesHeight;
						glyphData.x = 0;
						glyphData.line = ++currentLine;
					}
					
				}
				
			}
			
			previousglyphData = glyphData;
			
			glyphDataIndex++;
			
			
		}
		
		for (data in glyphsData)
			trace(data);
			
		
	}
	
	function set_spacingV(value:Float):Float 
	{
		
		linesHeight = textSize + spacingV;
		UpdateLayout();
		return spacingV = value;
	}
	
	function set_spacingH(value:Float):Float 
	{
		UpdateLayout();
		return spacingH = value;
	}
	
	
	
	
}

typedef RenderedGlyphData =
{
	public var x:Float;
	public var y:Float;
	public var width:Float;
	public var height:Float;
	public var color:Int;
	public var line:Int;
	public var textureData:SubTextureData;
	public var bufferIndex:Int;
}

typedef EmbeddedVisual =
{
	public var height:Float;
	public var visual:String;
	public var atlas:String;
}

typedef GlyphAttribute =
{
	public var color:UInt;
	public var bold:Bool;
	public var size:Int;
	public var font:String;
	public var atlas:String;
}
enum AutoAdjust 
{
	ADJUST_TEXT;
	ADJUST_FIELD;
	NONE;

}

enum Alignment 
{
	LEFT;
	CENTER;
	RIGHT;

}