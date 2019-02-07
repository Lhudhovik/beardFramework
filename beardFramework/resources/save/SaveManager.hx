package beardFramework.resources.save;
import beardFramework.core.BeardGame;
import beardFramework.resources.save.data.DataGeneric;
import beardFramework.resources.save.data.DataPlayer;
import beardFramework.resources.save.data.DataSave;
import beardFramework.resources.save.data.DataScreen;
import beardFramework.resources.save.data.Test;
import beardFramework.utils.Crypto;
import beardFramework.utils.DataU;
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
	
	
	private var saveSlots:Map<String, DataSlot<DataSave>>;
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
		
		saveSlots = new Map<String, DataSlot<DataSave>>();
		
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
					data: saveData
				}

			}
		}
		
		
	}
	
	public inline function Load(saveName:String):Void
	{
		currentSave = GetSave(saveName);
	}
	
	public function CreateSave(saveName:String):Bool
	{
		var success : Bool = false;
		
		if (saveSlots[saveName] == null) 
		{
			saveSlots[saveName] = {	name : saveName, address : BeardGame.Get().SAVE_PATH +  saveName + StringLibrary.SAVE_EXTENSION , data: { name:saveName, playersData:[],gameData:[]} };
			#if debug
			File.saveContent(saveSlots[saveName].address, haxe.Json.stringify(saveSlots[saveName].data));
			#else
			File.saveContent(saveSlots[saveName].address, Crypto.EncodeData(saveSlots[saveName].data));
			#end
			success = true;
		}
		
		return success;
	}
	
	public function DeleteSave(saveName:String):Bool
	{
		var success : Bool = false;
		
		if (saveSlots[saveName] != null) 
		{
			FileSystem.deleteFile(saveSlots[saveName].address);
			
			success = true;
		}
		
		return success;
	}
	
	public function GetSave(saveName:String):DataSave
	{
		
		if (saveSlots[saveName] != null){
			
			return saveSlots[saveName].data;
		}
	
		return null;
	}
	
	public function Save(saveName:String = "", data:DataSave = null):Bool
	{
		var success : Bool = false;
		if (saveName == "" && currentSave != null){
			saveName = currentSave.name;	
		}
		
		if(data == null && currentSave != null) data = currentSave;
				
		if (saveSlots[saveName] != null){
			
			if (data != null) saveSlots[saveName].data = data;
			
			
			#if debug
				
			File.saveContent(saveSlots[saveName].address, haxe.Json.stringify(data));
	
			
			#else
			File.saveContent(saveSlots[saveName].address, Crypto.EncodeData(saveSlots[saveName].data));
			#end
			
			success = true;
			
		}
		
		return success;
	}
	
	public function GetSavedPlayerData(name:String):DataPlayer
	{
		
		var playerData:DataPlayer = null;
		if (currentSave != null && currentSave.playersData != null)
			for (data in currentSave.playersData)
				if (data.name == name) playerData = cast data;
		
		return playerData;
		
	}
	
	@:generic
	public function GetSavedGameData<T>(name:String,  receiver:T):T
	{
		receiver = null;
		if (currentSave != null && currentSave.gameData != null)
			for (data in currentSave.gameData)
				if (data.name == name)
					receiver = cast data;
		
		return receiver;
		
	}
	
	@:generic
	public function SaveGameData<T>(name:String,  data:T):Bool
	{
		var success:Bool = false;
		
		if (currentSave != null && currentSave.gameData != null){
			
			for (savedData in currentSave.gameData)
				if (savedData.name == name){
					
					savedData = cast data;
					success = true;
					break;
				}
			
			if (!success){
				currentSave.gameData.push(cast data);
				success = true;
			}
			
			success = Save();
		}
		
		return success;
		
	}
	
	
	
}