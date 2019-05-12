package beardFramework.utils.math;
import lime.math.Matrix4;
import lime.math.Vector4;
/**
 * ...
 * @author 
 */
class MatrixExtension 
{
	static private var up:Vector4 = new Vector4(0, 1, 0);
	static private var endRow:Vector4 = new Vector4(0,0,0,1);
	static public function lookAt(matrix:Matrix4, pos:Vector4, target:Vector4):Void
	{
		
		up.normalize();
		
		var zAxis : Vector4 = pos.clone();
		zAxis.decrementBy(target);
		zAxis.normalize();
		
		var xAxis:Vector4 = zAxis.crossProduct(up);
		var yAxis:Vector4 = xAxis.crossProduct(zAxis);
			
		matrix[0] = xAxis.x;
		matrix[4] = xAxis.y;
		matrix[8] = xAxis.z;
		matrix[12] = -xAxis.dotProduct(pos);
		matrix[1] = yAxis.x;
		matrix[5] = yAxis.y;
		matrix[9] = yAxis.z;
		matrix[13] = -yAxis.dotProduct(pos);
		matrix[2] = zAxis.x;
		matrix[6] = zAxis.y;
		matrix[10] = zAxis.z;
		matrix[14] = -zAxis.dotProduct(pos);
		matrix[3] = endRow.x;
		matrix[7] = endRow.y;
		matrix[11] = endRow.z;
		matrix[15] = endRow.w;
		
	}
	
	static public function createPerspective(matrix:Matrix4, width:Int, height:Int, fov:Float, near:Float, far:Float ):Void
	{
		var aspectRatio:Float = width / height;
		
		var top:Float = Math.tan(fov / 2) * near;
		var right:Float = top * aspectRatio;
		var bottom:Float = -top;
		var left:Float = -top * aspectRatio;
		
		matrix[0] = (2* near)/(right - left);
		matrix[1] = 0;
		matrix[2] = (right + left)/(right-left);
		matrix[3] = 0;
		matrix[4] = 0;
		matrix[5] = (2*near)/(top-bottom);
		matrix[6] = (top+bottom)/(top-bottom);
		matrix[7] = 0;
		matrix[8] = 0;
		matrix[9] = 0;
		matrix[10] = -(far+near)/(far-near);
		matrix[11] = -(2*far*near)/(far-near);
		matrix[12] = 0;
		matrix[13] = 0;
		matrix[14] = -1;
		matrix[15] = 0;
		
		
	}
}