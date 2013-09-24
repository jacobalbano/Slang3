package com.jacobalbano.slang3.functions;
import com.jacobalbano.slang3.functions.SlangFunction;
import com.jacobalbano.slang3.ScriptVariable;

/**
 * ...
 * @author Jake Albano
 */
class NativeFunction extends SlangFunction
{
	private var func:Dynamic;
	private var self:Dynamic;
	
	public function new(func:Dynamic, argc:Int, type:FunctionType, ?refs:Array<Int>, ?self:Dynamic) 
	{
		this.func = func;
		this.type = type;
		this.self = self;
		_refs = refs == null ? SlangFunction.EMPTY_REFS : refs;
		_argc = argc;
	}
	
		private static function indexOf<T>(a:Array<T>, v:T):Int
		{
			var i = 0;
			for (v2 in a)
			{
				if( v == v2 ) return i;
				i++;
			}
			return -1;
		}
	
	override public function call(args:Array<Dynamic>):Dynamic 
	{
		for (i in 0...args.length)
		{
			var index = indexOf(refs, i);
			if (index < 0)
			{
				if (Std.is(args[i], ScriptVariable))
				{
					var variable:ScriptVariable = cast args[i];
					args[i] = variable.value;
				}
			}
			else
			{
				if (!Std.is(args[i], ScriptVariable))
				{
					throw "Function expected a reference but recieved a literal value.";
				}
			}
		}
		
		var result = Reflect.callMethod(self, func, args);
		return type == FunctionType.Procedure ? null : result;
	}
	
}