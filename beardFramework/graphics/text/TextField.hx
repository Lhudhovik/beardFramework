package beardFramework.graphics.text;
import beardFramework.core.BeardGame;
import beardFramework.graphics.cameras.Camera;
import beardFramework.graphics.objects.Visual;
import beardFramework.graphics.core.Framebuffer;
import beardFramework.graphics.objects.Quad;
import beardFramework.graphics.ui.FocusableList;
import beardFramework.input.InputManager;
import beardFramework.input.InputType;
import beardFramework.input.MousePos;
import beardFramework.input.data.InputData;
import beardFramework.input.data.KeyboardInputData;
import beardFramework.interfaces.IFocusable;
import beardFramework.resources.MinAllocArray;
import beardFramework.resources.assets.AssetManager;
import beardFramework.resources.assets.Atlas.SubTextureData;
import beardFramework.resources.assets.FontAtlas;
import beardFramework.resources.assets.Texture;
import beardFramework.updateProcess.Wait;
import beardFramework.utils.graphics.Color;
import beardFramework.utils.graphics.Scrolling;
import beardFramework.utils.libraries.StringLibrary;
import beardFramework.utils.math.MathU;
import lime.graphics.opengl.GL;
import lime.graphics.opengl.GLTexture;
import lime.text.Font;
import lime.text.GlyphMetrics;
import lime.ui.KeyCode;

using beardFramework.utils.extensions.RenderedObjectEx;
/**
 * ...
 * @author 
 */
class TextField extends Visual implements IFocusable
{

	private static var instanceCount:Int = 0;
	public static var defaultFont:String="";
	public static var framebuffer:Framebuffer;
	public static var quad:Quad;
	
	public var list:FocusableList;
	@:isVar public var font(get, set):String;
	@:isVar public var isInteractive(get, set):Bool = false;
	public var alignment(default, set):TextAlignment;
	public var verticalAdjust(default, set):TextAdjust;
	public var horizontalAdjust(default, set):TextAdjust;
	
	public var scrolling(default, set):UInt;
	public var textWidth:Int = 0;
	public var textHeight:Int = 0;
	public var glyphsData:MinAllocArray<RenderedGlyphData>;
	public var needLayoutUpdate(default, null):Bool = false;
	
	public var lineSpacing(default, set):Float = 0;
	public var letterSpacing(default, set):Float = 0;
	public var tabSpacing(default, set):Float = 0;
	public var spaceSpacing(default, set):Float = 0;
	public var text(default, null):String;
	public var textSize:Float;
	public var isForm:Bool;
	public var scrollX(default, null):Int;
	public var scrollY(default, null):Int;
	public var background:Color = Color.CLEAR;
	
	private var linesHeight:Float;
	private var cursor:Visual;
	private var cursorIndex(default, set):Int;
	
	private var textTexture:Texture;
	
	public function new(text:String="", font:String="", size:Int = 32,name:String = "" ) 
	{
		super("", AssetManager.Get().FONT_ATLAS_NAME, name != "" ? name : "TextField_" + instanceCount++ );
		
		this.text = "";
	
		glyphsData = new MinAllocArray<RenderedGlyphData>();
		
		alignment = TextAlignment.LEFT;
		horizontalAdjust = verticalAdjust = TextAdjust.FIELD;
		
		isInteractive = false;
		linesHeight = textSize = size;
		
		this.font = (font != "" ? font : defaultFont);
		
		if(text != "") AppendText(text);
	
		cursor = new Visual(AssetManager.Get().GetFontGlyphTextureName(this.font, "|",Std.int(this.textSize)), this.atlas, "cursor" + (instanceCount-1));
	
		cursor.visible = false;
		cursor.width =  5;
		cursor.height = linesHeight ;
				
		letterSpacing = textSize/50; //to adjust with format
		lineSpacing = textSize / 10;
		tabSpacing = textSize;
		spaceSpacing = textSize;
		needLayoutUpdate = true;
		cursorIndex = 0;
		
		scrollX = scrollY = 0;
		
		isForm = false;
		
		
		if (framebuffer == null) framebuffer = new Framebuffer(StringLibrary.TEXTFIELD);
		if (quad == null){
			quad = new Quad();
			quad.reverse = false;
		}
			
		var glTexture:GLTexture = GL.createTexture();
		GL.bindTexture(GL.TEXTURE_2D, glTexture);
		GL.texImage2D(GL.TEXTURE_2D, 0,GL.RGBA, 100, 30, 0,GL.RGBA,GL.FLOAT, 0);
		GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.LINEAR);
		GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.LINEAR);
		GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.REPEAT);
		GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.REPEAT);
		
		textTexture = AssetManager.Get().AddTexture(this.name, glTexture , 100, 30);
		
		material.SetComponentAtlas(StringLibrary.DIFFUSE,  "");
		this.SetBaseHeight(textSize);
		this.SetBaseWidth(textSize);
		needLayoutUpdate = true;
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
			//
			//for (i in 0...count)
			//{
				//if (glyphsData.length-1 >= i && glyphsData.get(glyphsData.length-i-1) != null)
				//glyphsData.get(glyphsData.length-1-i).bufferIndex = renderingBatch.FreeBufferIndex(glyphsData.get(glyphsData.length-1-i).bufferIndex);
			//}
			
			//if (bufferIndex >= 0 && renderingBatch != null) renderingBatch.AllocateBufferIndex(bufferIndex);
		}
		
		needLayoutUpdate = true;
		
 		return this.text;
		
	}
	
	public function AppendText( addedText:String, index:Int = -1):String
	{
		//trace(addedText);
		isDirty = true;
		//if (bufferIndex <0 && addedText.length > 0 && renderingBatch != null ) bufferIndex = renderingBatch.AllocateBufferIndex();
			
		
		if (index == -1 || index > text.length)
			this.text += addedText;
		else{
						
			text = text.substr(0, index) +addedText + text.substr(index, text.length - index);
		}
		
		needLayoutUpdate = true;
		
	
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
	
	public function RenderText(camera:Camera):Void
	{
		
		var glyphData:RenderedGlyphData = null;
		var closerSize:Int = cast(AssetManager.Get().GetAtlas(this.atlas), FontAtlas).GetClosestTextSize(font, Math.round(textSize));
		var atlasTexture:Texture =  AssetManager.Get().GetTexture(atlas);
		
		textTexture.width = Std.int(MathU.Max(textWidth, this.width));
		textTexture.height = Std.int(MathU.Max(textHeight, this.height));
		
		var screenRatioWidth:Float = BeardGame.Get().window.width / textTexture.width;
		var screenRatioheight:Float = BeardGame.Get().window.height / textTexture.height;
		
		
		GL.deleteTexture(textTexture.glTexture);
		textTexture.glTexture = GL.createTexture();
		GL.bindTexture(GL.TEXTURE_2D, textTexture.glTexture);
		GL.texImage2D(GL.TEXTURE_2D, 0, GL.RGBA, textTexture.width  ,textTexture.height , 0, GL.RGBA, GL.FLOAT, 0);
		GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.LINEAR);
		GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.LINEAR);
		GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.REPEAT);
		GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.REPEAT);
		
					
		framebuffer.Bind();
		GL.framebufferTexture2D(GL.FRAMEBUFFER, GL.COLOR_ATTACHMENT0, GL.TEXTURE_2D, textTexture.glTexture, 0);
		GL.clearColor(background.getRedf(), background.getGreenf(), background.getBluef(),background.getAlphaf());
		GL.clear(GL.COLOR_BUFFER_BIT);
		GL.viewport(0,0, textTexture.width , textTexture.height);
				
		for (i in 0...glyphsData.length)
		{
			glyphData = glyphsData.get(i);
			
			if (glyphData != null && glyphData.textureData != null)
			{
				if (glyphData.textureData.samplerIndex != atlasTexture.fixedIndex) quad.texture = AssetManager.Get().GetTextureByFixedIndex(glyphData.textureData.samplerIndex).glTexture;
				else quad.texture = atlasTexture.glTexture;
				
				quad.uvs.x = glyphData.textureData.uvX;
				quad.uvs.y = glyphData.textureData.uvY;
				quad.uvs.width = glyphData.textureData.uvW;
				quad.uvs.height = glyphData.textureData.uvH;
				quad.width = Std.int(glyphData.width*screenRatioWidth);
				quad.height =Std.int(glyphData.height*screenRatioheight);
				quad.x = glyphData.x*screenRatioWidth;
				quad.y = glyphData.y*screenRatioheight;
				quad.color = glyphData.color;
				quad.Render();
			}
		}

		framebuffer.UnBind();
		this.texture = this.name;
		
		SetScrollPosition();
		
	
	}
	override function Reinit():Void 
	{
		//super.Reinit();
	}
	
	/**
	 * Increment the scrolling factors with the specified values
	 * @param	h horizonal value to add to the scrolling position
	 * @param	v vertical value to add to the scrolling position
	 */
	
	public inline function Scroll(h:Float =0, v:Float = 0):Void
	{
		
		SetScrollPosition(scrollX += Std.int(h), scrollY += Std.int(v));
		
	}
	/**
	 * Update the current displayed text depending on the scrolling factor
	 * @param	h horizonal scroll. If the value is <0 then it is set to 0
	 * @param	v vertical scroll. If the value is <0 then it is set to 0
	 */
	public function SetScrollPosition(h:Int =0, v:Int =0 ):Void
	{
		if (h < 0) h = 0;
		if (v < 0) v = 0;
		
		
		scrollX = Std.int(MathU.Min(h, textTexture.width - width));
		material.components[StringLibrary.DIFFUSE].uv.x = scrollX / textTexture.width;
		material.components[StringLibrary.DIFFUSE].uv.width = (width / textTexture.width);
		
		scrollY = Std.int(MathU.Min(v, textTexture.height-height));
		material.components[StringLibrary.DIFFUSE].uv.y = 1 - (scrollY / textTexture.height);
		material.components[StringLibrary.DIFFUSE].uv.height =  -(height/ textTexture.height);
		
	}
	
	override public function Render(camera:Camera):Int 
	{
		if (isDirty && needLayoutUpdate){
			
			UpdateLayout();		
			RenderText(camera);
		}
		return super.Render(camera);
	}
	
	public function UpdateLayout():Void
	{
		
		var glyphMetrics:GlyphMetrics = null;
		var defaultGlyphMetrics = new GlyphMetrics();

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
		var textureData:SubTextureData = null;
		var glyphScale:Float=0;
		var glyphHeight:Float=0;
		var currFont:Font = AssetManager.Get().GetFont(font);
		var sizeRatio:Float = this.textSize / currFont.height;
		var carriageReturn:Bool = false;
		var endOfLineReached:Bool = false;
		SetScrollPosition();
		
		textWidth = 0;
		textHeight = 0;
		
		metrics =  {gAdvX:0, fAsc:currFont.ascender * sizeRatio, gHbX:0, gHbY:0, isValid:false}
		prevMetrics =  {gAdvX:0, fAsc:currFont.ascender * sizeRatio, gHbX:0, gHbY:0, isValid:false}
	
		var lines = new Array<Array<LineGlyphData>>();
		lines.push(new Array<LineGlyphData>());
		
		var i:Int = 0;
		var currentAttributeLength:Int = 0;
		
		while (i < chars.length)
		{
			char = chars[i];
			
			if (char == "<" && chars[i + 1] == "{")
			{
				var startTag:Int = i + 1;
				var endTag:Int = chars.indexOf(">", startTag);
				
				//tag = text.substr(startTag, endTag);
				tag = chars[startTag];
				
				for (j in startTag+1...endTag)	tag += chars[j];
				
				attribute = haxe.Json.parse(tag);
				
				i = endTag + 1;
				continue;
					
			}
			else if (char == "~" && chars[i + 1] == "{")
			{
				var startTag:Int = i + 1;
				var endTag:Int = chars.indexOf("~", startTag);
				
				tag = chars[startTag]; 
				for (j in startTag+1...endTag)	tag += chars[j];
				
				embedded = haxe.Json.parse(tag);
				
				i = endTag + 1;
				
				if (embedded == null || embedded.visual == null || embedded.visual == "" || embedded.atlas == null || embedded.atlas == "")
					continue;
				else
				{
					isEmbedded = true;
					textureData = AssetManager.Get().GetSubTextureData(embedded.visual,embedded.atlas);
					currWord.Clean();
				}
				
				
			}
			else if (char.charCodeAt(0) < 33 && char.charCodeAt(0) > 0)
			{
				
				currWord.Clean();
				textureData = null;
				if (char != "\t" && char != "\n" && char != " "){
					i++;
					continue;
				}
				
				
				if (char == "\n")
				{
					line++;
					lines.push(new Array<LineGlyphData>());
				}
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
				else{
					
					textureData = AssetManager.Get().GetFontGlyphTextureData(font, char, Math.round(textSize), atlas);
					if ( textureData == null){
							
						trace("Embedded visual or glyph" + char + " doesn't exist " );
						i++;
						continue;
					}	
			
					
				}
				
				
				
			}
			
			
			//glyph Data and metrics retrieve
			if (glyphsData.length > glyphDataIndex)		glyphData = glyphsData.get(glyphDataIndex);
			else {
				glyphData = {x:0, y: 0, width:0, height:0, color:this.color, colorChanged:false, line:0, textureData: null,	metrics:null}
				glyphsData.Push(glyphData);
			}
			
			glyphMetrics = ((!isEmbedded && textureData != null) ? currFont.getGlyphMetrics(currFont.getGlyph(char)):defaultGlyphMetrics);	
		
			metrics.gHbX = glyphMetrics.hBearing.x * sizeRatio;
			metrics.gHbY = glyphMetrics.hBearing.y * sizeRatio;
			metrics.gAdvX = glyphMetrics.advance.x * sizeRatio;
			metrics.isValid = glyphMetrics.isValid;
			
			glyphData.metrics = glyphMetrics;
				
			//Color
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
			
			
			//Size, texture & baseLine position
			if (textureData != null)
			{
				if (isEmbedded)
				{
					glyphHeight =  (embedded.height > 0 ? embedded.height : this.textSize);
					glyphData.y =  glyphHeight * line ;
					
				}
				else
				{
					glyphHeight = ((glyphMetrics.isValid) ? glyphMetrics.height * sizeRatio : this.textSize);
					glyphData.y = line * linesHeight  + (line+1)* metrics.fAsc + ( metrics.fAsc - metrics.gHbY) ;
					
				}
				
				glyphScale = textureData.uvH / textureData.uvW;
				//glyphScale = textureData.imageArea.height / textureData.imageArea.width;
				glyphData.height = glyphHeight;
				glyphData.width = glyphHeight / glyphScale;
				glyphData.textureData = textureData;
				
		
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
				
			}
					
			glyphData.line = line;
		
			
			//Previous glyph metrics retrieve
			if (prevglyphData != null && char != "\n" )
			{
				prevMetrics.gHbX = prevglyphData.metrics.hBearing.x * sizeRatio;
				prevMetrics.gHbY = prevglyphData.metrics.hBearing.y * sizeRatio;
				prevMetrics.gAdvX = prevglyphData.metrics.advance.x * sizeRatio;
							
				glyphData.x = metrics.gHbX  + prevglyphData.x + ((prevMetrics.isValid) ? prevMetrics.gAdvX - prevMetrics.gHbX : prevglyphData.width /*+ letterSpacing*/);
			}
			else	glyphData.x =  metrics.gHbX;
			
			
			
			switch(horizontalAdjust)
			{
				
				case TextAdjust.FIELD: if (glyphData.x + glyphData.width > width)	SetBaseWidth(glyphData.x + glyphData.width);
					textWidth = this.intWidth();
					
				case TextAdjust.TEXT : 
					if((glyphData.x + glyphData.width > this.width))
					{
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
							data.x =  data.metrics.hBearing.x * sizeRatio;
							else data.x = data.metrics.hBearing.x * sizeRatio  + prevData.x + (prevData.metrics.isValid ? (prevData.metrics.advance.x - prevData.metrics.hBearing.x) * sizeRatio : prevData.width + letterSpacing);					
							
							data.y = (data.metrics.isValid ? (line * linesHeight + (line+1) * metrics.fAsc + (metrics.fAsc - (data.metrics.hBearing.y * sizeRatio))) : data.height * line) ;
							
							prevData = data;
							
						}
						
						
						
						glyphData.y = ( metrics.isValid ? line * linesHeight  + (line+1)* metrics.fAsc + ( metrics.fAsc - metrics.gHbY) : glyphHeight * line );
						glyphData.x = metrics.gHbX;
						
						if (prevData != null)
							glyphData.x += prevData.x + (prevData.metrics.isValid ? (prevData.metrics.advance.x - prevData.metrics.hBearing.x) * sizeRatio : prevData.width + letterSpacing);
					
						if (glyphData.x + glyphData.width > textWidth)
							textWidth = Std.int(glyphData.x + glyphData.width);
					}
					
				case TextAdjust.SCROLLING :
					if (glyphData.x + glyphData.width > textWidth)
						textWidth = Std.int(glyphData.x + glyphData.width);
				
				case TextAdjust.NONE:
					if (glyphData.x + glyphData.width > textWidth)
						textWidth = Std.int(glyphData.x + glyphData.width);
			}
			
			switch(verticalAdjust)
			{
				case TextAdjust.FIELD :
					if (glyphData.y + glyphData.height > height)	SetBaseHeight(glyphData.y + glyphData.height);
					textHeight = this.intHeight();
					
				case TextAdjust.TEXT :
					if (glyphData.y+glyphData.height > this.height)
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
					if (glyphData.y + glyphData.height > textHeight)
						textHeight = Std.int(glyphData.y + glyphData.height);
					
				case TextAdjust.SCROLLING:
					if (glyphData.y + glyphData.height > textHeight)
						textHeight = Std.int(glyphData.y + glyphData.height);
				
				case TextAdjust.NONE:
					if (glyphData.y + glyphData.height > textHeight)
						textHeight = Std.int(glyphData.y + glyphData.height);
			}
			
			
			if(glyphData.metrics.isValid) currWord.Push(glyphDataIndex);	
			
			lines[glyphData.line].push({glyph:glyphDataIndex, tab:false, space:false});
			
			prevglyphData = glyphData;
			glyphDataIndex++;
					
			
			if (attribute != null && ++currentAttributeLength >= attribute.attributeLength)
			{
				currentAttributeLength = 0;
				attribute = null;
				currFont =  AssetManager.Get().GetFont(font);
				sizeRatio = this.textSize / currFont.height;
				metrics.fAsc = currFont.ascender * sizeRatio;
			}
			
			i++;
		}
		
		if (lines.length > 0)
		{
			var data:RenderedGlyphData;
			var prevData:RenderedGlyphData;
			var gap:Float;
		
			switch(alignment)
			{
				case TextAlignment.LEFT: 
				case TextAlignment.RIGHT:
					for (lineData in lines){
					
						if (lineData.length == 0) continue;
						data = prevData = glyphsData.get(lineData[lineData.length - 1].glyph);
						
						if(data.metrics.isValid)
							data.x = textWidth - (data.metrics.advance.x - data.metrics.hBearing.x)*sizeRatio;
						else
							data.x = textWidth - data.width;
									
						for (i in 1...lineData.length)
						{
							data = glyphsData.get(lineData[lineData.length - 1 - i].glyph);
							data.x = prevData.x - (prevData.metrics.isValid? (prevData.metrics.hBearing.x) * sizeRatio : 0) -(data.metrics.isValid ? (data.metrics.advance.x - data.metrics.hBearing.x) * sizeRatio : data.width + letterSpacing);				
							prevData = data;
						}
							
						
							
					}
				
				case TextAlignment.CENTER:
					
					for (lineData in lines){
						
						if (lineData.length == 0) continue;
						
						data = prevData = glyphsData.get(lineData[lineData.length - 1].glyph);
						gap = textWidth - data.x + (data.metrics.isValid? (data.metrics.advance.x - data.metrics.hBearing.x) * sizeRatio : data.width);
						
						if(data.metrics.isValid)
							data.x = textWidth - (gap*0.5) - (data.metrics.advance.x - data.metrics.hBearing.x)*sizeRatio;
						else
							data.x = textWidth - data.width - gap * 0.5;
							
						for (i in 1...lineData.length){
							data = glyphsData.get(lineData[lineData.length - 1 - i].glyph);
							data.x = prevData.x - (prevData.metrics.isValid ? (prevData.metrics.hBearing.x) * sizeRatio : 0) -(data.metrics.isValid ? (data.metrics.advance.x - data.metrics.hBearing.x) * sizeRatio : data.width + letterSpacing);				
							prevData = data;
						}
						
					}
					
				case TextAlignment.JUSTIFIED:
					for (lineData in lines){
						if (lineData.length == 0 || lineData == lines[lines.length -1]) continue;
						data = prevData = glyphsData.get(lineData[lineData.length - 1].glyph);
						gap = textWidth - data.x + (data.metrics.isValid ? (data.metrics.advance.x - data.metrics.hBearing.x) * sizeRatio : data.width);
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
		
		isDirty = true;
		

	}
	
	override function set_atlas(value:String):String 
	{
		if (value != atlas){
			atlas = value;
			Reinit();
			isDirty = true;
			needLayoutUpdate = true;
		}
		return atlas;
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
	
	function set_scrolling(value:UInt):UInt 
	{
		if (scrolling != value) needLayoutUpdate = isDirty = true;
		return scrolling = value;
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
		
	function set_alignment(value:TextAlignment):TextAlignment 
	{
		if(alignment!= value) needLayoutUpdate = isDirty= true;
	
		return alignment = value;
	}
	
	override function set_name(value:String):String 
	{
		var texture:Texture = AssetManager.Get().GetTexture(this.name);
		if ( texture != null && value != name)
		{
			AssetManager.Get().RemoveTexture(this.name);
			AssetManager.Get().AddTexture(this.name, texture.glTexture, texture.width, texture.height, texture.fixedIndex);
		}
		return super.set_name(value);
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
	
	function set_verticalAdjust(value:TextAdjust):TextAdjust 
	{
		if (verticalAdjust != value) needLayoutUpdate = isDirty = true;
		return verticalAdjust = value;
	}
	
	function set_horizontalAdjust(value:TextAdjust):TextAdjust 
	{
		if (horizontalAdjust != value) needLayoutUpdate = isDirty = true;
		return horizontalAdjust = value;
	}
	
	
	
	
}

typedef RenderedGlyphData =
{
	public var x:Float;
	public var y:Float;
	public var width:Float;
	public var height:Float;
	public var color:Color;
	public var colorChanged:Bool;
	public var line:Int;
	public var textureData:SubTextureData;
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
	public var attributeLength:Int;
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
	/** if the metrics are valid or not*/ public var isValid:Bool;
}
enum TextAdjust 
{
	TEXT;
	FIELD;
	SCROLLING;
	NONE;

}


enum TextAlignment 
{
	LEFT;
	CENTER;
	RIGHT;
	JUSTIFIED;

}