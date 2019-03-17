package beardFramework.graphics.core;
import beardFramework.graphics.rendering.Renderer;
import beardFramework.graphics.rendering.batches.RenderedObjectBatch;

/**
 * ...
 * @author 
 */
class BatchedRenderedObject extends RenderedObject 
{

	@:isVar public var bufferIndex(get, set):Int;
	@:isVar public var renderingBatch(get, set):RenderedObjectBatch;
	
	public function new() 
	{
		super();
		bufferIndex = -1;
		renderingBatch =  cast(Renderer.Get().GetBatch(Renderer.Get().DEFAULT), RenderedObjectBatch);
	}

	
	override function  set_isDirty(value:Bool):Bool 
	{
		if (value == true && renderingBatch != null && bufferIndex >= 0) renderingBatch.AddDirtyObject(this);
		else if ( value == false && renderingBatch != null) renderingBatch.RemoveDirtyObject(this);
		return isDirty = value;
	}
	
	function get_renderingBatch():RenderedObjectBatch 
	{
		return renderingBatch;
	}
	
	function set_renderingBatch(value:RenderedObjectBatch):RenderedObjectBatch 
	{
		if (value != renderingBatch)
		{
			if (renderingBatch != null)
			{
				renderingBatch.RemoveDirtyObject(this);
				if(bufferIndex >= 0) renderingBatch.FreeBufferIndex(bufferIndex);
			}
			
			renderingBatch = value;
			
			if (renderingBatch != null && bufferIndex >=0)
			{
				bufferIndex = renderingBatch.AllocateBufferIndex();
			}
		
			
			isDirty = true;
			
		}
		
		
		return renderingBatch;
	}
	
	function get_bufferIndex():Int 
	{
		return bufferIndex;
	}
	
	function set_bufferIndex(value:Int):Int 
	{
		return bufferIndex = value;
	}
	
	public function RequestBufferIndex():Void
	{
		if (renderingBatch != null){
			bufferIndex = renderingBatch.AllocateBufferIndex();
		}
	}
	
	public function ReleaseBufferIndex():Void
	{
		if (renderingBatch != null){
			
			bufferIndex = renderingBatch.FreeBufferIndex(bufferIndex);
		}
	}
	
}