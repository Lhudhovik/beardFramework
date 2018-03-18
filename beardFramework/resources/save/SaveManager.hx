package beardFramework.resources.save;
import beardFramework.core.BeardGame;
import beardFramework.resources.save.data.DataGeneric;
import beardFramework.resources.save.data.DataSave;
import beardFramework.resources.save.data.DataScreen;
import beardFramework.utils.Crypto;
import beardFramework.utils.DataUtils;
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
	public var currentSave:DataSave;
	
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
				
				#if debug
				var saveData:DataSave = haxe.Json.parse(File.getContent(BeardGame.Get().SAVE_PATH + element));
				#else
				var saveData:DataSave = Crypto.DecodedData(File.getContent(BeardGame.Get().SAVE_PATH + element));	
				#end
				
				saveSlots[saveData.name] = {
					address:BeardGame.Get().SAVE_PATH + element,
					name: saveData.name,
					data:saveData
				}
				
				
	
				
			}
		}
		
		
	}
	
	public inline function Load(name:String):Void
	{
		currentSave = GetSaveData(name);
	}
	
	public function CreateSave(name:String):Bool
	{
		var success : Bool = false;
		
		if (saveSlots[name] == null) 
		{
			saveSlots[name] = {	name : name, address : BeardGame.Get().SAVE_PATH +  name + StringLibrary.SAVE_EXTENSION , data: { name:name, playersData:[],gameData:[]} };
			#if debug
			File.saveContent(saveSlots[name].address, haxe.Json.stringify(saveSlots[name].data));
			#else
			File.saveContent(saveSlots[name].address, Crypto.EncodeData(saveSlots[name].data));
			#end
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
			
			
			#if debug
				
			File.saveContent(saveSlots[name].address, haxe.Json.stringify(data));
	
			
			#else
			File.saveContent(saveSlots[name].address, Crypto.EncodeData(saveSlots[name].data));
			#end
			
			success = true;
			
		}
		
		return success;
	}
	
	public function GetScreenSavedData(screen:String):Dynamic
	{
		
		var map:Map<String, DataGeneric> = ((currentSave != null && currentSave.gameData != null) ? DataUtils.DataArrayToMap(currentSave.gameData) : null);
		var screenData:Dynamic = null;
		
		if (map != null && map[screen] != null) screenData = map[screen];
		
		return screenData;
		
	}
	
}