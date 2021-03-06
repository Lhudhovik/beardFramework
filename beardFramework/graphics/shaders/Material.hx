package beardFramework.graphics.shaders;
import beardFramework.resources.save.data.StructDataMaterial;
import beardFramework.resources.save.data.StructDataMaterialComponent;
import beardFramework.utils.graphics.Color;

/**
 * ...
 * @author Ludovic
 */
class Material 
{
	
	public var components(default, null):Map<String,MaterialComponent>;
	public var shininess(default, null):Float = 32;
	public var transparency(default, set):Float = 1.0;
	public var bloom(default, set):Float = 0;
	public var isDirty:Bool;
	public var name:String;
	
	public function new() 
	{
		components = new Map();
	}
	
	public function ToData():StructDataMaterial
	{
		
		var componentData:Array<StructDataMaterialComponent> = [];
		var component:MaterialComponent;
		
		for (key in components.keys())
		{
			component = components[key];
			componentData.push({color:component.color,texture:component.texture,atlas:component.atlas,uv:component.uv,type: "",name:key, additionalData:""});
		}
		
		var data:StructDataMaterial =
		{
			
			name:this.name,
			type:Type.getClassName(Material),
			shininess: this.shininess,
			transparency: this.transparency,
			components:componentData,
			additionalData:""		
		}
	
		return data;
	}
	public function ParseData(data:StructDataMaterial):Void
	{
		for (component in data.components)
			components[component.name] = {color:component.color, texture:component.texture, atlas:component.atlas, uv:component.uv};
		
		shininess = data.shininess;
		transparency = data.transparency;
		
		isDirty = true;
	}
	
	public inline function SetComponentAtlas(component:String, atlas:String):Void
	{
		if (components[component] != null){
			components[component].atlas = atlas;
			isDirty = true;
		}
	}
	public inline function SetComponentTexture(component:String, texture:String):Void
	{
		if (components[component] != null){
			components[component].texture = texture;
			isDirty = true;
		}
		
	}
	public inline function SetComponentUVs(component:String, uvX:Float=-1, uvY:Float=-1, uvWidth:Float = -1, uvHeight:Float =-1):Void
	{
		if (components[component] != null){
			if(uvX >= 0) components[component].uv.x = uvX;
			if(uvY >= 0)components[component].uv.y = uvY;
			if(uvWidth >= 0)components[component].uv.width = uvWidth;
			if(uvHeight >= 0)components[component].uv.height = uvHeight;
			isDirty = true;
		}
	}
	public inline function SetComponentColor(component:String, color:Color):Void
	{
		if (components[component] != null){
			components[component].color = color;
			isDirty = true;
		}
	}
	
	public inline function hasComponent(name:String):Bool
	{
		return components[name] != null;
	}
	
	function set_transparency(value:Float):Float 
	{
		isDirty = true;
		return transparency = value;
	}
	
	function set_bloom(value:Float):Float 
	{
		isDirty = true;
		if (value < 0) value = 0;
		return bloom = value;
	}
	
	
}