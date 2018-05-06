package beardFramework.display.core;

/**
 * ...
 * @author Ludo
 */
class RenderChannel 
{
	private var atlas:String;
	public function new() 
	{
		
	}
	
	 public function isStateChange(tinted:Bool, parentAlpha:Float, texture:Texture, 
                                  smoothing:String, blendMode:String, numQuads:Int=1):Bool
    {
        if (mNumQuads == 0) return false;
        else if (mNumQuads + numQuads > MAX_NUM_QUADS) return true; // maximum buffer size
        else if (mTexture == null && texture == null) 
            return this.blendMode != blendMode;
        else if (mTexture != null && texture != null)
            return mTexture.base != texture.base ||
                   mTexture.repeat != texture.repeat ||
                   mSmoothing != smoothing ||
                   mTinted != (mForceTinted || tinted || parentAlpha != 1.0) ||
                   this.blendMode != blendMode;
        else return true;
    }
}