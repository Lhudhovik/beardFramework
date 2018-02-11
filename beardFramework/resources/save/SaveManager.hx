package beardFramework.resources.save;
import beardFramework.core.BeardGame;
import beardFramework.resources.save.data.DataSave;
import beardFramework.utils.Crypto;
import beardFramework.utils.StringLibrary;
import haxe.Json;
import sys.FileSystem;
import sys.io.File;
import sys.io.FileSeek;

/**
 * ...
 * @author Ludo
 */
class SaveManager
{
	private static var instance(default, null):SaveManager;
	
	
	private var saveSlots:Map<String, SaveSlot>;
	
	
	private function new() 
	{
		
	}
	
	public static inline function Get():SaveManager
	{
		if (instance == null)
		{
			instance = new SaveManager();
			instance.Init();
		}
		
		return instance;
	}
		
	private function Init():Void
	{
		
		saveSlots = new Map<String, SaveSlot>();
		
		if (!FileSystem.exists(BeardGame.Get().SAVE_PATH)) FileSystem.createDirectory(BeardGame.Get().SAVE_PATH);
		for (element in FileSystem.readDirectory(BeardGame.Get().SAVE_PATH))
		{
			if (element.indexOf(StringLibrary.SAVE_EXTENSION) != -1){
				
				var saveData:DataSave = Crypto.DecodedData(File.getContent(BeardGame.Get().SAVE_PATH+ element));	
				
				saveSlots[saveData.name] = {
					address:element,
					name: saveData.name,
					data:saveData
				}
				
				trace(saveData);
	
				
			}
		}
		
		
	}
	
	public function Load():Void
	{
		
		
		
		
	}
	
	public function CreateSave(name:String):Bool
	{
		var success : Bool = false;
		
		if (saveSlots[name] == null) 
		{
			saveSlots[name] = {	name : name, address : BeardGame.Get().SAVE_PATH +  name + StringLibrary.SAVE_EXTENSION , data: { name:name, playersData:[],gameData:[]} };
			File.saveContent(saveSlots[name].address, Crypto.EncodeData(saveSlots[name].data));
			success = true;
		}
		
		return success;
	}
	
	public function DeleteSave(name:String):Bool
	{
		var success : Bool = false;
		
		if (saveSlots[name] != null) 
		{
			FileSystem.deleteFile(saveSlots[name].address);
			
			success = true;
		}
		
		return success;
	}
	
	public function GetSaveData(name:String):DataSave
	{
		
		if (saveSlots[name] != null){
			
			return saveSlots[name].data;
		}
	
		return null;
	}
	
	public function Save(name:String, data:DataSave = null):Bool
	{
		var success : Bool = false;
		
		if (saveSlots[name] != null){
			
			if (data != null) saveSlots[name].data = data;
			
			File.saveContent(saveSlots[name].address, Crypto.EncodeData(saveSlots[name].data));
			
			success = true;
			
		}
	
		return success;
	}
	
}