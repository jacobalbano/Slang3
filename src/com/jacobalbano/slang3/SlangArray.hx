package com.jacobalbano.slang3;
import com.jacobalbano.slang3.functions.SlangFunction;
import com.jacobalbano.slang3.ScriptEngine;

/**
 * ...
 * @author Jake Albano
 */
class SlangArray
{
	private var symbols:Array<Dynamic>;
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
		
		contents = [];
		var callstack:Array < SlangFunction> = [];
		var argstack:Array<Dynamic> = [];
		
		function checkCall()
		{
			if (callstack.length > 0)
			{
				var func = callstack[callstack.length - 1];
				if (func.argc == argstack.length)
				{
					func.call(argstack.concat([]));
					argstack = [];
				}
			}
		}
		
		for (sym in symbols)
		{
			trace(sym);
			if (Std.is(sym, Literal))
			{
				var l:Literal = cast sym;
				if (l.type == Token.Identifier)
				{
					var name = Std.string(l.value);
					var func = scope.getFunction(name);
					if (func != null)
					{
						callstack.push(func);
						checkCall();
						continue;
					}
					
					var variable = scope.getVar(name);
					if (variable != null)
					{
						if (callstack.length > 0)
						{
							argstack.push(variable);
							checkCall();
							continue;
						}
						else
						{
							contents.push(variable.value);
							continue;
						}
					}
				}
				else
				{
					if (callstack.length > 0)
					{
						argstack.push(l.value);
						checkCall();
					}
					else
					{
						contents.push(l.value);
					}
				}
			}
		}
		
	}
	
	public function toString():String
	{
		var a = [for (x in contents) Std.string(x)];
		return "[object Array] [\n\t" + a.join(", \n\t") + "\n]";
	}
	
}