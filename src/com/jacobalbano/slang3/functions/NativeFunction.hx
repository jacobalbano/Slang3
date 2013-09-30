package com.jacobalbano.slang3.functions;
import com.jacobalbano.slang3.functions.SlangFunction;
import com.jacobalbano.slang3.Scope;
import com.jacobalbano.slang3.ScriptVariable;
using com.jacobalbano.slang3.Utils;

/**
 * A function made up of a reference to a method in the application.
 */
class NativeFunction extends SlangFunction
{
	private var func:Dynamic;
	private var self:Dynamic;
	
	/**
	 * Constructor
	 * @param	name The name of the function.
	 * @param	func A reference to the underlying function.
	 * @param	argc The number of arguments this funciton requires.
	 * @param	type This function's type.
	 * @param	?refs (opitonal) An array of Ints representing which indeces in the parameter array must be ScriptVariable references.
	 * @param	?self (optional) The object to use for "this" when the function is called.
	 */
	public function new(name:String, func:Dynamic, argc:Int, type:FunctionType, ?refs:Array<Int>, ?self:Dynamic) 
	{
		super(name);
		this.func = func;
		this.type = type;
		this.self = self;
		_refs = refs == null ? SlangFunction.EMPTY_REFS : refs;
		_argc = argc;
	}
	
	
	/**
	 * Call the funciton.
	 * @param	args an array of parameters to pass the function.
	 * @return The underlying function's return value, if any.
	 */
	override public function call(args:Array<Dynamic>):Dynamic 
	{
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