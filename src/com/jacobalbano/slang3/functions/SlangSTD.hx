package com.jacobalbano.slang3.functions;
import com.jacobalbano.slang3.functions.SlangFunction;
import com.jacobalbano.slang3.Scope;
import com.jacobalbano.slang3.ScriptVariable;

/**
 * ...
 * @author Jake Albano
 */
class SlangSTD
{
	public static function bindSTD(scope:Scope):Void
	{
		scope.functions.set("print", new NativeFunction(print, 1, FunctionType.Procedure));
		scope.functions.set("set", new NativeFunction(__set, 2, FunctionType.Function, [0]));
	}
	
	private static function __set(variable:ScriptVariable, value:Dynamic):Dynamic
	{
		variable.value = value;
		return value;
	}
	
	private static function print(p:Dynamic):Void
	{
		trace(Std.string(p));
	}
}