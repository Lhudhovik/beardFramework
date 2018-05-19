package beardFramework.display.rendering;
import beardFramework.display.core.Visual;
import beardFramework.resources.assets.AssetManager;
import beardFramework.utils.VertexAttributeUtils;
import lime.app.Application;
import lime.graphics.opengl.GL;
import lime.graphics.opengl.GLBuffer;
import lime.graphics.opengl.GLES3Context;
import lime.graphics.opengl.GLProgram;
import lime.graphics.opengl.GLShader;
import lime.graphics.opengl.GLVertexArrayObject;
import lime.utils.Float32Array;
import lime.utils.UInt16Array;


/**
 * ...
 * @author 
 */
class VisualRenderer 
{
	
	private static var instance:VisualRenderer;
	//public static var isReady:Bool = false;
	public var quadVertices:Float32Array;
	public var verticesIndices:UInt16Array;	
	
	private var EBO:GLBuffer;
	private var VBO:GLBuffer;
	private var TBO:GLBuffer;
	private var Transforms:Float32Array;
	private var VAO:GLVertexArrayObject;
	private var shaderProgram:GLProgram;
	private var ready:Bool = false;
	
	private function new()
	{
		
	}
	
	public static inline function Get():VisualRenderer
	{
		if (instance == null)
		{
			instance = new VisualRenderer();
			instance.Init();
		}
		
		return instance;
	}
	
	private function Init():Void
	{
		GL.viewport(0, 0, Application.current.window.width, Application.current.window.height);
	
		Shaders.LoadShaders();
		
		var vShader:GLShader = GL.createShader(GL.VERTEX_SHADER);
		GL.shaderSource(vShader, Shaders.shader["vertexShader"]);
		GL.compileShader(vShader);
				
		var fShader:GLShader = GL.createShader(GL.FRAGMENT_SHADER);
		GL.shaderSource(fShader, Shaders.shader["fragmentShader"]);
		GL.compileShader(fShader);
			
		
		
		shaderProgram = GL.createProgram();
		GL.attachShader(shaderProgram, vShader);
		GL.attachShader(shaderProgram, fShader);
		GL.linkProgram(shaderProgram);
			
		
		GL.deleteShader(vShader);
		GL.deleteShader(fShader);
		
		//quadVertices = new Float32Array(null, [ 
		////x		y	 	uvX		uvY	new uv
		//-1.0,	1.0,	0.0,	0.0, 0.7890625,0.45068359375, 0.03955078,0.05761718,
        //1.0, 	1.0, 	1.0,	0.0,0.7890625,0.45068359375, 0.03955078,0.05761718,
        //1.0, 	-1.0,	1.0,    1.0,0.7890625,0.45068359375, 0.03955078,0.05761718,
        //-1.0,	-1.0,	0.0,	1.0,0.7890625,0.45068359375, 0.03955078,0.05761718
		//]);
		
		quadVertices = new Float32Array(null, [ 
		//x		y	 	uvX		uvY	new uv
		-0.5,	0.5,	0.0,	0.0, 0.7890625,0.45068359375, 0.03955078,0.05761718,
        0.5, 	0.5, 	1.0,	0.0,0.7890625,0.45068359375, 0.03955078,0.05761718,
        0.5, 	-0.5,	1.0,    1.0,0.7890625,0.45068359375, 0.03955078,0.05761718,
        -0.5,	-0.5,	0.0,	1.0,0.7890625,0.45068359375, 0.03955078,0.05761718
		]);
		//quadVertices = new Float32Array(null, [ 
		////x		y	 	uvX		uvY
		//-1.0,	1.0,	0.7890625,	0.45068359375,
        //1.0, 	1.0, 	0.8286132,	0.45068359375,
        //1.0, 	-1.0,	0.8286132,   0.50830078125,
        //-1.0,	-1.0,	0.7890625,	0.50830078125
		//]);
		//
		verticesIndices = new UInt16Array(null, [0, 1, 2, 2, 3, 0]);
	
		VAO = GLObject.fromInt(GLObjectType.VERTEX_ARRAY_OBJECT, 1);
		VBO = GLObject.fromInt(GLObjectType.BUFFER, 1);
		EBO = GLObject.fromInt(GLObjectType.BUFFER, 2);
		
		TBO = GLObject.fromInt(GLObjectType.BUFFER, 3);
		//Instances stuff
		//var iBuffer:GLBuffer =  GLObject.fromInt(GLObjectType.BUFFER, 3);
		//var visual:Visual = new Visual("facebook_button_over_fr_hd", "menuHD");
		//visual.color = 0x55ffff;
		//
		//var data:Float32Array = VertexAttributeUtils.GenerateVertexAttributesFromVisual(visual);
		//
		//GL.bindBuffer(GL.ARRAY_BUFFER, iBuffer);
		//GL.bufferData(GL.ARRAY_BUFFER, data.byteLength, data , GL.DYNAMIC_DRAW);
		GL.bindBuffer(GL.ARRAY_BUFFER, 0);
		var tab:Array<Float> =[];
		//for (i in 0...5000)
			//tab = tab.concat([ 
		////x		y	 	uvX		uvY	new uv
		//-0.5,	i/5000,	0.0,	0.0, 0.7890625,0.45068359375, 0.03955078,0.05761718,
        //0.5, 	0.5, 	1.0,	0.0,0.7890625,0.45068359375, 0.03955078,0.05761718,
        //0.5, 	-0.5,	1.0,    1.0,0.7890625,0.45068359375, 0.03955078,0.05761718,
        //-0.5,	-0.5,	0.0,	1.0,0.7890625,0.45068359375, 0.03955078,0.05761718
		//]);
		//
		//quadVertices = new Float32Array(tab) ;
		trace(tab);
		
		
		//var tab2:Array<Int> = [];
		//for (i in 0...5000)
			//tab2 = tab2.concat([ 0 * (i+1), 1 * (i+1), 2* (i+1), 2* (i+1), 3* (i+1), 0* (i+1)]);
		//normal thing
		
		//verticesIndices = new UInt16Array(tab2);
		GL.bindVertexArray(VAO);
		
		GL.bindBuffer(GL.ARRAY_BUFFER, VBO);
		GL.bufferData(GL.ARRAY_BUFFER, quadVertices.byteLength, quadVertices, GL.STATIC_DRAW);
		
			//to do, create attributes "templates"
		GL.enableVertexAttribArray(0);
		//GL.vertexAttribPointer(0, 2, GL.FLOAT, false, 4 * Float32Array.BYTES_PER_ELEMENT, 0);
		GL.vertexAttribPointer(0, 2, GL.FLOAT, false, 8 * Float32Array.BYTES_PER_ELEMENT, 0);
		
		GL.enableVertexAttribArray(1);
		GL.vertexAttribPointer(1, 2, GL.FLOAT, false, 8 * Float32Array.BYTES_PER_ELEMENT, 2 * Float32Array.BYTES_PER_ELEMENT);

		GL.enableVertexAttribArray(2);
		GL.vertexAttribPointer(2, 4, GL.FLOAT, false, 8 * Float32Array.BYTES_PER_ELEMENT, 4 * Float32Array.BYTES_PER_ELEMENT);

		
		GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, EBO);
		GL.bufferData(GL.ELEMENT_ARRAY_BUFFER,verticesIndices.byteLength, verticesIndices, GL.DYNAMIC_DRAW);
		
		GL.bindBuffer(GL.ARRAY_BUFFER, TBO);
		
		Transforms = new Float32Array([for (i in 0...20000) Math.random() ]);
		trace(Transforms);
		GL.bufferData(GL.ARRAY_BUFFER, Transforms.byteLength, Transforms, GL.DYNAMIC_DRAW);
		GL.enableVertexAttribArray(3);
		GL.vertexAttribPointer(3, 1, GL.FLOAT, false, Float32Array.BYTES_PER_ELEMENT, 0);

		
		
		////new position
		//GL.enableVertexAttribArray(2);
		//GL.bindBuffer(GL.ARRAY_BUFFER, iBuffer);
		//GL.vertexAttribPointer(2, 2, GL.FLOAT, false, 10 * Float32Array.BYTES_PER_ELEMENT,0);
		//GL.bindBuffer(GL.ARRAY_BUFFER, 0);
		//GL.vertexAttribDivisor(2, 1);
		//color
		//GL.enableVertexAttribArray(3);
		//GL.bindBuffer(GL.ARRAY_BUFFER, iBuffer);
		//GL.vertexAttribPointer(3, 4, GL.FLOAT, false, 10 * Float32Array.BYTES_PER_ELEMENT,2*Float32Array.BYTES_PER_ELEMENT);
		//GL.bindBuffer(GL.ARRAY_BUFFER, 0);
		//GL.vertexAttribDivisor(3, 1);
		//new UV
		//GL.enableVertexAttribArray(4);
		//GL.bindBuffer(GL.ARRAY_BUFFER, iBuffer);
		//GL.vertexAttribPointer(4, 4, GL.FLOAT, false, 10 * Float32Array.BYTES_PER_ELEMENT, 4 * Float32Array.BYTES_PER_ELEMENT);
		//GL.bindBuffer(GL.ARRAY_BUFFER, 0);
		//GL.vertexAttribDivisor(4, 1);
		//
		
		
		GL.bindBuffer(GL.ARRAY_BUFFER, 0);
			GL.vertexAttribDivisor(0,0);
			GL.vertexAttribDivisor(1, 0);
		GL.vertexAttribDivisor(2, 0);
		GL.vertexAttribDivisor(3, 1);
		GL.bindVertexArray(0);
	
		trace("context version : " + GL.context.version);
		
		//isReady =  true;
		
	}
	
	public function Render():Void
	{
		if (ready)
		{
			GL.clearColor(0.2, 0.3, 0.3, 1);
			GL.clear(GL.COLOR_BUFFER_BIT);
			
			GL.clear(GL.DEPTH_BUFFER_BIT);
			//GL.activeTexture(GL.TEXTURE0);
			//GL.bindTexture(GL.TEXTURE_2D, AssetManager.Get().GetAtlas("menuHD").texture);
			
			GL.useProgram(shaderProgram);
			GL.bindVertexArray(VAO);
			//for(i in 0...50000)
			//GL.drawElements(GL.TRIANGLES,5000,GL.UNSIGNED_SHORT,0);
			//var glcontext:GLES3Context = GL.context;
			//glcontext.drawElementsInstanced(GL.TRIANGLES,6,GL.UNSIGNED_SHORT,0,500);
			GL.drawElementsInstanced(GL.TRIANGLES,6,GL.UNSIGNED_SHORT,0,500);
			//GL.drawArrays(GL.TRIANGLES, 0,5000);
			//GL.drawArraysInstanced(GL.TRIANGLES, 0, 6, 200);
		
			GL.bindVertexArray(0);
			//var error:Int = GL.getError();
			//trace(error);
			trace(Transforms[Math.round(Math.random()*Transforms.length-1)] = Math.random());
		}
		
		
			
	}
	
	public inline function ActivateTexture():Void
	{
		GL.useProgram(shaderProgram);
		GL.uniform1i(GL.getUniformLocation(shaderProgram, "atlas"), 0);
	}
	
	public function Test():Void
	{
		ready = true;
		//GL.bindVertexArray(VAO);
		//var visual:Visual = new Visual("button_help_normal", "menuHD");
		//visual.color = 0x55ffff;
		//
		//var data:Float32Array = VertexAttributeUtils.GenerateVertexAttributesFromVisual(visual);
		//
		//var iBuffer:GLBuffer =  GLObject.fromInt(GLObjectType.BUFFER, 3);
		//GL.bindBuffer(GL.ARRAY_BUFFER, iBuffer);
		//GL.bufferData(GL.ARRAY_BUFFER, data.byteLength, data , GL.DYNAMIC_DRAW);
		//
			////new position
		//GL.enableVertexAttribArray(2);
		//GL.bindBuffer(GL.ARRAY_BUFFER, iBuffer);
		//GL.vertexAttribPointer(2, 2, GL.FLOAT, false, 10 * Float32Array.BYTES_PER_ELEMENT,0);
		//GL.bindBuffer(GL.ARRAY_BUFFER, 0);
		////GL.vertexAttribDivisor(2, 1);
		////color
		//GL.enableVertexAttribArray(3);
		//GL.bindBuffer(GL.ARRAY_BUFFER, iBuffer);
		//GL.vertexAttribPointer(3, 4, GL.FLOAT, false, 10 * Float32Array.BYTES_PER_ELEMENT,2*Float32Array.BYTES_PER_ELEMENT);
		//GL.bindBuffer(GL.ARRAY_BUFFER, 0);
		////GL.vertexAttribDivisor(3, 1);
		////new UV
		//GL.enableVertexAttribArray(4);
		//GL.bindBuffer(GL.ARRAY_BUFFER, iBuffer);
		//GL.vertexAttribPointer(4, 4, GL.FLOAT, false, 10 * Float32Array.BYTES_PER_ELEMENT, 4 * Float32Array.BYTES_PER_ELEMENT);
		//GL.bindBuffer(GL.ARRAY_BUFFER, 0);
		//GL.vertexAttribDivisor(4, 1);
	}
}