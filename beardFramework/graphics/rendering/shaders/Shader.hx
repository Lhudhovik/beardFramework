package beardFramework.graphics.rendering.shaders;
import beardFramework.core.BeardGame;
import beardFramework.utils.data.Crypto;
import beardFramework.utils.libraries.StringLibrary;
import lime.graphics.opengl.GL;
import lime.graphics.opengl.GLProgram;
import lime.graphics.opengl.GLShader;
import lime.math.Matrix4;
import mloader.Loader.LoaderEvent;
import sys.FileSystem;
import sys.io.File;

/**
 * ...
 * @author 
 */
class Shader 
{
	
	static public var nativeShader:Map<String,String> = new Map<String,String>();
	static public var loaded:Bool= false;
	
	static public function LoadShaders():Void
	{
		
		if (!loaded && FileSystem.exists(BeardGame.Get().SHADERS_PATH))
		{
			for (element in FileSystem.readDirectory(BeardGame.Get().SHADERS_PATH))
			{
				if (element.indexOf(StringLibrary.SHADER_EXTENSION) != -1){
					
					
					#if debug
					nativeShader[cast(element, String).split(".")[0]] =  File.getContent(BeardGame.Get().SHADERS_PATH + element);
					#else
					nativeShader[cast(element, String).split(".")[0]] =  Crypto.DecodedData(File.getContent(BeardGame.Get().SHADERS_PATH + element));	
					#end
					
					//trace(shader[cast(element, String).split(".")[0]]);
					//trace(shader);
				}
			}
			loaded = true;
		}
		
			
	}
	
	static public function CreateShader(shadersList:Array<Shader.NativeShader>):Shader
	{
		var shader:Shader = new Shader();
		
		var createdShaders:Array<GLShader> = [];
		for (nativeShader in shadersList)
		{
			
			var glShader:GLShader =  GL.createShader(nativeShader.type);
			
			GL.shaderSource(glShader, Shader.nativeShader[nativeShader.name]);
			
			GL.compileShader(glShader);
			trace(nativeShader.name + " :\n" + GL.getShaderInfoLog(glShader));
			
			createdShaders.push(glShader);
			
			GL.attachShader(shader.program, glShader);
			trace(GL.getProgramInfoLog(shaderProgram ));
			
			
		}
						
		
		GL.linkProgram(shader.program);
		trace(GL.getProgramInfoLog(shader.program));

		for (nativeShader in createdShaders)
		{
			GL.deleteShader(nativeShader);
		}
		
		
		
		
	}
	
	
	public var program(default, null):GLProgram;
	public var uniformLocations(default, null):Map<String, Int>;
	
	private function new()
	{
		program = GL.createProgram();
		trace(GL.getProgramInfoLog(program ));
		
		uniformLocations = new Map<String,Int>();
	}
	
	
	public inline function Use():Void
	{
		GL.useProgram(program);
		trace(GL.getError());
	}
	
	public function SetInt(name:String, value:Int):Void
	{
		if (uniformLocations[name] == null) uniformLocations[name] = GL.getUniformLocation(program, name);
		GL.uniform1i(uniformLocations[name], value);			

	}
	
	public function SetFloat(name:String, value:Float):Void
	{
		if (uniformLocations[name] == null) uniformLocations[name] = GL.getUniformLocation(program, name);
		GL.uniform1f(uniformLocations[name], value);			

	}
	
	public function Set2Int(name:String, value1:Int, value2:Int):Void
	{
		if (uniformLocations[name] == null) uniformLocations[name] = GL.getUniformLocation(program, name);
		GL.uniform2i(uniformLocations[name], value1, value2);
		
	}
	
	public function Set2Float(name:String, value1:Float, value2:Float):Void
	{
		if (uniformLocations[name] == null) uniformLocations[name] = GL.getUniformLocation(program, name);
		GL.uniform2f(uniformLocations[name], value1, value2);
	}
	
	public function Set3Int(name:String, value1:Int, value2:Int, value3:Int):Void
	{
		if (uniformLocations[name] == null) uniformLocations[name] = GL.getUniformLocation(program, name);
		GL.uniform3i(uniformLocations[name], value1, value2, value3);
	}
	
	public function Set3Float(name:String, value1:Float, value2:Float, value3:Float):Void
	{
		if (uniformLocations[name] == null) uniformLocations[name] = GL.getUniformLocation(program, name);
		GL.uniform3f(uniformLocations[name], value1, value2, value3);
	}
	
	public function Set4Int(name:String, value1:Int, value2:Int, value3:Int,value4:Int ):Void
	{
		if (uniformLocations[name] == null) uniformLocations[name] = GL.getUniformLocation(program, name);
		GL.uniform4i(uniformLocations[name], value1, value2, value3, value4);
	}
		
	public function Set4Float(name:String, value1:Float, value2:Float, value3:Float,value4:Float ):Void
	{
		if (uniformLocations[name] == null) uniformLocations[name] = GL.getUniformLocation(program, name);
		GL.uniform4f(uniformLocations[name], value1, value2, value3, value4);
	}
	
	public function SetMatrix4fv(name:String, value:Matrix4 ):Void
	{
		if (uniformLocations[name] == null) uniformLocations[name] = GL.getUniformLocation(program, name);
		GL.uniformMatrix4fv(uniformLocations[name], 1, false, value);
		
	}
	
	
	
	
}

typedef NativeShader =
{
	public var name:String;
	public var type:Int;
}
