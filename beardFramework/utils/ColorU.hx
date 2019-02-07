package beardFramework.utils;
import haxe.ds.Vector;

/**
 * ...
 * @author 
 */
class ColorU 
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

    
    public static function getAlpha(color:UInt):Int { return color & 0xff; }

   
    public static function getRed(color:UInt):Int   { return (color >> 24) & 0xff; }

    
    public static function getGreen(color:UInt):Int { return (color >>  16) & 0xff; }

   
    public static function getBlue(color:UInt):Int  { return  (color >> 8)  & 0xff; }

   
    public static function setAlpha(color:UInt, alpha:Int):UInt
    {
        return (color & 0x00ffffff) | (alpha & 0xff) << 24;
    }

   
    public static function setRed(color:UInt, red:Int):UInt
    {
        return (color & 0xff00ffff) | (red & 0xff) << 16;
    }

   
    public static function setGreen(color:UInt, green:Int):UInt
    {
        return (color & 0xffff00ff) | (green & 0xff) << 8;
    }

 
    public static function setBlue(color:UInt, blue:Int):UInt
    {
        return (color & 0xffffff00) | (blue & 0xff);
    }

    public static function rgb(red:Int, green:Int, blue:Int):UInt
    {
        return (red << 16) | (green << 8) | blue;
    }

    
    public static function argb(alpha:Int, red:Int, green:Int, blue:Int):UInt
    {
        return (alpha << 24) | (red << 16) | (green << 8) | blue;
    }

      public static function toVector(color:UInt, out:Vector<Float>=null):Vector<Float>
    {
        if (out == null) out = new Vector<Float>(4);

        out[0] = ((color >> 16) & 0xff) / 255.0;
        out[1] = ((color >>  8) & 0xff) / 255.0;
        out[2] = ( color        & 0xff) / 255.0;
        out[3] = ((color >> 24) & 0xff) / 255.0;

        return out;
    }

   
    public static function multiply(color:UInt, factor:Float):UInt
    {
        if (factor == 0.0) return 0x0;

        var alpha:UInt = Std.int(((color >> 24) & 0xff) * factor);
        var red:UInt   = Std.int(((color >> 16) & 0xff) * factor);
        var green:UInt = Std.int(((color >>  8) & 0xff) * factor);
        var blue:UInt  = Std.int(( color        & 0xff) * factor);

        if (alpha > 255) alpha = 255;
        if (red   > 255) red   = 255;
        if (green > 255) green = 255;
        if (blue  > 255) blue  = 255;

        return argb(alpha, red, green, blue);
    }

    public static function interpolate(startColor:UInt, endColor:UInt, ratio:Float):UInt
    {
        var startA:UInt = (startColor >> 24) & 0xff;
        var startR:UInt = (startColor >> 16) & 0xff;
        var startG:UInt = (startColor >>  8) & 0xff;
        var startB:UInt = (startColor      ) & 0xff;

        var endA:UInt = (endColor >> 24) & 0xff;
        var endR:UInt = (endColor >> 16) & 0xff;
        var endG:UInt = (endColor >>  8) & 0xff;
        var endB:UInt = (endColor      ) & 0xff;

        var newA:UInt = Std.int(startA + (endA - startA) * ratio);
        var newR:UInt = Std.int(startR + (endR - startR) * ratio);
        var newG:UInt = Std.int(startG + (endG - startG) * ratio);
        var newB:UInt = Std.int(startB + (endB - startB) * ratio);

        return (newA << 24) | (newR << 16) | (newG << 8) | newB;
    }
}