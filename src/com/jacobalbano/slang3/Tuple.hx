package com.jacobalbano.slang3;

/**
 * ...
 * @author Jake Albano
 */
class Tuple
{
	public var count (get, never) : Int;
	@:allow(com.jacobalbano.slang3) var IDs:Array<String>;

	public function new(IDs:Array<String>) 
	{
		this.IDs = IDs;
	}
	
	public function toString():String
	{
		return "[object Tuple] (" + IDs.join(", ") + ")";
	}
	
	function get_count():Int
	{
		return IDs.length;
	}
}