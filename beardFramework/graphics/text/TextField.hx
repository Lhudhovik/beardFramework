package beardFramework.graphics.text;
import beardFramework.graphics.cameras.Camera;
import beardFramework.graphics.core.BeardLayer;
import beardFramework.graphics.core.RenderedObject;
import beardFramework.graphics.core.Visual;
import beardFramework.graphics.rendering.Renderer;
import beardFramework.interfaces.ICameraDependent;
import beardFramework.resources.assets.AssetManager;
import beardFramework.resources.assets.Atlas.SubTextureData;
import beardFramework.utils.ColorUtils;
import beardFramework.utils.MinAllocArray;
import haxe.Json;
import haxe.Utf8;
import lime.text.Font;
import lime.text.GlyphMetrics;


/**
 * ...
 * @author Ludo
 */
class TextField extends RenderedObject {
	
	private static var instanceCount:Int = 0;
	public static var defaultFont:String="";
	
	
	public var alignment(default, set):Alignment;
	@:isVar public var atlas(get, set):String;
	public var autoAdjust:AutoAdjust;
	@:isVar public var font(get, set):String;
	public var glyphsData:Array<RenderedGlyphData>;
	//public var lines:Array<Array<LineGlyphData>>;
	public var needLayoutUpdate(default, null):Bool = false;
	public var lineSpacing(default, set):Float = 0;
	public var letterSpacing(default, set):Float = 0;
	public var tabSpacing(default, set):Float = 0;
	public var spaceSpacing(default, set):Float = 0;
	public var text(default, null):String;
	public var textSize:Float;
	
	private var linesHeight:Float;
	private var cursor:Visual;
	private var cursorIndex:Int;
	
	
	
	public function new(text:String="", font:String="", size:Int = 32 ) 
	{
		super();
		
		if (name == "") name = "TextField_" + instanceCount;
		instanceCount++;
		
		this.text = "";
	
		glyphsData = new Array<RenderedGlyphData>();
		
		alignment = Alignment.LEFT;
		autoAdjust = AutoAdjust.ADJUST_FIELD;
		
		
		linesHeight = textSize = size;
		
		if (font != "") this.font = font;
		else this.font = defaultFont;
	
		if(text != "") AppendText(text);
		
		this.atlas = AssetManager.Get().FONT_ATLAS_NAME;
		cursor = new Visual("facebook_button_normal_fr_hd", "menuHD", "cursor" + instanceCount);
		cursor.visible = false;
		cursor.width = 5;
		cursor.height = linesHeight;
		renderer = Renderer.Get();
		
		letterSpacing = textSize/50; //to adjust with format
		lineSpacing = textSize / 10;
		tabSpacing = textSize;
		spaceSpacing = textSize;
		needLayoutUpdate = true;
	}
	
	public function ShowCursor():Void
	{
		if (layer != null)
		layer.Add(cursor);
		cursorIndex = 5;
		cursor.x = this.x + glyphsData[cursorIndex].x + glyphsData[cursorIndex].width;
		cursor.y = this.y + glyphsData[cursorIndex].line * linesHeight;
			
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
				glyphsData[glyphsData.length-1-i].bufferIndex = renderer.FreeBufferIndex(glyphsData[glyphsData.length-1-i].bufferIndex,renderingBatch);
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
		
		var glyphMetrics:GlyphMetrics=null;
		var metrics:Metrics=null;
		var prevMetrics:Metrics=null;
		var glyphData:RenderedGlyphData = null;
		var prevglyphData:RenderedGlyphData =  null;
		var glyphDataIndex:Int = 0;
		var currWord:MinAllocArray<Int> = new MinAllocArray();
		
		var isEmbedded:Bool = false;
		var isAttribute:Bool = false;
		var embedded : EmbeddedVisual = null;
		var attribute : GlyphAttribute = null;
		var tag:String="";	
		
		var char:String="";
		var line:Int = 0;
		var chars:Array<String> = text.split("");
		//for (i in 0...chars.length)
		//{
			//chars[i] = Utf8.encode(chars[i]);
			////chars.push(String.fromCharCode(Utf8.charCodeAt(text,i)));
			//
		//}
		trace(chars);
		var textureData:SubTextureData = null;
		var glyphScale:Float=0;
		var glyphHeight:Float=0;
		var currFont:Font = AssetManager.Get().GetFont(font);
		var sizeRatio:Float = this.textSize / currFont.height;
		var carriageReturn:Bool = false;
		var endOfLineReached:Bool = false;
		var space:Bool = false;
		var hTab:Bool = false;
		
		metrics =  {gAdvX:0, fAsc:currFont.ascender * sizeRatio, gHbX:0, gHbY:0}
		prevMetrics =  {gAdvX:0, fAsc:currFont.ascender * sizeRatio, gHbX:0, gHbY:0}
	
		var lines = new Array<Array<LineGlyphData>>();
		lines.push(new Array<LineGlyphData>());
		
		//First, add characters to lines
		for (i in 0...chars.length)
		{
			char = chars[i];
			//trace(char);
			if (isEmbedded)
			{
				isEmbedded = !(char == "}");
				continue;
			}	
			else if (isAttribute)
			{
				isAttribute = !(char == ">");
				if (isAttribute == false)
				{
					attribute = null;
					currFont =  AssetManager.Get().GetFont(font);
					sizeRatio = this.textSize / currFont.height;
					metrics.fAsc = currFont.ascender * sizeRatio;
				}
				continue;
			}
			else if (isAttribute = (char == "<" && chars[i + 1] == "{"))
			{
				
				tag =  chars[i + 1];
				
				for (j in (i+1)...(chars.indexOf("}", i) + 1)){
					trace(tag);
					tag += chars[j];
				}
				
				attribute = haxe.Json.parse(tag);
				continue;				
			}
			else if (char.charCodeAt(0) < 33 && char.charCodeAt(0) > 0)
			{
				switch(char)
				{
					
					case "\t" : hTab = true;
					case "\n" : carriageReturn = true;
					line++;
					lines.push(new Array<LineGlyphData>());
					case " " : space = true;
					
				}
				currWord.Clean();
				continue;
			}
			
			if (isEmbedded = (char == "{" && chars[i + 1] == "\""))
			{
							
				tag = char;
				
				for (j in (i+1)...(chars.indexOf("}", i) + 1)){
					trace(tag);
					tag += chars[j];
				}
				
				embedded = haxe.Json.parse(tag);
				
				if (embedded == null || embedded.visual == null || embedded.visual == "" || embedded.atlas == null || embedded.atlas == "") continue;
				
				textureData = AssetManager.Get().GetSubTextureData(embedded.visual,embedded.atlas);
				currWord.Clean();
			}
			else
			{
				if (attribute != null)
				{
					var usedFont:String = ((attribute.font != null && attribute.font != "") ? attribute.font : font);
					var usedAtlas : String;
					
					if (attribute.atlas != "") usedAtlas = attribute.atlas;
					else usedAtlas = atlas;
					
					textureData = AssetManager.Get().GetFontGlyphTextureData(usedFont, char, Math.round(textSize), usedAtlas);
					currFont = AssetManager.Get().GetFont(usedFont);
									
					if (attribute.size > 0) sizeRatio = attribute.size / currFont.height;
					else sizeRatio = this.textSize / currFont.height;
					
					metrics.fAsc = currFont.ascender * sizeRatio;
				
				}
				else
					textureData = AssetManager.Get().GetFontGlyphTextureData(font, char, Math.round(textSize), atlas);
				
			}
			
			
	
			if (textureData == null){
					
				trace("Embedded visual or glyph" + char+ " doesn't exist " );
					continue;
			}	
			
		
			if (glyphsData.length > glyphDataIndex)		glyphData = glyphsData[glyphDataIndex];
			else {
					glyphData = {
					x:0,
					y: 0,
					width:0,
					height:0,
					color:0,
					line:0,
					textureData: null,
					bufferIndex: -1,
					metrics:null
				}
				
				glyphsData.push(glyphData);
			}
			
			
			glyphMetrics = (!isEmbedded? currFont.getGlyphMetrics(currFont.getGlyph(char)):null);	
			
			if (glyphMetrics != null)
			{
				metrics.gHbX = glyphMetrics.horizontalBearing.x * sizeRatio;
				metrics.gHbY = glyphMetrics.horizontalBearing.y * sizeRatio;
				metrics.gAdvX = glyphMetrics.advance.x * sizeRatio;
			}
			else metrics.gHbX = metrics.gHbY = metrics.gAdvX = 0;
			
						
			glyphScale = textureData.uvH / textureData.uvW;
			glyphHeight = (!isEmbedded ? glyphMetrics.height * sizeRatio : (embedded.height > 0 ? embedded.height : this.textSize));
			glyphData.y = (!isEmbedded? line * linesHeight  + (line+1)* metrics.fAsc + ( metrics.fAsc - metrics.gHbY) : glyphHeight * line );
			glyphData.width = glyphHeight / glyphScale;
			glyphData.height = glyphHeight;
			glyphData.color = (isEmbedded ? (embedded.color >= 0 ? embedded.color : ColorUtils.WHITE) : ( attribute != null ? attribute.color : this.color));
			glyphData.line = line;
			glyphData.textureData = textureData;
			glyphData.metrics = glyphMetrics;
			
			if (glyphData.bufferIndex < 0 && bufferIndex >= 0) glyphData.bufferIndex = (i == 0 ? this.bufferIndex : renderer.AllocateBufferIndex(renderingBatch));
			//TO change
			if (this.width == 0) SetBaseWidth(glyphData.x + glyphData.width);
			if (this.height == 0)	SetBaseHeight(textSize);
			
			if (prevglyphData != null && carriageReturn == false)
			{
				if (prevglyphData.metrics != null)
				{
					prevMetrics.gHbX = prevglyphData.metrics.horizontalBearing.x * sizeRatio;
					prevMetrics.gHbY = prevglyphData.metrics.horizontalBearing.y * sizeRatio;
					prevMetrics.gAdvX = prevglyphData.metrics.advance.x * sizeRatio;
				}
				else prevMetrics.gHbX = prevMetrics.gHbY = prevMetrics.gAdvX = 0;
							
				glyphData.x = (glyphMetrics != null? metrics.gHbX : 0)  + prevglyphData.x + (prevglyphData.metrics != null? prevMetrics.gAdvX - prevMetrics.gHbX : prevglyphData.width + letterSpacing)  + (space ? spaceSpacing : 0) +(hTab ? tabSpacing : 0);
			}
			else	glyphData.x = (glyphMetrics != null? metrics.gHbX : 0);
			
					
			switch(autoAdjust)
			{
				case AutoAdjust.ADJUST_FIELD | AutoAdjust.NONE:
				
					if(glyphData.x + glyphData.width> width)
						SetBaseWidth(glyphData.x + glyphData.width);
					if(glyphData.y + glyphData.height > height)
						SetBaseHeight(glyphData.y + glyphData.height);
					
				case AutoAdjust.ADJUST_TEXT :
					if((glyphData.x > this.width || glyphData.x + glyphData.width > this.width))
					{
						//update word
						//trace("update word  " + char);
						glyphData.line = ++line;
						lines.push(new Array<LineGlyphData>());
						
						var data:RenderedGlyphData= null;
						var prevData:RenderedGlyphData = null;
						var lineData:LineGlyphData;
						for (i in 0...currWord.length){
							lineData = lines[glyphData.line-1].pop();	
							lineData.glyph = currWord.get(i);
							lineData.space = lineData.tab = false;
							lines[glyphData.line].push(lineData);
							
							data = glyphsData[currWord.get(i)];
							
							data.line = line;
							
							if (i == 0)
							data.x =  (data.metrics != null? data.metrics.horizontalBearing.x * sizeRatio : 0) ;
							else data.x = (data.metrics != null? data.metrics.horizontalBearing.x * sizeRatio : 0)  + prevData.x + (prevData.metrics != null? (prevData.metrics.advance.x - prevData.metrics.horizontalBearing.x) * sizeRatio : prevData.width + letterSpacing);					
							
							data.y = (data.metrics != null ? (line * linesHeight + (line+1) * metrics.fAsc + (metrics.fAsc - (data.metrics.horizontalBearing.y * sizeRatio))) :data.height * line) ;
							
							prevData = data;
							
						}
						
						
						
						glyphData.y = (glyphData.metrics != null ? line * linesHeight  + (line+1)* metrics.fAsc + ( metrics.fAsc - metrics.gHbY) : glyphHeight * line );
						glyphData.x = (glyphData.metrics != null? metrics.gHbX: 0);
						
						if (prevData != null)
						glyphData.x += prevData.x + (prevData.metrics != null? (prevData.metrics.advance.x - prevData.metrics.horizontalBearing.x) * sizeRatio : prevData.width + letterSpacing);
						
					}
				
					if (glyphData.y > this.height || glyphData.y+glyphData.height > this.height)
					{
						
						var gapFactor:Float =  this.height / (glyphData.y + glyphData.height);
					
						textSize *= gapFactor;
						lineSpacing *= gapFactor;
						letterSpacing *= gapFactor;
						tabSpacing *= gapFactor;
						spaceSpacing *= gapFactor;
						
						UpdateLayout();
						
						return;
						
					}
					
			}
			
			
			if (hTab == true || space == true) currWord.Clean();
			if(isEmbedded == false) currWord.Push(glyphDataIndex);	
			
			lines[glyphData.line].push({glyph:glyphDataIndex, tab:hTab, space:space});
			
			prevglyphData = glyphData;
			glyphDataIndex++;
			
			carriageReturn = space = hTab = endOfLineReached = false;	
		}
		
		
		if (lines.length > 0)
		{
			var data:RenderedGlyphData;
			var prevData:RenderedGlyphData;
			var gap:Float;
			switch(alignment)
			{
				case Alignment.LEFT: 
				case Alignment.RIGHT:
					for (lineData in lines){
						if (lineData.length == 0) continue;
						data = prevData = glyphsData[lineData[lineData.length - 1].glyph];
						
						if(data.metrics != null)
							data.x = this.width - (data.metrics.advance.x - data.metrics.horizontalBearing.x)*sizeRatio;
						else
							data.x = this.width - data.width;
									
						for (i in 1...lineData.length)
						{
							data = glyphsData[lineData[lineData.length - 1 - i].glyph];
							data.x = prevData.x - (prevData.metrics != null? (prevData.metrics.horizontalBearing.x) * sizeRatio : 0) -(data.metrics != null? (data.metrics.advance.x - data.metrics.horizontalBearing.x) * sizeRatio : data.width + letterSpacing) - ( lineData[lineData.length - i].space ? spaceSpacing : 0) - (lineData[lineData.length - i].tab ? tabSpacing : 0 );				
							prevData = data;
						}
							
						
							
					}
				
				case Alignment.CENTER:
					
					for (lineData in lines){
						
						if (lineData.length == 0) continue;
						
						data = prevData = glyphsData[lineData[lineData.length - 1].glyph];
						gap = this.width - data.x + (data.metrics != null? (data.metrics.advance.x - data.metrics.horizontalBearing.x) * sizeRatio : data.width);
						trace(gap);
						trace(this.width);
						trace(data.x);
						trace((data.metrics != null? (data.metrics.advance.x - data.metrics.horizontalBearing.x) * sizeRatio : 0));
						if(data.metrics != null)
							data.x = this.width - (gap*0.5) - (data.metrics.advance.x - data.metrics.horizontalBearing.x)*sizeRatio;
						else
							data.x = this.width - data.width - gap * 0.5;
							
						for (i in 1...lineData.length){
							data = glyphsData[lineData[lineData.length - 1 - i].glyph];
							data.x = prevData.x - (prevData.metrics != null? (prevData.metrics.horizontalBearing.x) * sizeRatio : 0) -(data.metrics != null? (data.metrics.advance.x - data.metrics.horizontalBearing.x) * sizeRatio : data.width + letterSpacing) - ( lineData[lineData.length -i].space ? spaceSpacing : 0) - (lineData[lineData.length -i].tab ? tabSpacing : 0 );				
							prevData = data;
						}
						
					}
					
				case Alignment.JUSTIFIED:
					for (lineData in lines){
						if (lineData.length == 0 || lineData == lines[lines.length -1]) continue;
						data = prevData = glyphsData[lineData[lineData.length - 1].glyph];
						gap = this.width - data.x + (data.metrics != null? (data.metrics.advance.x - data.metrics.horizontalBearing.x) * sizeRatio : data.width);
						gap /= lineData.length;
						for (i in 1...lineData.length)
						glyphsData[lineData[i].glyph].x += gap*i;
					}
				
			}
			
		}
	
		needLayoutUpdate = false;
		
		
	}
	
	function set_lineSpacing(value:Float):Float 
	{
		isDirty = needLayoutUpdate = true;
		linesHeight = cursor.height = (AssetManager.Get().GetFont(font).height) * (textSize / AssetManager.Get().GetFont(font).height) + value;
		cursor.height *= 1.5;
		return lineSpacing = value;
	}
	
	function set_letterSpacing(value:Float):Float 
	{
		isDirty = needLayoutUpdate = true;
		return letterSpacing = value;
	}
	
	override function set_bufferIndex(value:Int):Int 
	{
		
		if (glyphsData != null)
		{
			
			if (value < 0)
			{
				for (data in glyphsData)
				{
					if (data.bufferIndex > 0) renderer.FreeBufferIndex(data.bufferIndex,renderingBatch);
				}
			}
			else
			{
				for (i in 0...glyphsData.length)
				{
					
					if (glyphsData[i].bufferIndex < 0)
					{
						if (i == 0) glyphsData[i].bufferIndex = value;
						else glyphsData[i].bufferIndex = renderer.AllocateBufferIndex(renderingBatch);
						
					}
				}
				
			}
			
		
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
	
	override public function set_height(value:Float):Float 
	{
		needLayoutUpdate = true;
		return super.set_height(value);
	}
	override public function set_width(value:Float):Float 
	{
		trace("changed");
		needLayoutUpdate = isDirty = true;
		return super.set_width(value);
	}
	
	function set_tabSpacing(value:Float):Float 
	{
		needLayoutUpdate = isDirty = true;
		return tabSpacing = value;
	}

	function set_spaceSpacing(value:Float):Float 
	{
		needLayoutUpdate = isDirty = true;
		return spaceSpacing = value;
	}
	
	function set_alignment(value:Alignment):Alignment 
	{
		autoAdjust = AutoAdjust.ADJUST_TEXT;
		needLayoutUpdate = isDirty= true;
	
		return alignment = value;
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
	public var metrics:GlyphMetrics;
}

typedef EmbeddedVisual =
{
	public var height:Float;
	public var visual:String;
	public var atlas:String;
	public var color:UInt;
}

typedef GlyphAttribute =
{
	public var color:UInt;
	public var bold:Bool;
	public var size:Int;
	public var font:String;
	public var atlas:String;
}

typedef LineGlyphData =
{
	public var glyph:Int;
	public var tab:Bool;
	public var space:Bool;

}


typedef Metrics =
{
	/** glyph advance X */ public var gAdvX:Float;
	/** font ascender */public var fAsc:Float;
	/** Horizontal Bearing X */	public var gHbX:Float;
	/**	 * Horizontal Bearing X */public var gHbY:Float;
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
	JUSTIFIED;

}