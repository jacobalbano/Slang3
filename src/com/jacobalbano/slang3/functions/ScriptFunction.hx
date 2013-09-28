package com.jacobalbano.slang3.functions;
import com.jacobalbano.slang3.functions.SlangFunction;
import com.jacobalbano.slang3.Scope;
import com.jacobalbano.slang3.ScriptVariable;
import com.jacobalbano.slang3.Tuple;

/**
 * ...
 * @author Jake Albano
 */

class ScriptFunction extends SlangFunction
{
	private var params:Tuple;
	private var scope:Scope;
	
	//	the return value
	private var result:Dynamic;
	
	public function new(name:String, type:FunctionType, params:Tuple, scope:Scope)
	{
		super(name);
		this.type = type;
		this.params = params;
		this.scope = scope;
		_refs = SlangFunction.EMPTY_REFS;
		
		scope.functions.set("return", new NativeFunction("return", __return, 1, FunctionType.Function, this));
	}
	
	override public function call(args:Array<Dynamic>):Dynamic
	{
		trace("execute", name);
		for (i in 0...args.length)
		{
			var v = scope.setVar(params.IDs[i], new ScriptVariable(params.IDs[i], args[i]));
			trace("arg", v);
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