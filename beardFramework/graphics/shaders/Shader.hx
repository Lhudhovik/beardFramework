package beardFramework.graphics.shaders;
import beardFramework.core.BeardGame;
import beardFramework.resources.options.OptionsManager.ShaderToCreate;
import beardFramework.utils.data.Crypto;
import beardFramework.utils.graphics.GLU;
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
	
	static public var nativeShaders:Map<String,NativeShader> = new Map<String,NativeShader>();
	static public var loaded:Bool = false;
	
	static private var currentUsed:Shader;
	static private var instanceCount:Int = 0;
	static private var shaders:Map<String, Shader> = new Map<String, Shader>();
	
	
	static public function LoadShaders(shadersToCreate:Array<ShaderToCreate>):Void
	{
		
		for (shaderToCreate in shadersToCreate)
		{
			shaders[shaderToCreate.name] = CreateShader(shaderToCreate.nativeShaders,shaderToCreate.name);
		}
	}
	
	static public inline function GetShader(name:String):Shader
	{
		return shaders[name];
	}
	
	static public inline function GetShaderName(shader:Shader):String
	{
		var name:String="";
		for (key in shaders.keys())
		{
			if (shaders[key] == shader){
				name = key;
				break;
			}
		}
		return name;
	}
	
	static public inline function AddShader(name:String, shader:Shader):Shader
	{
		shaders[name] = shader;
		return shaders[name];
	}
	
	static public inline function RemoveShader(name:String, destroy:Bool = false):Void
	{
		
		if (shaders[name] != null) 
		{
			if (destroy) GL.deleteProgram(shaders[name].program);
			shaders[name] = null;
		}
		
	}
	
	static public function CreateShader(nativeShadersList:Array<String>, name:String = ""):Shader
	{
		instanceCount++; 
		var shader:Shader = new Shader(name);
		var error:String = null;
		var createdShaders:Array<GLShader> = [];
		for (nativeName in nativeShadersList)
		{
			
			var glShader:GLShader =  GL.createShader(nativeShaders[nativeName].type);
			
			
			GL.shaderSource(glShader, nativeShaders[nativeName].src);
			
			GL.compileShader(glShader);
			error = GL.getShaderInfoLog(glShader);
			if(error != null) 	trace(nativeName + " : " + error);
			
			createdShaders.push(glShader);
			
			GL.attachShader(shader.program, glShader);
			error = GL.getProgramInfoLog(shader.program );
			if(error != null) trace(error);
			
			
		}
						
		
		GL.linkProgram(shader.program);
		error = GL.getProgramInfoLog(shader.program);
		if(error != null) trace(error);
				
		for (nativeShader in createdShaders)
		{
			GL.deleteShader(nativeShader);
		}
		
		return shader;
		
		
	}
	
	
	public var program(default, null):GLProgram;
	public var isUsed(default, null):Bool;
	public var uniformLocations(default, null):Map<String, Int>;
	public var name:String; 
	private function new(name:String = "")
	{
		program = GL.createProgram();
		var info:String = GL.getProgramInfoLog(program );
		if(info != null) trace(info);
		isUsed = false;
		uniformLocations = new Map<String,Int>();
		
		if (name == "") this.name = StringLibrary.SHADER + instanceCount;
		else this.name = name;
	}
	
	
	public inline function Use():Void
	{
		
		if (isUsed == false)
		{
			if (currentUsed != null) currentUsed.isUsed = false;		
			currentUsed = this;
			isUsed = true;
		
			GL.useProgram(program);
			GLU.ShowErrors("Shader Error when trying to use " + this.name);
		}
		
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
	public var src:String;
	public var type:Int;
}
