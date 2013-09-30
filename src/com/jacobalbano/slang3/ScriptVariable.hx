package com.jacobalbano.slang3;

/**
 * A class that allows functions to set variables in the script.
 */
class ScriptVariable
{
	public var name:String;
	public var value:Dynamic;
	
	/**
	 * Constructor
	 * @param	name The name of the variable.
	 * @param	value The value of the variable.
	 */
	public function new(name:String, value:Dynamic) 
	{
		this.name = name;
		this.value = value;
	}
	
	public function toString():String
	{
		return "[object ScriptVariable] " + name + " -> " + Std.string(value);
	}
}