package beardFramework.graphics.batches;

import beardFramework.graphics.objects.RenderedObject;
import beardFramework.graphics.core.BatchedVisual;
import beardFramework.graphics.core.Renderer;
import beardFramework.graphics.text.BatchedTextField;
import beardFramework.utils.data.DataU;
import beardFramework.utils.graphics.Color;
import beardFramework.resources.MinAllocArray;
import beardFramework.utils.libraries.StringLibrary;
import haxe.ds.Vector;
import lime.graphics.opengl.GL;
import lime.math.Vector2;
import lime.utils.Float32Array;
import lime.utils.UInt16Array;
/**
 * ...
 * @author 
 */
class UIBatch extends Batch 
{

	
	public function new() 
	{
		super();
		
	}
	override function Init(batchData:BatchRenderingData ):Void
	{
		super.Init(batchData);
	
	}
	
	override public function UpdateRenderedData():Void
	{
		if (renderer.ready){
				
			
			if ( dirtyObjects == null ||  dirtyObjects.length == 0) return;
			
			var verIndex:Int = 0;
			var attIndex:Int = 0;
			var visIndex:Int = 0;
			var depthChange:Bool = false;
			
			GL.bindVertexArray(VAO);
	
			
			if (GetHigherIndex()  >= verticesData.size)
			{
				
				var newBufferData:Float32Array = new Float32Array(verticesData.objectStride * (GetHigherIndex()+1));
				
				if(verticesData.size > 0)
					for (i in 0...verticesData.data.length)
						newBufferData[i] = verticesData.data[i];
			
				verticesData.data = newBufferData;
				
				if (indicesPerObject > 0){
					
					
					indicesData = new UInt16Array(indicesPerObject * (GetHigherIndex() + 1));
				
					for (i in 0...(GetHigherIndex() + 1)){
						attIndex = i * indicesPerObject ;
						for(j in 0...indicesPerObject)
							indicesData[attIndex+j] = indices[j] + i*4;
					}
					
					
					GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, EBO);
					GL.bufferData(GL.ELEMENT_ARRAY_BUFFER,indicesData.byteLength, indicesData, GL.DYNAMIC_DRAW);
				}
						
				
				GL.bindBuffer(GL.ARRAY_BUFFER, VBO);
				GL.bufferData(GL.ARRAY_BUFFER, verticesData.data.byteLength, verticesData.data, GL.DYNAMIC_DRAW);
				
				GL.bindBuffer(GL.ARRAY_BUFFER, 0);
				
			
			}
			
			GL.bindBuffer(GL.ARRAY_BUFFER, VBO);
			
			if (utilFloatArray == null) utilFloatArray = new Float32Array(verticesData.objectStride);
					
			var visual:BatchedVisual;
			var textfield:BatchedTextField;
			var center:Vector2 = new Vector2();
			
			//Update data
			while (dirtyObjects.length > 0)
			{
				
				
				if (dirtyObjects.get(0) == null) continue;
				
				else if ( Std.is(dirtyObjects.get(0), BatchedVisual) && (visual = cast(dirtyObjects.get(0), BatchedVisual)) != null)
				{
					
					
					visIndex = bufferIndices[visual.bufferIndex].bufferIndex *verticesData.objectStride;
					center.x =  visual.width * 0.5;
					center.y = visual.height * 0.5;
					for (i in 0...4)
					{
						verIndex = i * 4;
						attIndex = i * verticesData.vertexStride;
						
						
						//Position
						verticesData.data[visIndex + attIndex] = utilFloatArray[attIndex] = visual.x + center.x + ((vertices[verIndex] * visual.width)-center.x)*visual.rotationCosine -  ((vertices[verIndex+1] * visual.height)-center.y)*visual.rotationSine;
						verticesData.data[visIndex + attIndex+ 1] = utilFloatArray[attIndex+1] = visual.y + center.y + ((vertices[verIndex] * visual.width)-center.x)*visual.rotationSine +  ((vertices[verIndex+1] * visual.height)-center.y)*visual.rotationCosine;
						
						
						if (verticesData.data[visIndex + attIndex + 2] != (visual.visible ? visual.renderDepth : Renderer.Get().VISIBLEDEPTHLIMIT+1)) depthChange = true;
							
						verticesData.data[visIndex + attIndex + 2] = utilFloatArray[attIndex + 2] = visual.visible ? visual.renderDepth :Renderer.Get().VISIBLEDEPTHLIMIT+1;
								
						
						//UV + TextureID
						verticesData.data[visIndex + attIndex + 3] = utilFloatArray[attIndex + 3] = visual.GetTextureData().uvX +  vertices[verIndex + 2] * visual.GetTextureData().uvW;
						verticesData.data[visIndex + attIndex + 4] = utilFloatArray[attIndex + 4] = visual.GetTextureData().uvY +  vertices[verIndex + 3] * visual.GetTextureData().uvH;
						verticesData.data[visIndex + attIndex + 5] = utilFloatArray[attIndex + 5] = cast( visual.GetTextureData().samplerIndex, Float);
						
						//StringLibrary.StringLibrary.DIFFUSE
						verticesData.data[visIndex + attIndex + 6] = utilFloatArray[attIndex + 6] =  visual.material.components[StringLibrary.DIFFUSE].color.getRedf();
						verticesData.data[visIndex + attIndex + 7] = utilFloatArray[attIndex + 7] =  visual.material.components[StringLibrary.DIFFUSE].color.getGreenf();
						verticesData.data[visIndex + attIndex + 8] = utilFloatArray[attIndex + 8] =  visual.material.components[StringLibrary.DIFFUSE].color.getBluef();
						//alpha
						verticesData.data[visIndex + attIndex + 9] = utilFloatArray[attIndex + 9] = visual.alpha;	
						
						//specular
						verticesData.data[visIndex + attIndex + 10] = utilFloatArray[attIndex + 10] =  visual.material.components[StringLibrary.SPECULAR].color.getRedf();
						verticesData.data[visIndex + attIndex + 11] = utilFloatArray[attIndex + 11] =  visual.material.components[StringLibrary.SPECULAR].color.getGreenf();
						verticesData.data[visIndex + attIndex + 12] = utilFloatArray[attIndex + 12] =  visual.material.components[StringLibrary.SPECULAR].color.getBluef();
						//shininess
						verticesData.data[visIndex + attIndex + 13] = utilFloatArray[attIndex + 13] = visual.material.shininess;	
						

						
						
					}
						
					visual.isDirty = false;
				
					GL.bufferSubData(GL.ARRAY_BUFFER, bufferIndices[visual.bufferIndex].bufferIndex * utilFloatArray.byteLength, utilFloatArray.byteLength, utilFloatArray); 
							
				}
				else if (Std.is(dirtyObjects.get(0), BatchedTextField) && (textfield = cast(dirtyObjects.get(0), BatchedTextField)) != null)
				{
					/*
					if (textfield.needLayoutUpdate)	textfield.UpdateLayout();
										center.x =  textfield.width * 0.5;
						center.y = textfield.height * 0.5;	
					var data:RenderedGlyphData;
					for (d in 0...textfield.glyphsData.length)
					{
						data = textfield.glyphsData.get(d);
						if (data.textureData == null || data.bufferIndex < 0) continue;
						
						visIndex = bufferIndices[data.bufferIndex].bufferIndex*verticesData.objectStride;
					
						
						for (i in 0...4)
						{
							verIndex = i * 4;
							attIndex = i * verticesData.vertexStride;
							
							
							//Position
							verticesData.data[visIndex + attIndex] = utilFloatArray[attIndex] = textfield.x  +  center.x + ((vertices[verIndex] * data.width + data.x)-center.x)*textfield.rotationCosine -  ((vertices[verIndex+1] * data.height + data.y)-center.y)*textfield.rotationSine;
							verticesData.data[visIndex + attIndex+ 1] = utilFloatArray[attIndex+1] =  textfield.y + center.y + ((vertices[verIndex] * data.width+data.x)-center.x)*textfield.rotationSine +  ((vertices[verIndex+1] * data.height+data.y)-center.y)*textfield.rotationCosine;
					
							if (verticesData.data[visIndex + attIndex + 2] != (textfield.visible ? textfield.renderDepth : Renderer.Get().VISIBLEDEPTHLIMIT+1))	depthChange = true;
		
	
							verticesData.data[visIndex + attIndex + 2] = utilFloatArray[attIndex + 2] = textfield.visible ? textfield.renderDepth : Renderer.Get().VISIBLEDEPTHLIMIT+1;
							
							
							//UV + Texture ID
							verticesData.data[visIndex + attIndex + 3] = utilFloatArray[attIndex + 3] = data.textureData.uvX +  vertices[verIndex + 2] * data.textureData.uvW;
							verticesData.data[visIndex + attIndex + 4] = utilFloatArray[attIndex + 4] = data.textureData.uvY +  vertices[verIndex + 3] * data.textureData.uvH;
							verticesData.data[visIndex + attIndex + 5] = utilFloatArray[attIndex + 5] = cast(data.textureData.samplerIndex, Float);
													
							//StringLibrary.StringLibrary.DIFFUSE
							verticesData.data[visIndex + attIndex + 6] = utilFloatArray[attIndex + 6] = data.color.getRedf();
							verticesData.data[visIndex + attIndex + 7] = utilFloatArray[attIndex + 7] =	data.color.getGreenf();
							verticesData.data[visIndex + attIndex + 8] = utilFloatArray[attIndex + 8] = data.color.getBluef();
							//alpha
							verticesData.data[visIndex + attIndex + 9] = utilFloatArray[attIndex + 9] = textfield.alpha;	
							
							//specular
							verticesData.data[visIndex + attIndex + 10] = utilFloatArray[attIndex + 10] =  textfield.material.components[StringLibrary.SPECULAR].color.getRedf();
							verticesData.data[visIndex + attIndex + 11] = utilFloatArray[attIndex + 11] =  textfield.material.components[StringLibrary.SPECULAR].color.getGreenf();
							verticesData.data[visIndex + attIndex + 12] = utilFloatArray[attIndex + 12] =  textfield.material.components[StringLibrary.SPECULAR].color.getBluef();
							//shininess
							verticesData.data[visIndex + attIndex + 13] = utilFloatArray[attIndex + 13] = textfield.material.shininess;	
							
							
							
						}
						
						GL.bufferSubData(GL.ARRAY_BUFFER, bufferIndices[data.bufferIndex].bufferIndex * utilFloatArray.byteLength ,utilFloatArray.byteLength, utilFloatArray); 
						
					}
					
					textfield.isDirty = false;
					*/
				}
			}
			
			GL.bindBuffer(GL.ARRAY_BUFFER, 0);
			GL.bindVertexArray(0);
			dirtyObjects.Clean();
			
			
			if (needOrdering && depthChange) OrderVerticesData();
			needUpdate = false;
		}
		
	}
	
	override public function OrderVerticesData():Void 
	{
			
		var ordered:Vector<DepthOrderingData> = new Vector(bufferIndices.length);
		var z:Float = 0;
		
		for (i in 0...ordered.length)
		{
			ordered[i] = { z: verticesData.data[bufferIndices[i].bufferIndex *verticesData.objectStride + 2], stockedIndex : i}   ;
		}
		
		
		ordered.sort(DepthSorting);
		
		var newBufferData:Float32Array = new Float32Array(verticesData.data.length);
		
		for (i in 0...ordered.length)
		{
			
			for (j in 0...verticesData.objectStride)
			{
				newBufferData[i * verticesData.objectStride + j] = verticesData.data[bufferIndices[ordered[i].stockedIndex].bufferIndex * verticesData.objectStride + j];
			}
			bufferIndices[ordered[i].stockedIndex].bufferIndex = i;
			
		}
		
		verticesData.data = newBufferData;
		
		GL.bindBuffer(GL.ARRAY_BUFFER, VBO);
		GL.bufferData(GL.ARRAY_BUFFER, verticesData.data.byteLength, verticesData.data, GL.DYNAMIC_DRAW);
		GL.bindBuffer(GL.ARRAY_BUFFER, 0);
		
		
	}
	private inline function DepthSorting(data1:DepthOrderingData, data2:DepthOrderingData):Int
	{
		var result:Int = 0;
		if (data1.z < data2.z) result = 1;
		else if (data1.z > data2.z) result = -1;
		else result = 0;
		
		return result;		
	}
	
	
	override public function Flush():Void 
	{
		super.Flush();
		dirtyObjects.Clean();
	}
	
}