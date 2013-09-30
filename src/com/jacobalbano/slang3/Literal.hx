package com.jacobalbano.slang3;
import com.jacobalbano.slang3.ScriptEngine;

@:allow(com.jacobalbano.slang3)
class Literal
{
	public var value:Dynamic;
	public var type:Token;
	
	public function new(value:Dynamic, type:Token) 
	{
		this.value = value;
		this.type = type;
	}
	
	public function toString():String
	{
		return "{ value : " + Std.string(value) + ", type : " + Std.string(type) + "}";
	}
	
}