package beardFramework.graphics.core;

import beardFramework.graphics.objects.AbstractVisual;
import beardFramework.graphics.core.Renderer;
import beardFramework.graphics.batches.RenderedObjectBatch;
import beardFramework.graphics.lights.Light;
import beardFramework.interfaces.IBatch;
import beardFramework.interfaces.IBatchable;
import beardFramework.resources.assets.AssetManager;
import beardFramework.resources.assets.Atlas.SubTextureData;
import beardFramework.utils.libraries.StringLibrary;
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
		renderingBatch =  cast Renderer.Get().GetRenderable(StringLibrary.DEFAULT);
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
	
	override public function CastShadow(light:Light):Void 
	{
		super.CastShadow(light);
		//vertice0X = x + width * 0.5  + ((renderingBatch.vertices[0] * width) - width * 0.5) * rotationCosine -  ((renderingBatch.vertices[1] * height) - height * 0.5) * rotationSine;
	}

}

