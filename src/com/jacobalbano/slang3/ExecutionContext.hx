package com.jacobalbano.slang3;
import com.jacobalbano.slang3.functions.SlangFunction;

/**
 * ...
 * @author Jake Albano
 */
class ExecutionContext
{	
	private var results:Array<Dynamic>;
	private var callstack:Array<SlangFunction>;
	private var argstack:Array<Dynamic>;
	private var argcounts:Array<Int>;
	private var argcount:Int;
	
	private var scope:Scope;
	
	public function new(scope:Scope)
	{
		trace("new");
		
		this.scope = scope;
		
		results = [];
		callstack = [];
		argstack = [];
		argcounts = [];
		argcount = 0;
	}
	
	public function checkCall():Void
	{
		if (callstack.length > 0)
		{
			var func = callstack[callstack.length - 1];
			if (func.argc == argcount)
			{
				var result = func.call(this, argstack.slice(-argcount));
				var count = func.argc;
				while (count --> 0)
				{
					argstack.pop();
				}
				
				callstack.pop();
				var count = argcounts.pop();
				if (count == null)
				{
					argcount = 0;
				}
				else
				{
					argcount = count;
				}
				
				if (result != null)
				{
					if (Std.is(result, SlangFunction))
					{
						pushFunc(cast result);
					}
					else
					{
						pushArg(result);
					}
				}
			}
		}
	}
	
	public function pushArg(value:Dynamic):Void
	{			
		if (callstack.length > 0)
		{
			++argcount;
			argstack.push(value);
			checkCall();
		}
		else
		{
			results.push(value);
		}
	}
		
	public function pushFunc(func:SlangFunction):Void
	{
		func.prepare(scope);
		callstack.push(func);
		argcounts.push(argcount);
		argcount = 0;
		checkCall();
	}
		
	public function assertCompleted():Void
	{
		if (callstack.length > 0)
		{
			throw "Unresolved functions left on stack.";
		}
	}
	
	public function getResults():Array<Dynamic>
	{
		return results;
	}
	
	public function getStacktrace():String
	{
		var m = [for (f in callstack) f.name].join("");
		if (m.length == 0)
		{
			return m;
		}
		
		return "at " + m;
	}
	
	public function raiseError(string:String):Void
	{
		throw string;
	}
}