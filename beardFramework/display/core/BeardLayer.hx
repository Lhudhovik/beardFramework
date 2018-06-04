package beardFramework.display.core;
import beardFramework.display.rendering.VisualRenderer;
import beardFramework.resources.assets.AssetManager;
import beardFramework.utils.MinAllocArray;
import haxe.ds.Vector;

/**
 * ...
 * @author Ludo
 */
class BeardLayer
{
	public static var DEPTH_CONTENT:Float = -0.5;
	public static var DEPTH_UI:Float = 0;
	public static var DEPTH_LOADING:Float = 0.5;
	
	public var depth:Float; 
	public var maxVisualsCount(default, null):Int;
	public var name:String;
	@:isVar public var visible(get, set):Bool;
	public var visuals:Array<Visual>;
	public var dirtyVisuals:MinAllocArray<Int>;
	
	public function new(name:String, depth :Float, maxVisualsCount:Int=100000) 
	{
		this.name = name;
		this.depth = depth;
		this.maxVisualsCount = maxVisualsCount;
		visuals = new Array<Visual>();	
		dirtyVisuals = new MinAllocArray<Int>(50);
		visible = true;
		
	}

	public function Render ():Void 
	{
		/*
		if (!__renderable || __worldAlpha <= 0) return;
		
		var utilX:Float;
		var utilY:Float;
	
		renderSession.filterManager.pushObject (this);
		
		for (camera in BeardGame.Get().cameras.iterator()){
		
			renderSession.maskManager.pushRect (camera.GetRect(), camera.transform);
			
			for (child in __children) {
				
				if (Std.is(child, ICameraDependent) && camera.Contains(cast child)){
					cast(child, ICameraDependent).RenderThroughCamera(camera, renderSession);
					
				}else if (Std.is(child, ICameraDependent)){
					
						for (cam in cast(child, ICameraDependent).displayingCameras)
							if (cam == camera.name)
							{
								cast(child, ICameraDependent).displayingCameras.remove(camera.name);
								break;
							}
				}
				else {
					child.__renderGL (renderSession);
				}
			}
		
			renderSession.maskManager.popRect ();
		}
		
		for (orphan in __removedChildren) {
				
			if (orphan.stage == null) {
				
				orphan.__cleanup ();
				
			}
				
		}
		
		__removedChildren.length = 0;
		
		renderSession.filterManager.popObject (this);*/
		
		
		
	}
	
	public function RenderMask ():Void 
	{
		
		/*if (__cacheBitmap != null && !__cacheBitmapRender) return;
			
		
		for (camera in BeardGame.Get().cameras.iterator()){
			
			
			if (renderSession.clearRenderDirty) {
				
				for (child in __children) {
					
					
					if (Std.is(child, ICameraDependent) && camera.Contains(cast child)){
						cast(child, ICameraDependent).RenderMaskThroughCamera(camera, renderSession);
						child.__renderDirty = false;
					
					}else if (Std.is(child, ICameraDependent)){
					
						for (cam in cast(child, ICameraDependent).displayingCameras)
							if (cam == camera.name)
							{
								cast(child, ICameraDependent).displayingCameras.remove(camera.name);
								break;
							}
					}
					else {
						child.__renderGLMask (renderSession);
						child.__renderDirty = false;
					}
					
					
				
					
				}
				
				__renderDirty = false;
				
			} else {
				
				for (child in __children) {
					
					if (Std.is(child, ICameraDependent) && camera.Contains(cast child)){
						cast(child, ICameraDependent).RenderMaskThroughCamera(camera, renderSession);
									
					}else if (Std.is(child, ICameraDependent)){
					
						for (cam in cast(child, ICameraDependent).displayingCameras)
							if (cam == camera.name)
							{
								cast(child, ICameraDependent).displayingCameras.remove(camera.name);
								break;
							}
					}
					else {
						child.__renderGLMask (renderSession);
						
					}
					
					
				}
				
			}
			
			
			
		}
		
		for (orphan in __removedChildren) {
			
			if (orphan.stage == null) {
				
				orphan.__cleanup ();
				
			}
			
		}
		
		__removedChildren.length = 0;
		*/
		
	}
	
	public function VisualHitTest(x:Float, y:Float):Bool
	{
		
		
		return true;
	}
	
	public function AddMultiple(visuals:Array<Visual>):Void
	{
		
		for (i in 0...visuals.length)
			Add(visuals[i], false);
			
		VisualRenderer.Get().UpdateBufferFromVisuals(visuals);
		
		
	}
	
	public function AddMultipleOpti(addedVisuals:MinAllocArray<Visual>, updateBuffer:Bool = true):Void
	{
		var visual:Visual;
		for (i in 0...addedVisuals.length){
			
			visual = addedVisuals.get(i);
			if (visuals.indexOf(visual) == -1)
			{
			
				visual.layer = this;
				visual.z = (visual.z ==-1) ? visuals.length : visual.z;
				visual.visible = this.visible;
				visual.bufferIndex =  VisualRenderer.Get().GetFreeBufferIndex();
				visuals.push(visual);
				
				AddVisualDirty(visual);
			}
	
		}
		
		if(updateBuffer)
			VisualRenderer.Get().UpdateBufferFromLayer(this);
		
		
	}
	
	public function Add(visual:Visual, updateBuffer:Bool = true):Void
	{
		
		if (visuals.indexOf(visual) == -1)
		{
			
			visual.layer = this;
			visual.z = (visual.z ==-1) ? visuals.length : visual.z;
			visual.visible = this.visible;
			visual.bufferIndex =  VisualRenderer.Get().GetFreeBufferIndex();
			
			visuals.push(visual);
		
			if (updateBuffer)
				VisualRenderer.Get().UpdateBufferFromVisuals([visual]);
			
		}
	}
		
	public inline function Remove(visual:Visual):Void
	{
		if (visuals.indexOf(visual) != -1)
		{
			visuals.remove(visual);
			
			visual.bufferIndex = VisualRenderer.Get().FreeBufferIndex(visual.bufferIndex);
		}
	}
	
	function get_visible():Bool 
	{
		return visible;
	}
	
	function set_visible(value:Bool):Bool 
	{
		
		for (visual in visuals)
			visual.visible = value;
		return visible = value;
	}
	
	public inline function AddVisualDirty(visual:Visual):Void
	{
		
		if (dirtyVisuals.IndexOf(visuals.indexOf(visual)) == -1)
		{
			dirtyVisuals.Push(visuals.indexOf(visual));
		}
		
		
	}
	
	public inline function PrepareForRendering():Void
	{
		VisualRenderer.Get().UpdateBufferFromVisuals(visuals);
	}

}


enum BeardLayerType
{
	CONTENT;
	UI;
	LOADING;
	
}