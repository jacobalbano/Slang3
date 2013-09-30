package com.jacobalbano.slang3.functions.lib;
import com.jacobalbano.slang3.functions.NativeFunction;
import com.jacobalbano.slang3.functions.SlangFunction.FunctionType;
import com.jacobalbano.slang3.Scope;
import com.jacobalbano.slang3.SlangArray;

/**
 * Basic string functions. Bound to each global scope automatically.
 */
class SlangString
{
	/**
	 * Bind the Slang string functions
	 * @param	scope
	 */
	public static function bind(scope:Scope):Void
	{
		scope.functions.set("string:format", new NativeFunction("string:format", stringf, 2, FunctionType.Function));
	}
	
	private static function stringf(string:String, args:SlangArray):String
	{
		var result:String = string;
		for (i in 0...args.array.length)
		{
			var item = args.array[i];
			var replace:String = null;
			
			if (Std.is(item, ScriptVariable))
			{
				var v:ScriptVariable = cast item;
				replace = Std.string(v.value);
			}
			else
			{
				replace = Std.string(item);
			}
			
			result = StringTools.replace(string, "{" + i + "}", replace);
		}
		
		return result;
	}
}