package beardFramework.graphics.text;
import beardFramework.graphics.cameras.Camera;
import beardFramework.graphics.core.BeardLayer;
import beardFramework.graphics.core.RenderedObject;
import beardFramework.graphics.rendering.Renderer;
import beardFramework.graphics.rendering.TextRenderer;
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
	
	
	public var alignment:Alignment;
	@:isVar public var atlas(get, set):String;
	public var autoAdjust:AutoAdjust;
	@:isVar public var font(get, set):String;
	public var glyphsData:Array<RenderedGlyphData>;
	public var needLayoutUpdate(default, null):Bool = false;
	public var spacingV(default, set):Float = 0;
	public var spacingH(default, set):Float = 0;
	public var text(default, null):String;
	public var textSize:Int;
	
	private var linesHeight:Float;


	
	
	
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
		
		this.atlas = AssetManager.Get().FONT_ATLAS_NAME;
		
		renderer = Renderer.Get();
		
		spacingH = 4; //to adjust with format
		spacingV = textSize / 3;
		
		needLayoutUpdate = true;
	}
	
	public function RemoveText(index:Int, count:Int = 1):String
	{
		
		isDirty  = true;
		
		if (text.length > 0 && index < text.length)
		{
			text = text.substr(0, (index - count + 1 >= 0 ? index - count +1 : 0)) +text.substr((index + 1 < text.length? index + 1: text.length - 1), text.length - 1 - index);
			
			for (i in 0...count)
			{
				if (glyphsData.length-1 >= i && glyphsData[glyphsData.length-i-1] != null)
				glyphsData[glyphsData.length-1-i].bufferIndex = renderer.FreeBufferIndex(glyphsData[glyphsData.length-1-i].bufferIndex);
			}
			
		}
		
		UpdateLayout();
		
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
	
	}
	
	public function AppendText( addedText:String, index:Int = -1):String
	{
		
		isDirty = true;
		if (index == -1 || index > text.length)
			this.text += addedText;
		else{
						
			text = text.substr(0, index) +addedText + text.substr(index, text.length - index);
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
		if (font != value) isDirty = needLayoutUpdate = true;
		return font = value;
	}
	
	inline function get_atlas():String 
	{
		return atlas;
	}
	
	function set_atlas(value:String):String 
	{
		if (atlas != value) isDirty = needLayoutUpdate = true;
		return atlas = value;
	}
	
	public function UpdateLayout():Void
	{
		trace("extfield layout update");
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
		var carriageReturn:Bool = false;
		var space:Bool = false;
		var hTab:Bool = false;
		
		for (i in 0...chars.length)
		{
			char = chars[i];
				
			trace(char);
			
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
					glyphData.y =currentLine * (linesHeight + spacingV);
				}
				else {
						glyphData = {
						x:0,
						y: currentLine * (linesHeight + spacingV),
						width:glyphHeight / glyphScale,
						height:glyphHeight,
						color: (currentAttribute != null ? currentAttribute.color : this.color),
						line:currentLine,
						textureData: textureData,
						bufferIndex: -1
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
			else if (char.charCodeAt(0) < 33)
			{

				trace("entering escape sequence");
				switch(char)
				{
					
					case "\t" : hTab = true;
					case "\n" : carriageReturn = true;
					case " " : space = true;
					
				}
				
				
				trace(hTab);
				trace(carriageReturn);
				trace(space);
				continue;
				
			}
			else
			{
				if (currentAttribute != null)
				{
					var usedFont:String = ((currentAttribute.font != null && currentAttribute.font != "") ? currentAttribute.font : font);
					var usedAtlas : String;
					
					if (currentAttribute.atlas != "") usedAtlas = currentAttribute.atlas;
					else usedAtlas = atlas;
					
					textureData = AssetManager.Get().GetFontGlyphTextureData(usedFont, char, textSize, usedAtlas);
					
					if (currentAttribute.size > 0)
						glyphHeight = currentAttribute.size;
					
					currentFont = AssetManager.Get().GetFont(usedFont);
	
				}
				else
				{
					
					textureData = AssetManager.Get().GetFontGlyphTextureData(font, char, textSize, atlas);
					glyphHeight = cast(textSize, Float);
				
				}
				
				glyphScale = textureData.uvH / textureData.uvW;
				
				glyphMetrics = currentFont.getGlyphMetrics(currentFont.getGlyph(char));				
				
				
				if (glyphsData.length > glyphDataIndex){
					glyphData = glyphsData[glyphDataIndex];
					glyphData.y = (currentLine * (linesHeight + spacingV) ) ;
					//glyphData.y = (currentLine * linesHeight) + glyphHeight - glyphMetrics.verticalBearing.y;
				}
				else{
					glyphData = {
						x:0,
						y: (currentLine * (linesHeight + spacingV))  ,
						//y: (currentLine * linesHeight) + glyphHeight - glyphMetrics.verticalBearing.y ,
						width:glyphHeight / glyphScale,
						height:glyphHeight,
						color: (currentAttribute != null ? currentAttribute.color : this.color),
						line: currentLine,
						textureData: textureData,
						bufferIndex:-1
					};
					
					glyphsData.push(glyphData);
				}
				
				
				
			}
			
		
			glyphData.width = glyphHeight / glyphScale;
			glyphData.height = glyphHeight;
			glyphData.color = (currentAttribute != null ? currentAttribute.color : this.color);
			glyphData.line = currentLine;
			glyphData.textureData = textureData;
			
			if (glyphData.bufferIndex < 0 && bufferIndex >= 0){
				
				glyphData.bufferIndex = (i == 0 ? this.bufferIndex : renderer.AllocateBufferIndex());
			}
				
			if (previousglyphData != null)
			{
				
				glyphData.x = previousglyphData.x + previousglyphData.width + spacingH + (space ? spacingH*2 : 0) +(hTab ? spacingH*4 : 0) ;
				
				
				if (carriageReturn){
					trace("carriagereturn");
					glyphData.y += linesHeight + spacingV;
					glyphData.x = 0;
					glyphData.line = ++currentLine;
				}
				
				if (this.width > 0 && (glyphData.x > this.width || glyphData.x + glyphData.width > this.width))
				{
					if (autoAdjust == AutoAdjust.ADJUST_FIELD)
					{
						this.width = glyphData.x + glyphData.width ;
					}
					else if (autoAdjust == AutoAdjust.ADJUST_TEXT)
					{
						
						glyphData.y += linesHeight + spacingV;
						glyphData.x = 0;
						glyphData.line = ++currentLine;
					}
					
				}
					
			}
			
		
			
			
			previousglyphData = glyphData;
			
			glyphDataIndex++;
			
			carriageReturn = space = hTab = false;
			
		}
		
		needLayoutUpdate = false;
		//for (data in glyphsData)
			//trace(data);
			
		
	}
	
	function set_spacingV(value:Float):Float 
	{
		isDirty = needLayoutUpdate = true;
		linesHeight = textSize + spacingV;
		return spacingV = value;
	}
	
	function set_spacingH(value:Float):Float 
	{
		isDirty = needLayoutUpdate = true;
		return spacingH = value;
	}
	
	override function set_bufferIndex(value:Int):Int 
	{
		trace("set buiffer " + value); 
		if (glyphsData != null)
		{
			trace("no bulll "); 
			if (value < 0)
			{
				for (data in glyphsData)
				{
					if (data.bufferIndex > 0) renderer.FreeBufferIndex(data.bufferIndex);
				}
			}
			else
			{
				for (i in 0...glyphsData.length)
				{
					trace(glyphsData[i].bufferIndex );
					if (glyphsData[i].bufferIndex < 0)
					{
						if (i == 0) glyphsData[i].bufferIndex = value;
						else glyphsData[i].bufferIndex = renderer.AllocateBufferIndex();
						
					}
				}
				
			}
			
			for (data in glyphsData)
			trace(data);
		}
		
		return super.set_bufferIndex(value);
	}
	
	override function set_scaleX(value:Float):Float 
	{
		needLayoutUpdate = true;
		return super.set_scaleX(value);
	}
	
	override function set_scaleY(value:Float):Float 
	{
		needLayoutUpdate = true;
		return super.set_scaleY(value);
	}
	
	override function set_rotation(value:Float):Float 
	{
		needLayoutUpdate = true;
		return super.set_rotation(value);
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