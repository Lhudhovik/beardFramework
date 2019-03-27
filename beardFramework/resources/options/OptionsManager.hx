package beardFramework.resources.options;
import beardFramework.graphics.rendering.Renderer;
import beardFramework.graphics.rendering.Shaders.Shader;
import beardFramework.graphics.rendering.batches.BatchRenderingData;
import beardFramework.graphics.rendering.vertexData.VertexAttribute;
import beardFramework.graphics.screens.BasicLoadingScreen;
import beardFramework.graphics.text.FontFormat;
import beardFramework.graphics.text.BatchedTextField;
import beardFramework.input.InputManager;
import beardFramework.resources.assets.AssetManager;
import lime.graphics.opengl.GL;

/**
 * ...
 * @author Ludo
 */
class OptionsManager
{

	private static var instance(default,null):OptionsManager;
	
	public var resourcesToLoad:Array<ResourceToLoad>;
	public var fontsToLoad:Array<FontToLoad>;
	public var batchesToCreate:Array<BatchToCreate>;
	private var settings(null,null):Xml;
	private function new() 
	{
		
	}
	
	public static inline function Get():OptionsManager
	{
		if (instance == null)
		{
			instance = new OptionsManager();
			instance.Init();
		}
		
		return instance;
	}
	
	private function Init():Void
	{
		
	}
	
	public function parseSettings(xml:Xml):Void
	{
		
		resourcesToLoad = new Array<ResourceToLoad>();
		fontsToLoad = new Array<FontToLoad>();
		batchesToCreate = new Array<BatchToCreate>();
		xml = xml.firstElement();
		
		for (element in xml.elements())
		{
			
			if (element.nodeName == "atlases")
			{
				for (atlas in element.elementsNamed("atlas"))
				{
					resourcesToLoad.push({ type: (atlas.get("fileExtension") == "jpg" ?AssetType.ATLAS_JPG : AssetType.ATLAS_PNG), name : atlas.get("name"), url:atlas.get("path") });
				}
			}
			
			else if (element.nodeName == "fonts")
			{

				BatchedTextField.defaultFont = element.get("default");
				var size:Array<Int> = [];
				var readSize:Array<String> = [];
				for (font in element.elementsNamed("font"))
				{
					
					size = [];
					readSize = font.get("size").split(",");
					for (fontSize in readSize)
					{
						size.push(Std.parseInt(fontSize));
						//trace(size);
					}
				
					fontsToLoad.push({ format: (font.get("fileExtension") == "ttf" ?FontFormat.TTF : FontFormat.OTF), name : font.get("name"), size: size });
				}
			}
			
			else if (element.nodeName == "renderingBatches")
			{
				
				var shaders:Array<Shader> = [];
				var vertexAttributes:Array<VertexAttribute> = [];
				var verticesIndices:Array<Int> = [];
				var vertices:Array<Float> = [];
				var vertexStride:Int;
				var type:Int = GL.VERTEX_SHADER;
				var drawMode:Int = GL.TRIANGLES;
				
				for (template in element.elementsNamed("template"))
				{
					vertexStride = 0;
					shaders = [];
					vertexAttributes = [];
					verticesIndices = [];
					vertices = [];
					
					
					for (indice in template.get("verticesIndices").split(",")){
						if (indice != "")
							verticesIndices.push(Std.parseInt(indice));
					}
					
					
					for (shader in template.elementsNamed("shader")){
					
						
						switch(shader.get("type"))
						{
							
							case "VERTEX_SHADER": type = GL.VERTEX_SHADER;
							case "FRAGMENT_SHADER": type = GL.FRAGMENT_SHADER;							
							
						}
						shaders.push({name: shader.get("name") , type :type});
							
					}
					for (vertex in template.elementsNamed("vertex"))
					{
						for (value in vertex.get("data").split(","))
							vertices.push(Std.parseInt(value));
					}
				
					for (attribute in template.elementsNamed("vertexAttribute")){
						vertexAttributes.push({ name: attribute.get("name") , size:Std.parseInt(attribute.get("size")) , index:Std.parseInt(attribute.get("index")) }) ;
						vertexStride += Std.parseInt(attribute.get("size"));
					}
							
					switch(template.get("drawMode"))
					{
						
						case "POINTS" : drawMode = GL.POINTS;
						case "LINES" : drawMode = GL.LINES;
						case "LINE_LOOP" : drawMode = GL.LINE_LOOP;
						case "LINE_STRIP" : drawMode = GL.LINE_STRIP;
						case "TRIANGLES" : drawMode = GL.TRIANGLES;
						case "TRIANGLE_STRIP" : drawMode = GL.TRIANGLE_STRIP;
						case "TRIANGLE_FAN" : drawMode = GL.TRIANGLE_FAN;
								
					}
					
					Renderer.Get().AddTemplate({name: template.get("name"), type: template.get("type"), drawMode: drawMode, shaders:shaders, indices:verticesIndices, vertices: vertices, vertexAttributes: vertexAttributes, vertexStride : vertexStride, vertexPerObject: Std.parseInt(template.get("vertexPerObject")), z: Std.parseFloat(template.get("z")), lightGroup:template.get("lightGroup")});
					
					
				}
				
				for (batch in element.elementsNamed("batch"))
				{
					batchesToCreate.push({name: batch.get("name"), template: batch.get("template"),needOrdering: (batch.get("needOrdering") == "true")});
				}
				
			}
			
			else if (element.nodeName == "settings")
			{
				settings = element;
				InputManager.Get().ParseInputSettings(settings.elementsNamed("inputs").next());
				
				BasicLoadingScreen.MINLOADINGTIME = Std.parseFloat(settings.elementsNamed("loading").next().get("minLoadingTime")) * 1000; //time is in seconds on the config file so need to translate to milliseconds
				
			}
			
			
		}
	}
	
	public function GetSettings(settingsName:String):Xml
	{
		var returnedSettings : Xml = null;
		if (settingsName == "") returnedSettings = settings;
		else for (element in settings.elementsNamed(settingsName)) 
			if (element.nodeName == settingsName)
			{ 
				returnedSettings = element; 
				break;
			} 
			
		return returnedSettings;
	}
	
	
	
	
}

typedef ResourceToLoad = {
	
	var type : AssetType;
	var name : String;
	var url : String;
	
}

typedef FontToLoad = {
	var size : Array<Int>;
	var format:FontFormat;
	var name:String;
	
}

typedef BatchToCreate = {
	var name : String;
	var template:String;
	var needOrdering:Bool;
}
