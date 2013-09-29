package com.jacobalbano.slang3.functions.lib;
import com.jacobalbano.slang3.functions.NativeFunction;
import com.jacobalbano.slang3.functions.SlangFunction;
import com.jacobalbano.slang3.Literal;
import com.jacobalbano.slang3.Scope;
import com.jacobalbano.slang3.ScriptEngine;
import com.jacobalbano.slang3.ScriptVariable;
import com.jacobalbano.slang3.SlangArray;
using StringTools;

/**
 * ...
 * @author Jake Albano
 */
class SlangSTD
{
	public static function bind(scope:Scope):Void
	{
		scope.functions.set("print", new NativeFunction("print", print, 1, FunctionType.Procedure));
		scope.functions.set("printf", new NativeFunction("printf", printf, 2, FunctionType.Procedure));
		scope.functions.set("set", new NativeFunction("set", __set, 2, FunctionType.Function, [0]));
		                                                   
		scope.functions.set("if", new NativeFunction("if", __if, 2, FunctionType.Procedure));
		scope.functions.set("ifelse", new NativeFunction("ifelse", __ifelse, 3, FunctionType.Procedure));
		scope.functions.set("!", new NativeFunction("!", __not, 1, FunctionType.Function));
		scope.functions.set("==", new NativeFunction("==", __eq, 2, FunctionType.Function));
		
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
	
	private static function printf(s:String, args:SlangArray):Void
	{
		var result:String = s;
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
			
			result = StringTools.replace(s, "{" + i + "}", replace);
		}
		
		trace(result);
	}
	
	private static function __not(condition:Bool):Bool
	{
		return !condition;
	}
	
	private static function __eq(o1:Dynamic, o2:Dynamic):Bool
	{
		return o1 == o2;
	}
	
	private static function __if(condition:Bool, scope:Scope):Void
	{
		if (condition)
		{
			scope.execute();
		}
	}
	
	private static function __ifelse(condition:Bool, trueScope:Scope, falseScope:Scope):Void
	{
		if (condition)
		{
			trueScope.execute();
		}
		else
		{
			falseScope.execute();
		}
	}
}