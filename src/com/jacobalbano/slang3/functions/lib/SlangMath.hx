package com.jacobalbano.slang3.functions.lib;
import com.jacobalbano.slang3.functions.NativeFunction;
import com.jacobalbano.slang3.functions.SlangFunction;
import com.jacobalbano.slang3.Scope;

/**
 * ...
 * @author Jake Albano
 */
class SlangMath
{
	public static function bind(scope:Scope):Void
	{
		scope.functions.set("<", 	new NativeFunction("<", __lt, 2, FunctionType.Function));
		scope.functions.set(">", 	new NativeFunction(">", __gt, 2, FunctionType.Function));
		scope.functions.set("<=", 	new NativeFunction("<=", __lte, 2, FunctionType.Function));
		scope.functions.set(">=", 	new NativeFunction(">=", __gte, 2, FunctionType.Function));
		
		scope.functions.set("+", 	new NativeFunction("+", __add, 2, FunctionType.Function));
		scope.functions.set("add", 	new NativeFunction("add", __add, 2, FunctionType.Function));
		
		scope.functions.set("-", 	new NativeFunction("-", __sub, 2, FunctionType.Function));
		scope.functions.set("sub", 	new NativeFunction("sub", __sub, 2, FunctionType.Function));
		
		scope.functions.set("*", 	new NativeFunction("*", __mul, 2, FunctionType.Function));
		scope.functions.set("mul", 	new NativeFunction("mul", __mul, 2, FunctionType.Function));
		
		scope.functions.set("/", 	new NativeFunction("/", __div, 2, FunctionType.Function));
		scope.functions.set("div", 	new NativeFunction("div", __div, 2, FunctionType.Function));
		
		scope.functions.set("%", 	new NativeFunction("%", __mod, 2, FunctionType.Function));
		scope.functions.set("mod", 	new NativeFunction("mod", __mod, 2, FunctionType.Function));
	}
	
	private static function __lt(a1:Float, a2:Float):Bool
	{
		return a1 < a2;
	}
	
	private static function __gt(a1:Float, a2:Float):Bool
	{
		return a1 > a2;
	}
	
	private static function __lte(a1:Float, a2:Float):Bool
	{
		return a1 <= a2;
	}
	
	private static function __gte(a1:Float, a2:Float):Bool
	{
		return a1 >= a2;
	}
	
	private static function __add(a1:Float, a2:Float):Float
	{
		return a1 + a2;
	}
	
	private static function __sub(a1:Float, a2:Float):Float
	{
		return a1 - a2;
	}
	
	private static function __mul(a1:Float, a2:Float):Float
	{
		return a1 * a2;
	}
	
	private static function __div(a1:Float, a2:Float):Float
	{
		return a1 / a2;
	}
	
	private static function __mod(a1:Float, a2:Float):Float
	{
		return a1 % a2;
	}

}