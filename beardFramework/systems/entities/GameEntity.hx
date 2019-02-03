package beardFramework.systems.entities;
import beardFramework.interfaces.IEntityComponent;
import beardFramework.interfaces.IEntityVisual;
import beardFramework.resources.save.data.DataEntity;
/* ...
 * @author Ludo
 */
class GameEntity
{
	
	static private var entitiesCount:Int = 0;
	public var name:String;
	public var x:Float;
	public var y:Float;
	public var isLocal:Bool=true;
	public var forcedLocation(default, null):Bool = false;
	public var isVirtual(default,null):Bool;
	public var requiredSave(default,null):Bool=false;
	
	
	private var components:Array<IEntityComponent>;

	public function new(x:Float = 0, y:Float = 0) 
	{
		this.x = x;
		this.y = y;
		
		
		
		components = new Array<IEntityComponent>();
		isVirtual = false;
		
		name = "Game Entity " + entitiesCount++;
		
	}
	
	public function AddComponent(component:IEntityComponent, update:Bool = true, position:Int = -1):IEntityComponent
	{
		
		if (components.indexOf(component) == -1)
		{
		
			if (position >= 0) components.insert(position, component);
			else components.push(component);
			
			component.parentEntity = this;
			
			if (update) component.Update();
		}
		
		return component;
		
	}
	
	public function RemoveComponentByName(componentName:String):IEntityComponent
	{
		
		for (component in components)
		{
			if (component.name == componentName)
			{
				components.remove(component);
				component.parentEntity = null;
				return component;
			}
		}
		
		return null;
	}
	
	public function RemoveComponent(component:IEntityComponent):IEntityComponent
	{
		
		if (components.indexOf(component) != -1)
		{
			components.remove(component);
			component.parentEntity = null;
			
			return component;
			
		}
	
		return null;
		
	}
	
	public function GetComponent(componentName:String):IEntityComponent
	{
		
		for (component in components)
		{
			if (component.name == componentName) 
				return component;
		}
		
		return null;
		
	}
	
	public function GetComponents():Array<IEntityComponent>
	{
		
		return components;
		
	}
	
	public function Update():Void
	{
		for (component in components)
		{
			component.Update();
		}
		
		forcedLocation = false;
	}
	
	public function ForceLocation(x:Float, y:Float):Void
	{
		
		this.x = x;
		this.y = y;
		forcedLocation = true;
	
	}
	
	public function Virtualize():Void{
		//clear basic components
		//remove Listeners if needed
		
	}
	
	public function Devirtualize():Void{
		//redeem basic components
		//re-add listeners if needed
	}
	
	public function ToData():DataEntity
	{
		
		var data:DataEntity =
		{
			
			name:this.name,
			type:Type.getClassName(GameEntity),
			x:this.x,
			y:this.y,
			components:[for (component in components) component.ToData()],
			additionalData:""
			
			
		}
		
		
	
		
		return data;
		
	}
	
	public function ParseData(data:DataEntity):Void
	{
		this.name = data.name;
		this.x = data.x;
		this.y = data.y;
		
		for (componentData in data.components)
		{
			//trace(this);
			var component:Dynamic = Type.createInstance(Type.resolveClass(componentData.type), []);
			//trace(Type.resolveClass(componentData.type));
			AddComponent(component, componentData.update, componentData.position);
			component.ParseData(componentData);
		}
	}
	
	public function Dispose():Void
	{
		entitiesCount--;
		
		for (component in components)
		{
				
			if (Std.is(component, IEntityVisual))
			{
				cast(component, IEntityVisual).UnRegister();
			}
			
			component.Dispose();
		}
			
		
		
		
	}
	
}


