package beardFramework.interfaces;

/**
 * @author Ludo
 */
interface IButton 
{
	private function OnOver(value:Float):Void;
	private function OnOut(value:Float):Void;
	private function OnClick(value:Float):Void;
	private function OnDown(value:Float):Void;
	private function OnUp(value:Float):Void;
	private function OnMove(value:Float):Void;
	private function OnWheel(value:Float):Void;
}