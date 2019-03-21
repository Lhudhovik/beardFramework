package beardFramework.graphics.core;

import beardFramework.graphics.rendering.Renderer;
import beardFramework.graphics.rendering.batches.RenderedObjectBatch;
import beardFramework.interfaces.IBatch;
import beardFramework.interfaces.IBatchable;
import beardFramework.resources.assets.AssetManager;
import beardFramework.resources.assets.Atlas.SubTextureData;
import haxe.ds.Vector;
import openfl.geom.Matrix;

/**
 * ...
 * @author 
 */
class BatchedVisual extends AbstractVisual implements IBatchable
{
	
	@:isVar public var bufferIndex(get, set):Int;
	@:isVar public var renderingBatch(get, set):IBatch;
	
	public function new(texture:String, atlas:String , name:String = "") 
	{
		super(texture,atlas,name);
		bufferIndex = -1;
		renderingBatch =  cast Renderer.Get().GetRenderable(Renderer.Get().DEFAULT);
	}
	
	override function  set_isDirty(value:Bool):Bool 
	{
		if (value == true && renderingBatch != null && bufferIndex >= 0) renderingBatch.AddDirtyObject(this);
		else if ( value == false && renderingBatch != null) renderingBatch.RemoveDirtyObject(this);
		return isDirty = value;
	}
	
	function get_renderingBatch():IBatch 
	{
		return renderingBatch;
	}
	
	function set_renderingBatch(value:IBatch):IBatch 
	{
		if (value != renderingBatch)
		{
			if (renderingBatch != null)
			{
				renderingBatch.RemoveDirtyObject(this);
				renderingBatch.RemoveAtlas(this.atlas);
				if(bufferIndex >= 0) renderingBatch.FreeBufferIndex(bufferIndex);
			}
			
			renderingBatch = value;
			
			if (renderingBatch != null && bufferIndex >=0)
			{
				if(atlas != null && atlas !="") renderingBatch.AddAtlas(this.atlas);
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
			if(atlas != null && atlas !="") renderingBatch.AddAtlas(this.atlas);
			bufferIndex = renderingBatch.AllocateBufferIndex();
		}
	}
	
	public function ReleaseBufferIndex():Void
	{
		if (renderingBatch != null){
			renderingBatch.RemoveAtlas(this.atlas);
			bufferIndex = renderingBatch.FreeBufferIndex(bufferIndex);
		}
	}

}

