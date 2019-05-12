package beardFramework.utils.math;
import lime.math.Matrix4;
import lime.math.Vector4;
/**
 * ...
 * @author 
 */
class MatrixExtension 
{
	static private var endRow:Vector4 = new Vector4(0,0,0,1);
	static public function lookAt(matrix:Matrix4, pos:Vector4, target:Vector4, up:Vector4 = null ):Void
	{
		
		
		var tmp:Vector4 = new Vector4(0, 1, 0);
		tmp.normalize();
		var forward:Vector4 = pos.subtract(target);
		forward.normalize();
		
		var right:Vector4 = tmp.crossProduct(forward);
		
		up = forward.crossProduct(right);
		
		matrix[0] = right.x;
		matrix[4] = right.y;
		matrix[8] = right.z;
		//matrix[12] = -xAxis.dotProduct(pos);
		matrix[1] = up.x;
		matrix[5] = up.y;
		matrix[9] = up.z;
		//matrix[13] = -yAxis.dotProduct(pos);
		matrix[2] = forward.x;
		matrix[6] = forward.y;
		matrix[10] = forward.z;
		//matrix[14] = -zAxis.dotProduct(pos);
		matrix[3] = pos.x;
		matrix[7] = pos.y;
		matrix[11] = pos.z;
		//matrix[15] = endRow.w;
		
		//matrix.invert();
		//if (up == null) up = new Vector4(0, 1, 0);
		//up.normalize();
		//
		//var zAxis : Vector4 = pos.clone();
		//zAxis.decrementBy(target);
		//zAxis.normalize();
		//
		//var xAxis:Vector4 = zAxis.crossProduct(up);
		//xAxis.normalize();
		//var yAxis:Vector4 = xAxis.crossProduct(zAxis);
		//yAxis.normalize();
			//
		//matrix[0] = xAxis.x;
		//matrix[4] = xAxis.y;
		//matrix[8] = xAxis.z;
		//matrix[12] = -xAxis.dotProduct(pos);
		//matrix[1] = yAxis.x;
		//matrix[5] = yAxis.y;
		//matrix[9] = yAxis.z;
		//matrix[13] = -yAxis.dotProduct(pos);
		//matrix[2] = zAxis.x;
		//matrix[6] = zAxis.y;
		//matrix[10] = zAxis.z;
		//matrix[14] = -zAxis.dotProduct(pos);
		//matrix[3] = endRow.x;
		//matrix[7] = endRow.y;
		//matrix[11] = endRow.z;
		//matrix[15] = endRow.w;
		
		//var forward : Vector4 = pos.subtract(target);
		//forward.normalize();
	//
		//up = new Vector4(0, 1, 0);
		////up.normalize();
		//
		//var right:Vector4 = up.crossProduct(forward);
		//right.normalize();
		//
		//up = forward.crossProduct(right);
		//
		//
		//matrix.identity();
		//
		//matrix[0] = right.x;
		//matrix[4] = right.y;
		//matrix[8] = right.z;
		////matrix[12] = 0;
		//matrix[12] = -(right.dotProduct(target));
		////matrix[12] = -right.x * pos.x - right.y*pos.y - right.z * pos.z;
		//matrix[1] = up.x;
		//matrix[5] = up.y;
		//matrix[9] = up.z;
		////matrix[13] = 0;
		//matrix[13] = -(up.dotProduct(target));
		////matrix[13] =  -up.x * pos.x - up.y*pos.y - up.z * pos.z;
		//matrix[2] = -forward.x;
		//matrix[6] = -forward.y;
		//matrix[10] = -forward.z;
		////matrix[14] = 0;
		//matrix[14] = -(forward.dotProduct(target));
		////matrix[14] =  -forward.x * pos.x - forward.y*pos.y - forward.z * pos.z;
		//matrix[3] = 0;
		//matrix[7] = 0;
		//matrix[11] = 0;
		//matrix[15] = 1;
		////
		
		
	}
	
	static public function createPerspective(matrix:Matrix4, width:Int, height:Int, fov:Float, near:Float, far:Float ):Void
	{
		var aspectRatio:Float = width / height;
			
		var d : Float = 1 / Math.tan(fov / 2);
		
		matrix[0] = d/aspectRatio;	matrix[1] = 0;			matrix[2] = 0;							matrix[3] = 0;
		matrix[4] = 0;				matrix[5] = d;			matrix[6] = 0;							matrix[7] = 0;
		matrix[8] = 0;				matrix[9] = 0;			matrix[10] = (near+far)/(near-far);		matrix[11] = (2*far*near)/(near-far);
		matrix[12] = 0;				matrix[13] = 0;			matrix[14] = -1;						matrix[15] = 0;
		
		
		//var aspectRatio:Float = width / height;
		//
		//var top:Float = Math.tan(fov / 2) * near;
		//var right:Float = top * aspectRatio;
		//var bottom:Float = -top;
		//var left:Float = -top * aspectRatio;
		//
		//matrix[0] = (2* near)/(right - left);
		//matrix[1] = 0;
		//matrix[2] = (right + left)/(right-left);
		//matrix[3] = 0;
		//matrix[4] = 0;
		//matrix[5] = (2*near)/(top-bottom);
		//matrix[6] = (top+bottom)/(top-bottom);
		//matrix[7] = 0;
		//matrix[8] = 0;
		//matrix[9] = 0;
		//matrix[10] = -(far+near)/(far-near);
		//matrix[11] = -(2*far*near)/(far-near);
		//matrix[12] = 0;
		//matrix[13] = 0;
		//matrix[14] = -1;
		//matrix[15] = 0;
		
		
	}
}