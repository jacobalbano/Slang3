package com.jacobalbano.slang3;

/**
 * ...
 * @author Jake Albano
 */
class ScriptVariable
{
	public var name:String;
	public var value:Dynamic;
	
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