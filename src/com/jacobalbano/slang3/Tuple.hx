package com.jacobalbano.slang3;

/**
 * ...
 * @author Jake Albano
 */
class Tuple
{
	private var IDs:Array<String>;

	public function new(IDs:Array<String>) 
	{
		this.IDs = IDs;
	}
	
	public function toString():String
	{
		return "[object Tuple] (" + IDs.join(", ") + ")";
	}
	
}