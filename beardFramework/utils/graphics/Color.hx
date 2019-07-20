package beardFramework.utils.graphics;
import haxe.ds.Vector;

/**
 * ...
 * @author 
 */
abstract Color(UInt) from UInt to UInt
{

	public static inline var WHITE:UInt  = 0xffffffff;
    public static inline var SILVER:UInt  = 0xc0c0c0ff;
    public static inline var GRAY:UInt    = 0x808080ff;
    public static inline var BLACK:UInt   = 0x000000ff;
    public static inline var RED:UInt     = 0xff0000ff;
    public static inline var MAROON:UInt  = 0x800000ff;
    public static inline var YELLOW:UInt  = 0xffff00ff;
    public static inline var OLIVE:UInt   = 0x808000ff;
    public static inline var LIME:UInt    = 0x00ff00ff;
    public static inline var GREEN:UInt   = 0x008000ff;
    public static inline var AQUA:UInt    = 0x00ffffff;
    public static inline var TEAL:UInt    = 0x008080ff;
    public static inline var BLUE:UInt    = 0x0000ffff;
    public static inline var NAVY:UInt    = 0x000080ff;
    public static inline var FUCHSIA:UInt = 0xff00ffff;
    public static inline var PURPLE:UInt  = 0x800080ff;
    public static inline var CLEAR:UInt  = 0x80008000;

    
	inline function new(value:UInt) this = value;
	
	
    public inline function getAlphai():Int return this & 0xff;
    public inline function getRedi():Int  return (this >> 24) & 0xff;
    public inline function getGreeni():Int return (this >>  16) & 0xff;
    public inline function getBluei():Int return  (this >> 8)  & 0xff; 
 
   
	public inline function getAlphaf():Float return (this & 0xff)/255;
    public inline function getRedf():Float return ((this >> 24) & 0xff)/255; 
    public inline function getGreenf():Float return ((this >>  16) & 0xff)/255;
    public inline function getBluef():Float return  ((this >> 8)  & 0xff)/255; 

    public inline function setAlphai(alpha:Int):UInt return this = (this & 0xffffff00) | (alpha & 0xff);
    public inline function setRedi(red:Int):UInt return this = (this & 0x00ffffff) | (red & 0xff) << 24;
    public inline function setGreeni(green:Int):UInt return this = (this & 0xff00ffff) | (green & 0xff) << 16;
	public inline function setBluei(blue:Int):UInt return this = (this & 0xffff00ff) | (blue & 0xff) << 8;
	
	public inline function setAlphaf(alpha:Float):UInt return setAlphai(Std.int(alpha * 255));
    public inline function setRedf(red:Float):UInt return setRedi(Std.int(red * 255));
    public inline function setGreenf(green:Float):UInt return setGreeni(Std.int(green * 255));
	public inline function setBluef(blue:Float):UInt return setBluei(Std.int(blue * 255));
	
    public inline function fromRGBAi(red:Int, green:Int, blue:Int, alpha:Int):UInt return this = ((red << 24) | (green << 16) | (blue << 8) | (alpha ) ) ;
   	public inline function fromRGBAf(red:Float, green:Float, blue:Float, alpha:Float):UInt return fromRGBAi(Std.int(red*255),Std.int(green*255),Std.int(blue*255),Std.int(alpha*255)) ;

     public function toVector( out:Vector<Float>=null):Vector<Float>
    {
        if (out == null) out = new Vector<Float>(4);

        out[0] = ((this >> 24) & 0xff) / 255.0;
        out[1] = ((this >> 16) & 0xff) / 255.0;
        out[2] = ((this >> 8)  & 0xff) / 255.0;
        out[3] = ((this ) & 0xff) / 255.0;

        return out;
    }

   
    public function multiply( factor:Float):UInt
    {
        if (factor == 0.0) return 0x0;

        var alpha:UInt = Std.int(((this) & 0xff) * factor);
        var red:UInt   = Std.int(((this >> 24) & 0xff) * factor);
        var green:UInt = Std.int(((this >> 16) & 0xff) * factor);
        var blue:UInt  = Std.int(((this >>  8) & 0xff) * factor);

        if (alpha > 255) alpha = 255;
        if (red   > 255) red   = 255;
        if (green > 255) green = 255;
        if (blue  > 255) blue  = 255;

        return fromRGBAi(red, green, blue,alpha);
    }

    public function interpolate(endColor:UInt, ratio:Float):UInt
    {
        var startA:UInt = (this) & 0xff;
        var startR:UInt = (this >> 24) & 0xff;
        var startG:UInt = (this >> 16) & 0xff;
        var startB:UInt = (this >>  8) & 0xff;

        var endA:UInt = (endColor) & 0xff;
        var endR:UInt = (endColor >> 24) & 0xff;
        var endG:UInt = (endColor >> 16) & 0xff;
        var endB:UInt = (endColor >>  8) & 0xff;

        var newA:UInt = Std.int(startA + (endA - startA) * ratio);
        var newR:UInt = Std.int(startR + (endR - startR) * ratio);
        var newG:UInt = Std.int(startG + (endG - startG) * ratio);
        var newB:UInt = Std.int(startB + (endB - startB) * ratio);

        return (newR << 24) | (newG << 16) | (newB << 8) | newA;
    }
}