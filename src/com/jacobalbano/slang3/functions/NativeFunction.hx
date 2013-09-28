package com.jacobalbano.slang3.functions;
import com.jacobalbano.slang3.functions.SlangFunction;
import com.jacobalbano.slang3.Scope;
import com.jacobalbano.slang3.ScriptVariable;
using com.jacobalbano.slang3.Utils;

/**
 * ...
 * @author Jake Albano
 */
class NativeFunction extends SlangFunction
{
	private var func:Dynamic;
	private var self:Dynamic;
	
	public function new(name:String, func:Dynamic, argc:Int, type:FunctionType, ?refs:Array<Int>, ?self:Dynamic) 
	{
		super(name);
		this.func = func;
		this.type = type;
		this.self = self;
		_refs = refs == null ? SlangFunction.EMPTY_REFS : refs;
		_argc = argc;
	}
	
	override public function call(args:Array<Dynamic>):Dynamic 
	{
		trace("execute", name, "( " + args.join(", ") + " )");
		for (i in 0...args.length)
		{
			var index = refs.indexOf(i);
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
		return result;
	}
	
}