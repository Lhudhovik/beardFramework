package beardFramework.graphics.text;
import beardFramework.core.BeardGame;
import beardFramework.graphics.cameras.Camera;
import beardFramework.graphics.core.BeardLayer;
import beardFramework.graphics.core.RenderedObject;
import beardFramework.graphics.core.Visual;
import beardFramework.graphics.rendering.Renderer;
import beardFramework.graphics.rendering.batches.RenderedObjectBatch;
import beardFramework.graphics.ui.FocusableList;
import beardFramework.input.InputManager;
import beardFramework.input.InputType;
import beardFramework.input.MousePos;
import beardFramework.input.data.InputData;
import beardFramework.input.data.KeyboardInputData;
import beardFramework.interfaces.ICameraDependent;
import beardFramework.interfaces.IFocusable;
import beardFramework.resources.assets.AssetManager;
import beardFramework.resources.assets.Atlas.SubTextureData;
import beardFramework.updateProcess.UpdateProcess;
import beardFramework.updateProcess.UpdateProcessesManager;
import beardFramework.updateProcess.Wait;
import beardFramework.utils.graphics.ColorU;
import beardFramework.resources.MinAllocArray;
import beardFramework.utils.libraries.StringLibrary;
import beardFramework.utils.math.MathU;
import haxe.Json;
import haxe.Utf8;
import lime.text.Font;
import lime.text.GlyphMetrics;
import lime.ui.KeyCode;


/**
 * ...
 * @author Ludo
 */
class TextField extends RenderedObject implements IFocusable {
	
	private static var instanceCount:Int = 0;
	public static var defaultFont:String="";
		
	public var list:FocusableList;
	@:isVar public var atlas(get, set):String;
	@:isVar public var font(get, set):String;
	@:isVar public var isInteractive(get, set):Bool = false;
	public var alignment(default, set):Alignment;
	public var autoAdjust:AutoAdjust;
	public var glyphsData:MinAllocArray<RenderedGlyphData>;
	//public var lines:Array<Array<LineGlyphData>>;
	public var needLayoutUpdate(default, null):Bool = false;

	public var lineSpacing(default, set):Float = 0;
	public var letterSpacing(default, set):Float = 0;
	public var tabSpacing(default, set):Float = 0;
	public var spaceSpacing(default, set):Float = 0;
	public var text(default, null):String;
	public var textSize:Float;
	public var isForm:Bool;
	
	private var linesHeight:Float;
	private var cursor:Visual;
	private var cursorIndex(default, set):Int;
	
	
	
	public function new(text:String="", font:String="", size:Int = 32,name:String = "" ) 
	{
		super();
		
		if (name == "") this.name = "TextField_" + instanceCount;
		else this.name = name;
		instanceCount++;
		
		this.text = "";
	
		glyphsData = new MinAllocArray<RenderedGlyphData>();
		
		alignment = Alignment.LEFT;
		autoAdjust = AutoAdjust.ADJUST_FIELD;
		
		isInteractive = false;
		linesHeight = textSize = size;
		
		if (font != "") this.font = font;
		else this.font = defaultFont;
	
		if(text != "") AppendText(text);
		
		this.atlas = AssetManager.Get().FONT_ATLAS_NAME;
		cursor = new Visual(AssetManager.Get().GetFontGlyphTextureName(this.font, "|",Std.int(this.textSize)), this.atlas, "cursor" + instanceCount);
	
		cursor.visible = false;
		cursor.width =  5;
		cursor.height = linesHeight ;
				
		letterSpacing = textSize/50; //to adjust with format
		lineSpacing = textSize / 10;
		tabSpacing = textSize;
		spaceSpacing = textSize;
		needLayoutUpdate = true;
		cursorIndex = 0;
		
		isForm = false;
	}
	
	public function ShowCursor():Void
	{
		if (layer != null){
			if(cursor.layer == null) layer.Add(cursor);
			cursor.visible = true;
			Wait.WaitFor(0.5, HideCursor,this.name );
		}
	
			
	}
	
	private function HideCursor():Void
	{
		cursor.visible = false;
		if (InputManager.Get().focusedObject == this) 
			Wait.WaitFor(0.5, ShowCursor, this.name);
		
	}
		
	public function RemoveText(index:Int, count:Int = 1):String
	{
		
		isDirty  = true;
		
		if (text.length > 0 && index < text.length)
		{
			text = text.substr(0, (index - count + 1 >= 0 ? index - count +1 : 0)) +text.substr((index + 1 < text.length? index + 1: text.length - 1), text.length - 1 - index);
			
			for (i in 0...count)
			{
				if (glyphsData.length-1 >= i && glyphsData.get(glyphsData.length-i-1) != null)
				glyphsData.get(glyphsData.length-1-i).bufferIndex = renderingBatch.FreeBufferIndex(glyphsData.get(glyphsData.length-1-i).bufferIndex);
			}
			
			if (bufferIndex >= 0 && renderingBatch != null) renderingBatch.AllocateBufferIndex(bufferIndex);
		}
		
		UpdateLayout();
		
 		return this.text;
		
	}
	
	public function ClearGlyphData(full:Bool = false):Void
	{
		var j:Int = 0;
		for (i in 0...glyphsData.length)
		{
			if (glyphsData.get(j) != null)
			{
				if (full || glyphsData.get(j).bufferIndex < 0){
					glyphsData.set(j,  null);
					glyphsData.RemoveByIndex(j);
				}
				else j++;
			}
		}	
	
	}
	
	public function AppendText( addedText:String, index:Int = -1):String
	{
		trace(addedText);
		isDirty = true;
		//if (bufferIndex <0 && addedText.length > 0 && renderingBatch != null ) bufferIndex = renderingBatch.AllocateBufferIndex();
			
		
		if (index == -1 || index > text.length)
			this.text += addedText;
		else{
						
			text = text.substr(0, index) +addedText + text.substr(index, text.length - index);
		}
		
		UpdateLayout();
		
	
 		return this.text;
		
	}
	
	public function SetText(text:String):String
	{
		RemoveText(this.text.length - 1, this.text.length);
		AppendText(text);
		
		return text;
	}
	
	public function AppendTextAtCursor( value:InputData):Void
	{
			
		var data:KeyboardInputData = cast value;
		var key:KeyCode = data.keyCode;
		
		if (key == KeyCode.BACKSPACE){
			RemoveText(cursorIndex -1);
			cursorIndex--;
		}
		else if (key == KeyCode.TAB && isForm && list!=null) list.SelectNext();
		else if (key == 13 && isForm) Validate();
		else if(key > 32){
			AppendText(String.fromCharCode(data.keyCode), cursorIndex);
			cursorIndex++;
		}
		
		
		
		
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
		//trace(chars);
		var textureData:SubTextureData = null;
		var glyphScale:Float=0;
		var glyphHeight:Float=0;
		var currFont:Font = AssetManager.Get().GetFont(font);
		var sizeRatio:Float = this.textSize / currFont.height;
		var carriageReturn:Bool = false;
		var endOfLineReached:Bool = false;
		var isSpecialChar:Bool = false;
		
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
				
				currWord.Clean();
				if (char != "\t" && char != "\n" && char != " ")
					continue
				else isSpecialChar = true;
				
				if (char == "\n")
				{
					line++;
					lines.push(new Array<LineGlyphData>());
				}
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
				else if (!isSpecialChar){
					
					textureData = AssetManager.Get().GetFontGlyphTextureData(font, char, Math.round(textSize), atlas);
					if ( textureData == null){
							
						trace("Embedded visual or glyph" + char + " doesn't exist " );
						continue;
					}	
			
					
				}
				
			}
			
					
			if (glyphsData.length > glyphDataIndex)		glyphData = glyphsData.get(glyphDataIndex);
			else {
					glyphData = {
					x:0,
					y: 0,
					width:0,
					height:0,
					color:0,
					colorChanged:false,
					line:0,
					textureData: null,
					bufferIndex: -1,
					metrics:null
				}
				
				glyphsData.Push(glyphData);
			}
			
			
			glyphMetrics = ((!isEmbedded && !isSpecialChar)? currFont.getGlyphMetrics(currFont.getGlyph(char)):null);	
		
			if (glyphMetrics != null)
			{
				metrics.gHbX = glyphMetrics.horizontalBearing.x * sizeRatio;
				metrics.gHbY = glyphMetrics.horizontalBearing.y * sizeRatio;
				metrics.gAdvX = glyphMetrics.advance.x * sizeRatio;
			}
			else metrics.gHbX = metrics.gHbY = metrics.gAdvX = 0;
			
			glyphData.metrics = glyphMetrics;
				
			if (isEmbedded && embedded.color >= 0 )
			{
				glyphData.colorChanged = true;
				glyphData.color = embedded.color;
				
			}
			else if (attribute != null && attribute.color >= 0 )
			{
				glyphData.colorChanged = true;
				glyphData.color = attribute.color;
				
			}
			else {
				
				glyphData.colorChanged = false;
				glyphData.color = this.color;
			}
			
			
			
			
			
			
			if (!isSpecialChar)
			{
				if (isEmbedded)
				{
					glyphHeight =  (embedded.height > 0 ? embedded.height : this.textSize);
					glyphData.y =  glyphHeight * line ;
					
				}
				else
				{
					glyphHeight = ((glyphMetrics != null) ? glyphMetrics.height * sizeRatio : this.textSize);
					glyphData.y = line * linesHeight  + (line+1)* metrics.fAsc + ( metrics.fAsc - metrics.gHbY) ;
					
				}
				
				glyphScale = textureData.uvH / textureData.uvW;
				glyphData.height = glyphHeight;
				glyphData.width = glyphHeight / glyphScale;
				glyphData.textureData = textureData;
				if (glyphData.bufferIndex < 0 && bufferIndex >= 0) glyphData.bufferIndex = (i == 0 ? this.bufferIndex : renderingBatch.AllocateBufferIndex());
		
			}
			else
			{
				glyphData.textureData = null;
				switch(char)
				{
					case "\n": glyphData.width = 0;
					case "\t": glyphData.width = tabSpacing;
					case " ": glyphData.width = spaceSpacing;
				}
				
				glyphData.height = this.textSize;
				glyphData.y = glyphHeight * line ;
				if (glyphData.bufferIndex >= 0) glyphData.bufferIndex = renderingBatch.FreeBufferIndex(glyphData.bufferIndex);
			}
					
			glyphData.line = line;
					
			//TO change
			if (this.width == 0) SetBaseWidth(glyphData.x + glyphData.width);
			if (this.height == 0)	SetBaseHeight(textSize);
			
			if (prevglyphData != null && char != "\n" )
			{
				if (prevglyphData.metrics != null)
				{
					prevMetrics.gHbX = prevglyphData.metrics.horizontalBearing.x * sizeRatio;
					prevMetrics.gHbY = prevglyphData.metrics.horizontalBearing.y * sizeRatio;
					prevMetrics.gAdvX = prevglyphData.metrics.advance.x * sizeRatio;
				}
				else prevMetrics.gHbX = prevMetrics.gHbY = prevMetrics.gAdvX = 0;
				glyphData.x = metrics.gHbX  + prevglyphData.x + (prevglyphData.metrics != null? prevMetrics.gAdvX - prevMetrics.gHbX : prevglyphData.width /*+ letterSpacing*/);
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
							
							data = glyphsData.get(currWord.get(i));
							
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
			
			
			if(!isEmbedded && !isSpecialChar) currWord.Push(glyphDataIndex);	
			
			lines[glyphData.line].push({glyph:glyphDataIndex, tab:false, space:false});
			
			prevglyphData = glyphData;
			glyphDataIndex++;
			
			isSpecialChar = false;	
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
						data = prevData = glyphsData.get(lineData[lineData.length - 1].glyph);
						
						if(data.metrics != null)
							data.x = this.width - (data.metrics.advance.x - data.metrics.horizontalBearing.x)*sizeRatio;
						else
							data.x = this.width - data.width;
									
						for (i in 1...lineData.length)
						{
							data = glyphsData.get(lineData[lineData.length - 1 - i].glyph);
							data.x = prevData.x - (prevData.metrics != null? (prevData.metrics.horizontalBearing.x) * sizeRatio : 0) -(data.metrics != null? (data.metrics.advance.x - data.metrics.horizontalBearing.x) * sizeRatio : data.width + letterSpacing);				
							prevData = data;
						}
							
						
							
					}
				
				case Alignment.CENTER:
					
					for (lineData in lines){
						
						if (lineData.length == 0) continue;
						
						data = prevData = glyphsData.get(lineData[lineData.length - 1].glyph);
						gap = this.width - data.x + (data.metrics != null? (data.metrics.advance.x - data.metrics.horizontalBearing.x) * sizeRatio : data.width);
						//trace(gap);
						//trace(this.width);
						//trace(data.x);
						//trace((data.metrics != null? (data.metrics.advance.x - data.metrics.horizontalBearing.x) * sizeRatio : 0));
						if(data.metrics != null)
							data.x = this.width - (gap*0.5) - (data.metrics.advance.x - data.metrics.horizontalBearing.x)*sizeRatio;
						else
							data.x = this.width - data.width - gap * 0.5;
							
						for (i in 1...lineData.length){
							data = glyphsData.get(lineData[lineData.length - 1 - i].glyph);
							data.x = prevData.x - (prevData.metrics != null? (prevData.metrics.horizontalBearing.x) * sizeRatio : 0) -(data.metrics != null? (data.metrics.advance.x - data.metrics.horizontalBearing.x) * sizeRatio : data.width + letterSpacing);				
							prevData = data;
						}
						
					}
					
				case Alignment.JUSTIFIED:
					for (lineData in lines){
						if (lineData.length == 0 || lineData == lines[lines.length -1]) continue;
						data = prevData = glyphsData.get(lineData[lineData.length - 1].glyph);
						gap = this.width - data.x + (data.metrics != null? (data.metrics.advance.x - data.metrics.horizontalBearing.x) * sizeRatio : data.width);
						gap /= lineData.length;
						for (i in 1...lineData.length)
						glyphsData.get(lineData[i].glyph).x += gap*i;
					}
				
			}
			
		}
		if (cursor != null){
			cursorIndex = cursorIndex;
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
				for (i in 0...glyphsData.length)
				{
					if (glyphsData.get(i).bufferIndex > 0) renderingBatch.FreeBufferIndex(glyphsData.get(i).bufferIndex);
				}
			}
			else
			{
				for (i in 0...glyphsData.length)
				{
					
					if (glyphsData.get(i).bufferIndex < 0 && glyphsData.get(i).textureData !=null)
					{
						trace(i);
						trace(glyphsData.get(i).textureData);
						if (i == 0) glyphsData.get(i).bufferIndex = value;
						else glyphsData.get(i).bufferIndex = renderingBatch.AllocateBufferIndex();
						
					}
				}
			
			}
			
		
		}
		
		return super.set_bufferIndex(value);
	}
	
	override function set_renderingBatch(value:RenderedObjectBatch):RenderedObjectBatch 
	{
	
		if (value != renderingBatch)
		{
			if (renderingBatch != null)
			{
				renderingBatch.RemoveDirtyObject(this);
				if (bufferIndex >= 0){
					var data:RenderedGlyphData;
					for (i in 0...glyphsData.length)
					{
						data = glyphsData.get(i);
						if (data.bufferIndex > 0) renderingBatch.FreeBufferIndex(data.bufferIndex);
					}
				}
				
				if (cursor != null && cursor.renderingBatch != null && cursor.bufferIndex >= 0)
				{
					cursor.renderingBatch.RemoveDirtyObject(cursor);
					cursor.renderingBatch.FreeBufferIndex(cursor.bufferIndex);
				}
				
			}
			
			renderingBatch = value;
			
			if (renderingBatch != null && bufferIndex >=0)
			{
				bufferIndex = renderingBatch.AllocateBufferIndex();
				
			}
			if (cursor != null && cursor.renderingBatch != value) cursor.renderingBatch = value;
		
			
			isDirty = true;
			
		}
		
		
		return renderingBatch;
	
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
	
	override function set_color(value:UInt):UInt 
	{
		if (glyphsData != null)
		{
			for (i in 0...glyphsData.length)
			{
				if (!glyphsData.get(i).colorChanged)
				glyphsData.get(i).color = value;
				
			}
		}
		
		return super.set_color(value);
	}
	
	override public function set_height(value:Float):Float 
	{
		needLayoutUpdate = true;
		return super.set_height(value);
	}

	override public function set_width(value:Float):Float 
	{
		//trace("changed");
		needLayoutUpdate = isDirty = true;
		return super.set_width(value);
	}
		
	public function FocusOn(value:InputData=null):Void 
	{
		
		if (InputManager.Get().focusedObject != this)
		{
			if(InputManager.Get().focusedObject != null)	InputManager.Get().focusedObject.FocusOff();
			InputManager.Get().focusedObject = this;
		}
		
		InputManager.Get().BindToInput(StringLibrary.ANY, InputType.KEY_DOWN, AppendTextAtCursor, this.name);
		InputManager.Get().BindToInput(StringLibrary.ANY, InputType.MOUSE_CLICK, SetCursorPosition, this.name);
		
		SetCursorPosition();
		cursor.height = linesHeight + AssetManager.Get().GetFont(font).ascender * (this.textSize / AssetManager.Get().GetFont(font).height);
		
		Wait.ClearWait(this.name);
		ShowCursor();
	}
	
	public function FocusOff():Void 
	{
		
		InputManager.Get().UnbindFromInput(StringLibrary.ANY, InputType.KEY_DOWN, AppendTextAtCursor, this.name);
		InputManager.Get().UnbindFromInput(StringLibrary.ANY, InputType.MOUSE_CLICK, SetCursorPosition, this.name);
		Wait.ClearWait(this.name);
		HideCursor();
		
	}
	
	public function Validate():Void 
	{
		
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
	
	function get_isInteractive():Bool 
	{
		return isInteractive;
	}
	
	function set_isInteractive(value:Bool):Bool 
	{
		
		if (isInteractive != value)
		{
			if (value == true)
			{
				onAABBTree = true;
				InputManager.Get().BindToInput(StringLibrary.ANY, InputType.MOUSE_CLICK,FocusOn, this.name);
			}
			else
			{
				onAABBTree = false;
				InputManager.Get().UnbindFromInput(StringLibrary.ANY, InputType.MOUSE_CLICK,FocusOn, this.name);
				
			}
			
		}
		
		return isInteractive = value;
	}
		
	function set_alignment(value:Alignment):Alignment 
	{
		autoAdjust = AutoAdjust.ADJUST_TEXT;
		needLayoutUpdate = isDirty= true;
	
		return alignment = value;
	}
	
	
	private function SetCursorPosition(value:InputData = null):Void
	{
		var mouseX:Float = MousePos.current.x;
		var mouseY:Float = MousePos.current.y;
		var distance:Float = this.width * 2;
		var bestDistance:Float = distance;
		var position : Int = glyphsData.length ;
		
		for (i in 0...glyphsData.length)
		{
			
			if ( glyphsData.get(i).line * linesHeight > mouseY) continue;
			if (  glyphsData.get(i).x + this.x > mouseX) continue;
			
			distance = Math.sqrt(Math.pow(mouseX - glyphsData.get(i).x, 2) + Math.pow(mouseY - glyphsData.get(i).y, 2));
			
			if (distance < bestDistance){
				bestDistance = distance;
				position = i;
			}
				
			
		}
		
		cursorIndex = position+1;
	}
	
	function set_cursorIndex(value:Int):Int 
	{
		if (glyphsData != null && value < glyphsData.length && glyphsData.get(value) != null)
		{
			cursor.x = this.x +  glyphsData.get(value).x - cursor.width;
			cursor.y = this.y +  glyphsData.get(value).line * linesHeight  + ( glyphsData.get(value).line)* AssetManager.Get().GetFont(font).ascender * (this.textSize / AssetManager.Get().GetFont(font).height);	
			cursorIndex = value;
		}
		else if (glyphsData != null && value == glyphsData.length && glyphsData.length > 0)
		{
			cursor.x = this.x +  glyphsData.get(glyphsData.length-1).x + glyphsData.get(glyphsData.length-1).width - cursor.width;
			cursor.y = this.y +  glyphsData.get(glyphsData.length-1).line * linesHeight  + ( glyphsData.get(glyphsData.length-1).line)* AssetManager.Get().GetFont(font).ascender * (this.textSize / AssetManager.Get().GetFont(font).height);	
			cursorIndex = value;	
		}
		else{
			cursor.x = this.x;
			cursor.y = this.y;
			cursorIndex = 0;
		}
		return cursorIndex ;
	}
	
	
	
	
	
}

typedef RenderedGlyphData =
{
	public var x:Float;
	public var y:Float;
	public var width:Float;
	public var height:Float;
	public var color:Int;
	public var colorChanged:Bool;
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