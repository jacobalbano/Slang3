package com.jacobalbano.slang3;

/**
 * ...
 * @author Jake Albano
 */
class Scope
{
	private var symbols:Array<Dynamic>;
	
	public function new(symbols:Array<Dynamic>) 
	{
		this.symbols = symbols;
	}
	
	public function toString():String
	{
		var a:Array<Dynamic> = [for (x in symbols) Std.string("\t" + x + "\n")];
		return "[object Scope] {\n" + a.join(" ") + "\n}";
	}
	
}