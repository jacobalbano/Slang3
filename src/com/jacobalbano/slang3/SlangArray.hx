package com.jacobalbano.slang3;
import com.jacobalbano.slang3.functions.SlangFunction;
import com.jacobalbano.slang3.ScriptEngine;

/**
 * ...
 * @author Jake Albano
 */
class SlangArray
{
	@:allow(com.jacobalbano.slang3) var symbols:Array<Dynamic>;
	@:allow(com.jacobalbano.slang3) var contents:Array<Dynamic>;
	
	public function new(symbols:Array<Dynamic>) 
	{
		this.symbols = symbols;
	}
	
	@:allow(com.jacobalbano.slang3) function process(scope:Scope):Void
	{
		if (contents != null)
		{
			//	processing is already done
			return;
		}
		
		contents = scope.evalExpression(symbols);
	}
	
	public function toString():String
	{
		var a = [for (x in contents) Std.string(x)];
		return "[object Array] [\n\t" + a.join(", \n\t") + "\n]";
	}
	
}