package beardFramework.interfaces;
import beardFramework.graphics.rendering.batches.BatchTemplateData;
import lime.graphics.opengl.GLProgram;

/**
 * @author 
 */
interface IBatch 
{
  	public var name(get, set):String;
	public var needUpdate:Bool;
	public var needOrdering:Bool;
	public var shaderProgram(default, null):GLProgram;
	public var cameras:List<String>;
	
	public function UpdateRenderedData():Void;
	public function IsEmpty():Bool;
	/**
	 * 
	 * @return the number of internal draw calls
	 */
	public function Render():Int;
	public function Init(batchData:BatchTemplateData):Void;
}