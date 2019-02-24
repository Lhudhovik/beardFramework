package beardFramework.graphics.rendering.batches;

import beardFramework.graphics.core.RenderedObject;
import beardFramework.graphics.core.Visual;
import beardFramework.graphics.rendering.Renderer;
import beardFramework.graphics.text.TextField;
import beardFramework.utils.graphics.ColorU;
import beardFramework.resources.MinAllocArray;
import lime.graphics.opengl.GL;
import lime.math.Vector2;
import lime.utils.Float32Array;
import lime.utils.UInt16Array;

/**
 * ...
 * @author 
 */
class RenderedObjectBatch extends Batch 
{

	private var dirtyObjects:MinAllocArray<RenderedObject>;
	public function new() 
	{
		super();
		
	}
	override function Init(batchData:BatchData ):Void
	{
		super.Init(batchData);
		dirtyObjects = new MinAllocArray<RenderedObject>();
		
	}
	
	//override public function InitVertices(indices:Array<Int> = null):Void 
	//{
		//super.InitVertices(indices);
		//vertices = new Float32Array(null, [ 
		////x		y	 	uvX		uvY	new uv
		//0,		1,		0.0,	1.0,
		//1, 		1, 		1.0,	1.0,
		//1, 		0,		1.0,    0.0,
		//0,		0,		0.0,	0.0
		//]);	
		//
		//
	//}
	override public function UpdateRenderedData():Void
	{
		if (renderer.ready){
				
			
			if ( dirtyObjects == null ||  dirtyObjects.length == 0) return;
			
			var verIndex:Int = 0;
			var attIndex:Int = 0;
			var visIndex:Int = 0;
			
			
			GL.bindVertexArray(VAO);
	
			
			//enlarge the buffer data if too small	
			if (GetHigherIndex()  >= verticesData.size)
			{
			
				var newBufferData:Float32Array = new Float32Array(40 * (GetHigherIndex()+1));
				
				if(verticesData.size > 0)
					for (i in 0...verticesData.data.length)
						newBufferData[i] = verticesData.data[i];
			
				verticesData.data = newBufferData;
				
				indicesData = new UInt16Array(6 * (GetHigherIndex() + 1));
				
				for (i in 0...Math.round(indicesData.length / 6)){
					attIndex = i * 6 ;
					indicesData[attIndex] 	= 0 + i*4;
					indicesData[attIndex+1] = 1 + i*4;
					indicesData[attIndex+2] = 2	+ i*4;
					indicesData[attIndex+3] = 2 + i*4;
					indicesData[attIndex+4] = 3	+ i*4;
					indicesData[attIndex+5] = 0 + i*4;
					
				}
				
				GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, EBO);
				GL.bufferData(GL.ELEMENT_ARRAY_BUFFER,indicesData.byteLength, indicesData, GL.DYNAMIC_DRAW);
				
				GL.bindBuffer(GL.ARRAY_BUFFER, VBO);
				GL.bufferData(GL.ARRAY_BUFFER, verticesData.data.byteLength, verticesData.data, GL.DYNAMIC_DRAW);
				
				GL.bindBuffer(GL.ARRAY_BUFFER, 0);
			}
			
			
			GL.bindBuffer(GL.ARRAY_BUFFER, VBO);
			
			if (utilFloatArray == null) utilFloatArray = new Float32Array(40);
					
			var visual:Visual;
			var textfield:TextField;
			var center:Vector2 = new Vector2();
			
			//Update data
			while (dirtyObjects.length > 0)
			{
				
				
				if (dirtyObjects.get(0) == null) continue;
				
				else if ( Std.is(dirtyObjects.get(0), Visual) && (visual = cast(dirtyObjects.get(0), Visual)) != null)
				{
					
					visIndex = visual.bufferIndex*40;
					center.x =  visual.width * 0.5;
					center.y = visual.height * 0.5;
					for (i in 0...4)
					{
						verIndex = i * 4;
						attIndex = i * 10;
						
						
						//Position
						verticesData.data[visIndex + attIndex] = utilFloatArray[attIndex] = visual.x + center.x + ((vertices[verIndex] * visual.width)-center.x)*visual.rotationCosine -  ((vertices[verIndex+1] * visual.height)-center.y)*visual.rotationSine;
						//renderedData.data[visIndex + attIndex] = utilFloatArray[attIndex] = visual.x +  quadVertices[verIndex] * visual.width;
						verticesData.data[visIndex + attIndex+ 1] = utilFloatArray[attIndex+1] = visual.y + center.y + ((vertices[verIndex] * visual.width)-center.x)*visual.rotationSine +  ((vertices[verIndex+1] * visual.height)-center.y)*visual.rotationCosine;
						//renderedData.data[visIndex + attIndex+ 1] = utilFloatArray[attIndex+1] = visual.y +  quadVertices[verIndex+1] * visual.height;
						verticesData.data[visIndex + attIndex + 2] = utilFloatArray[attIndex + 2] = visual.visible ? visual.renderDepth : -2;
								
						
						//UV + TextureID
						verticesData.data[visIndex + attIndex + 3] = utilFloatArray[attIndex + 3] = visual.GetTextureData().uvX +  vertices[verIndex + 2] * visual.GetTextureData().uvW;
						verticesData.data[visIndex + attIndex + 4] = utilFloatArray[attIndex + 4] = visual.GetTextureData().uvY +  vertices[verIndex + 3] * visual.GetTextureData().uvH;
						verticesData.data[visIndex + attIndex + 5] = utilFloatArray[attIndex + 5] = cast( visual.GetTextureData().atlasIndex, Float);
						
						//color
						verticesData.data[visIndex + attIndex + 6] = utilFloatArray[attIndex + 6] =  ColorU.getRed(visual.color)/255;
						verticesData.data[visIndex + attIndex + 7] = utilFloatArray[attIndex + 7] =  ColorU.getGreen(visual.color)/255;
						verticesData.data[visIndex + attIndex + 8] = utilFloatArray[attIndex + 8] =  ColorU.getBlue(visual.color)/255;
						verticesData.data[visIndex + attIndex + 9] = utilFloatArray[attIndex + 9] = visual.alpha;		
						
					}
						
					visual.isDirty = false;
				
					GL.bufferSubData(GL.ARRAY_BUFFER, visual.bufferIndex * utilFloatArray.byteLength, utilFloatArray.byteLength, utilFloatArray); 
								
				}
				else if (Std.is(dirtyObjects.get(0), TextField) && (textfield = cast(dirtyObjects.get(0), TextField)) != null)
				{
					
					if (textfield.needLayoutUpdate)	textfield.UpdateLayout();
										center.x =  textfield.width * 0.5;
						center.y = textfield.height * 0.5;	
					for (data in textfield.glyphsData)
					{
						
						visIndex = data.bufferIndex*40;
					
						
						for (i in 0...4)
						{
							verIndex = i * 4;
							attIndex = i * 10;
							
							
							//Position
							verticesData.data[visIndex + attIndex] = utilFloatArray[attIndex] = textfield.x  +  center.x + ((vertices[verIndex] * data.width + data.x)-center.x)*textfield.rotationCosine -  ((vertices[verIndex+1] * data.height + data.y)-center.y)*textfield.rotationSine;
							//renderedData.data[visIndex + attIndex] = utilFloatArray[attIndex] = textfield.x + data.x +  quadVertices[verIndex] * data.width;
							verticesData.data[visIndex + attIndex+ 1] = utilFloatArray[attIndex+1] =  textfield.y + center.y + ((vertices[verIndex] * data.width+data.x)-center.x)*textfield.rotationSine +  ((vertices[verIndex+1] * data.height+data.y)-center.y)*textfield.rotationCosine;
							//renderedData.data[visIndex + attIndex+ 1] = utilFloatArray[attIndex+1] = textfield.y +  data.y +  quadVertices[verIndex+1] * data.height;
							verticesData.data[visIndex + attIndex + 2] = utilFloatArray[attIndex + 2] = textfield.visible ? textfield.renderDepth : -2;
							
							
							//UV + Texture ID
							verticesData.data[visIndex + attIndex + 3] = utilFloatArray[attIndex + 3] = data.textureData.uvX +  vertices[verIndex + 2] * data.textureData.uvW;
							verticesData.data[visIndex + attIndex + 4] = utilFloatArray[attIndex + 4] = data.textureData.uvY +  vertices[verIndex + 3] * data.textureData.uvH;
							verticesData.data[visIndex + attIndex + 5] = utilFloatArray[attIndex + 5] = cast(data.textureData.atlasIndex, Float);
							
							//color
							verticesData.data[visIndex + attIndex + 6] = utilFloatArray[attIndex + 6] = ColorU.getRed(data.color)/255;
							verticesData.data[visIndex + attIndex + 7] = utilFloatArray[attIndex + 7] = ColorU.getGreen(data.color)/255;
							verticesData.data[visIndex + attIndex + 8] = utilFloatArray[attIndex + 8] = ColorU.getBlue(data.color)/255;
							verticesData.data[visIndex + attIndex + 9] = utilFloatArray[attIndex + 9] = textfield.alpha;		
							
						}
						
						GL.bufferSubData(GL.ARRAY_BUFFER, data.bufferIndex * utilFloatArray.byteLength ,utilFloatArray.byteLength, utilFloatArray); 
						
					}
					
					textfield.isDirty = false;
					
				}
			}
			
			GL.bindBuffer(GL.ARRAY_BUFFER, 0);
			GL.bindVertexArray(0);
			dirtyObjects.Clean();
			
			//var visu:Array<Float> = [];
			//for (i in 0...verticesData.vertexStride)
				//visu.push(verticesData.data[i]);
			//trace(visu);
			needUpdate = false;
		}
		
	}
	
	public inline function AddDirtyObject(object:RenderedObject):Void
	{
		if (dirtyObjects.IndexOf(object) == -1)
		{
			dirtyObjects.Push(object);
			needUpdate = true;
		}
	}
	
	public function RemoveDirtyObject(object:RenderedObject):Void
	{
		dirtyObjects.Remove(object);
	}
	
	override public function Flush():Void 
	{
		super.Flush();
		dirtyObjects.Clean();
	}
}