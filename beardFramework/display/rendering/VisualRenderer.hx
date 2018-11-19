package beardFramework.display.rendering;
import beardFramework.display.core.BeardLayer;
import beardFramework.display.core.Visual;
import lime.graphics.opengl.GL;
import lime.utils.Float32Array;
import lime.utils.UInt16Array;




@:access(lime.graphics.opengl.GL)
/**
 * ...
 * @author 
 */
class VisualRenderer extends DefaultRenderer
{
	
	private static var instance:VisualRenderer;

	private function new()
	{
		super();
	}
	
	
	public static inline function Get():VisualRenderer
	{
		if (instance == null)
		{
			instance = new VisualRenderer();
			instance.Init();
		}
		
		return instance;
	}
	
	
	
	public function UpdateBufferFromVisuals(visuals:Array<Visual>):Void
	{
		
		if (visuals == null || visuals.length == 0) return;
		
		var verIndex:Int = 0;
		var attIndex:Int = 0;
		var visIndex:Int = 0;
		
		GL.bindVertexArray(VAO);
	
		
		//enlarge the buffer data if too small	
		if (GetHigherIndex()  >= visualData.visualsCount)
		{
			var newBufferData:Float32Array = new Float32Array(40 * (GetHigherIndex()+1));
			
			if(visualData.visualsCount > 0)
				for (i in 0...visualData.data.length)
					newBufferData[i] = visualData.data[i];
		
			visualData.data = newBufferData;

			verticesIndices = new UInt16Array(6 * (GetHigherIndex() + 1));
			
			for (i in 0...Math.round(verticesIndices.length / 6)){
				attIndex = i * 6 ;
				verticesIndices[attIndex] 	= 0 + i*4;
				verticesIndices[attIndex+1] = 1 + i*4;
				verticesIndices[attIndex+2] = 2	+ i*4;
				verticesIndices[attIndex+3] = 2 + i*4;
				verticesIndices[attIndex+4] = 3	+ i*4;
				verticesIndices[attIndex+5] = 0 + i*4;
				
			}
			
			GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, EBO);
			GL.bufferData(GL.ELEMENT_ARRAY_BUFFER,verticesIndices.byteLength, verticesIndices, GL.DYNAMIC_DRAW);
			
			GL.bindBuffer(GL.ARRAY_BUFFER, VBO);
			GL.bufferData(GL.ARRAY_BUFFER, visualData.data.byteLength, visualData.data, GL.DYNAMIC_DRAW);
				
			
			GL.bindBuffer(GL.ARRAY_BUFFER, 0);
		}
		
		
		GL.bindBuffer(GL.ARRAY_BUFFER, VBO);
		
		if (utilFloatArray == null) utilFloatArray = new Float32Array(40);
		
		
		//Update data
		for (visual in visuals)
		{
			if (visual.isDirty == false) continue;
			visIndex = visual.bufferIndex*40;
		
			for (i in 0...4)
			{
				verIndex = i * 4;
				attIndex = i * 10;
				
				
				//Position
				visualData.data[visIndex + attIndex] = utilFloatArray[attIndex] = visual.x +  quadVertices[verIndex] * visual.width;
				visualData.data[visIndex + attIndex+ 1] = utilFloatArray[attIndex+1] = visual.y +  quadVertices[verIndex+1] * visual.height;
				visualData.data[visIndex + attIndex + 2] = utilFloatArray[attIndex + 2] = visual.visible ? visual.renderDepth : -2;
				
				//UV + Texture ID
				visualData.data[visIndex + attIndex + 3] = utilFloatArray[attIndex + 3] = visual.GetTextureData().uvX +  quadVertices[verIndex + 2] * visual.GetTextureData().uvW;
				visualData.data[visIndex + attIndex + 4] = utilFloatArray[attIndex + 4] = visual.GetTextureData().uvY +  quadVertices[verIndex + 3] * visual.GetTextureData().uvH;
				visualData.data[visIndex + attIndex + 5] = utilFloatArray[attIndex + 5] = cast(visual.GetTextureData().atlasIndex, Float);
				
				//color
				visualData.data[visIndex + attIndex + 6] = utilFloatArray[attIndex + 6] = ((visual.color >> 16) & 0xff) / 255.0;
				visualData.data[visIndex + attIndex + 7] = utilFloatArray[attIndex + 7] = ((visual.color >>  8) & 0xff) / 255.0;
				visualData.data[visIndex + attIndex + 8] = utilFloatArray[attIndex + 8] = ( visual.color & 0xff) / 255.0;
				visualData.data[visIndex + attIndex + 9] = utilFloatArray[attIndex + 9] = visual.alpha;		
				
				
			}
	
			
			
			
			GL.bufferSubData(GL.ARRAY_BUFFER, visual.bufferIndex * utilFloatArray.byteLength ,utilFloatArray.byteLength, utilFloatArray); 
			
			
			
		}
	
		//DataUtils.DisplayFloatArrayContent(visualData.data, 10);
		
		GL.bindBuffer(GL.ARRAY_BUFFER, 0);
		GL.bindVertexArray(0);
		
		
	}

	public function UpdateBufferFromLayer(layer:BeardLayer):Void
	{
		if (ready){
			
		
		if ( layer.dirtyVisuals == null ||  layer.dirtyVisuals.length == 0) return;
		
		var verIndex:Int = 0;
		var attIndex:Int = 0;
		var visIndex:Int = 0;
		
		GL.bindVertexArray(VAO);
	
		
		//enlarge the buffer data if too small	
		if (GetHigherIndex()  >= visualData.visualsCount)
		{
			var newBufferData:Float32Array = new Float32Array(40 * (GetHigherIndex()+1));
			
			if(visualData.visualsCount > 0)
				for (i in 0...visualData.data.length)
					newBufferData[i] = visualData.data[i];
		
			visualData.data = newBufferData;

			verticesIndices = new UInt16Array(6 * (GetHigherIndex() + 1));
			
			for (i in 0...Math.round(verticesIndices.length / 6)){
				attIndex = i * 6 ;
				verticesIndices[attIndex] 	= 0 + i*4;
				verticesIndices[attIndex+1] = 1 + i*4;
				verticesIndices[attIndex+2] = 2	+ i*4;
				verticesIndices[attIndex+3] = 2 + i*4;
				verticesIndices[attIndex+4] = 3	+ i*4;
				verticesIndices[attIndex+5] = 0 + i*4;
				
			}
			
			GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, EBO);
			GL.bufferData(GL.ELEMENT_ARRAY_BUFFER,verticesIndices.byteLength, verticesIndices, GL.DYNAMIC_DRAW);
			
			GL.bindBuffer(GL.ARRAY_BUFFER, VBO);
			GL.bufferData(GL.ARRAY_BUFFER, visualData.data.byteLength, visualData.data, GL.DYNAMIC_DRAW);
			
			GL.bindBuffer(GL.ARRAY_BUFFER, 0);
		}
		
		
		GL.bindBuffer(GL.ARRAY_BUFFER, VBO);
		
		if (utilFloatArray == null) utilFloatArray = new Float32Array(40);
		
		var visual:Visual;
		//Update data
		for (index in  0...layer.dirtyVisuals.length)
		{
			
			if ((visual = layer.visuals[layer.dirtyVisuals.get(index)]) == null) continue;
			
			visIndex = visual.bufferIndex*40;
		
			for (i in 0...4)
			{
				verIndex = i * 4;
				attIndex = i * 10;
				
				
				//Position
				visualData.data[visIndex + attIndex] = utilFloatArray[attIndex] = visual.x +  quadVertices[verIndex] * visual.width;
				visualData.data[visIndex + attIndex+ 1] = utilFloatArray[attIndex+1] = visual.y +  quadVertices[verIndex+1] * visual.height;
				visualData.data[visIndex + attIndex + 2] = utilFloatArray[attIndex + 2] = visual.visible ? visual.renderDepth : -2;
				
				//UV + TextureID
				visualData.data[visIndex + attIndex + 3] = utilFloatArray[attIndex + 3] = visual.GetTextureData().uvX +  quadVertices[verIndex + 2] * visual.GetTextureData().uvW;
				visualData.data[visIndex + attIndex + 4] = utilFloatArray[attIndex + 4] = visual.GetTextureData().uvY +  quadVertices[verIndex + 3] * visual.GetTextureData().uvH;
				visualData.data[visIndex + attIndex + 5] = utilFloatArray[attIndex + 5] = cast( visual.GetTextureData().atlasIndex, Float);
				
				//color
				visualData.data[visIndex + attIndex + 6] = utilFloatArray[attIndex + 6] = ((visual.color >> 16) & 0xff) / 255.0;
				visualData.data[visIndex + attIndex + 7] = utilFloatArray[attIndex + 7] = ((visual.color >>  8) & 0xff) / 255.0;
				visualData.data[visIndex + attIndex + 8] = utilFloatArray[attIndex + 8] = ( visual.color & 0xff) / 255.0;
				visualData.data[visIndex + attIndex + 9] = utilFloatArray[attIndex + 9] = visual.alpha;		
				
				//textureID
				
			}
	
			
			visual.isDirty = false;
			
			GL.bufferSubData(GL.ARRAY_BUFFER, visual.bufferIndex * utilFloatArray.byteLength, utilFloatArray.byteLength, utilFloatArray); 
			
			
			
		}
		
	
		
		GL.bindBuffer(GL.ARRAY_BUFFER, 0);
		GL.bindVertexArray(0);
		
		layer.dirtyVisuals.Clean();
		}
	}
	
		
}