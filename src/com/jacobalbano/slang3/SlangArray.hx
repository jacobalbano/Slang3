package com.jacobalbano.slang3;

/**
 * ...
 * @author Jake Albano
 */
class SlangArray
{
	private var symbols:Array<Dynamic>;
	
	public function new(symbols:Array<Dynamic>) 
	{
		this.symbols = symbols;
	}
	
	public function toString():String
	{
		var a = [for (x in symbols) Std.string(x)];
		return "[object Array] [\n\t" + a.join(", \n\t") + "\n]";
	}
	
}