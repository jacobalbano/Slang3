package com.jacobalbano.slang3.functions;
import com.jacobalbano.slang3.functions.SlangFunction;
import com.jacobalbano.slang3.Scope;
import com.jacobalbano.slang3.ScriptVariable;
import com.jacobalbano.slang3.Tuple;

/**
  * A function made up of a Slang scope
  */
class ScriptFunction extends SlangFunction
{
	private var params:Tuple;
	private var scope:Scope;
	
	//	the return value
	private var result:Dynamic;
	
	/**
	 * Constructor
	 * @param	name The name of the function.
	 * @param	type The type of the function.
	 * @param	params A tuple that defines argument names.
	 * @param	scope The function body.
	 */
	public function new(name:String, type:FunctionType, params:Tuple, scope:Scope)
	{
		super(name);
		this.type = type;
		this.params = params;
		this.scope = scope;
		_refs = SlangFunction.EMPTY_REFS;
		
		scope.functions.set("return", new NativeFunction("return", __return, 1, FunctionType.Function, this));
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
			if (Std.is(args[i], ScriptVariable))
			{
				scope.setVar(params.IDs[i], cast args[i]);
			}
			else
			{
				scope.setVar(params.IDs[i], new ScriptVariable(params.IDs[i], args[i]));
			}
		}
		
		scope.execute();
		
		return result;
	}
	
	override private function get_argc():Int 
	{
		return params.count;
	}
	
	private function __return(arg:Dynamic):Dynamic
	{
		result = arg;
		return result;
	}
}