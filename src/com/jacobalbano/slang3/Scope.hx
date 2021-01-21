package com.jacobalbano.slang3;
import com.jacobalbano.slang3.functions.lib.SlangMath;
import com.jacobalbano.slang3.functions.lib.SlangSTD;
import com.jacobalbano.slang3.functions.lib.SlangString;
import com.jacobalbano.slang3.Scope.Match;
import com.jacobalbano.slang3.ScriptEngine;
import com.jacobalbano.slang3.functions.ScriptFunction;
import com.jacobalbano.slang3.functions.NativeFunction;
import com.jacobalbano.slang3.functions.SlangFunction;

@:allow(com.jacobalbano.slang3)
typedef Match = Array<Dynamic>;

private enum MatchID
{
	FunctionDefinition;
	ProcedureDefinition;
	
	Variable;
	
	Incomplete;
	NoMatchPossible;
}

/**
 * A class containing processed symbols after script compilation.
 * Scopes can be executed multiple times after being compiled.
 */
class Scope
{
	private static var matches:Array<Dynamic>;
	private static function makeMatches():Void
	{
		if (matches != null) return;
		
		matches = [];
		matches.push([Token.Function, Token.Identifier, Tuple, Scope]);
		matches.push([Token.Procedure, Token.Identifier, Tuple, Scope]);
		
		matches.push([Token.Variable, Token.Identifier]);
		
	}
	
	private var symbols:Array<Dynamic>;
	
	@:allow(com.jacobalbano.slang3) var parent:Scope;
	@:allow(com.jacobalbano.slang3)	var functions:Map<String, SlangFunction>;
	private	var vars:Map<String, ScriptVariable>;
	
	/**
	 * Constructor.
	 * @param	parent The scope that encloses this one. If null, this scope is global.
	 */
	public function new(parent:Scope = null) 
	{
		this.parent = parent;
		functions = new Map<String, SlangFunction>();
		vars = new Map<String, ScriptVariable>();
		
		if (parent == null)
		{
			SlangSTD.bind(this);
			SlangMath.bind(this);
			SlangString.bind(this);
		}
	}
	
	/**
	 * Executes the commands contained within this scope.
	 */
	public function execute():Void
	{
		if (symbols == null)
		{
			throw "There was an error during compilation and execution cannot take place.";
		}
		
		evalExpression(symbols);
	}
	
	@:allow(com.jacobalbano.slang3) function evalExpression(symbols:Array<Dynamic>):Array<Dynamic>
	{
		var results:Array<Dynamic> = [];
		var callstack:Array<SlangFunction> = [];
		var argstack:Array<Dynamic> = [];
		var argcounts:Array<Int> = [];
		var argcount:Int = 0;
		
		var checkCall:Void->Void = null;
		var pushFunc:SlangFunction->Void = null;
		var pushArg:Dynamic->Void = null;
		var getStacktrace:Void->String = null;
		
		pushArg = function(value:Dynamic)
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
			
		pushFunc = function(func:SlangFunction)
		{
			callstack.push(func);
			argcounts.push(argcount);
			argcount = 0;
			checkCall();
		}
		
		getStacktrace = function()
		{
			return "at " + [for (f in callstack) f.name].join("\n\t");
		}
		
		
		checkCall = function()
		{
			if (callstack.length > 0)
			{
				var func = callstack[callstack.length - 1];
				if (func.argc == argcount)
				{
					var result = func.call(argstack.slice(-argcount));
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
		
		try
		{
			for (sym in symbols)
			{
				if (Std.is(sym, Literal))
				{
					var l:Literal = cast sym;
					if (l.type == Token.Identifier)
					{
						var name = Std.string(l.value);
						
						var func = getFunction(name);
						if (func != null)
						{
							pushFunc(func);
							continue;
						}
						
						var variable = getVar(name);
						if (variable != null)
						{
							pushArg(variable);
							continue;
						}
						
						throw "'" + name + "' is undefined.";
					}
					else
					{
						pushArg(l.value);
					}
				}
				else if (Std.is(sym, SlangArray))
				{
					var arr:SlangArray = cast sym;
					arr.process(this);
					pushArg(arr);
				}
				else
				{
					//	literal values
					pushArg(sym);
				}
			}
			
			if (callstack.length > 0)
			{
				throw "Unresolved functions left on stack.";
			}
		}
		catch (e:String)
		{
			throw e + "\n\t" + getStacktrace();
		}
		
		return results;
	}
	
	private function getFunction(name:String):SlangFunction
	{
		var result = functions[name];
		if (result != null)
		{
			return result;
		}
		
		if (parent != null)
		{
			return parent.getFunction(name);
		}
		
		return null;
	}
	
	private function getVar(name:String):Dynamic
	{
		var result = vars[name];
		if (result != null)
		{
			return result;
		}
		
		if (parent != null)
		{
			return parent.getVar(name);
		}
		
		return null;
	}
	
	@:allow(com.jacobalbano.slang3)	function process(symbols:Array<Dynamic>):Void
	{
		this.symbols = removeMatches(symbols);
		
		for (sym in symbols)
		{
			if (Std.is(sym, Scope))
			{
				var s:Scope = cast sym;
				if (s.parent == null)
				{
					s.parent = this;
				}
			}
		}
	}
	
	private function removeMatches(symbols:Array<Dynamic>):Array<Dynamic>
	{
		var result:Array<Dynamic> = [];
		
		makeMatches();
		
		var combo:Match = [];
		for (symbol in symbols)
		{
			combo.push(symbol);
			var match = findMatch(matches, combo);
			switch (match) 
			{
				case MatchID.FunctionDefinition:
					newFunc(combo, FunctionType.Function);
					combo = [];
				case MatchID.ProcedureDefinition:
					newFunc(combo, FunctionType.Procedure);
					combo = [];
				case MatchID.Variable:
					result.push(newVar(combo));
					combo = [];
				case MatchID.Incomplete:
					//	continue matching
				case MatchID.NoMatchPossible:
					if (combo.length > 1)
					{
						throw "Pattern ended unexpectedly.";
					}
					else
					{
						if (Std.is(symbol, SlangArray))
						{
							var array:SlangArray = cast symbol;
							var contents = removeMatches(array.symbols);
							result.push(new SlangArray(contents));
						}
						else
						{
							result.push(symbol);
						}
						
						combo = [];
					}
			}
		}
		
		return result;
	}
	
	private static function findMatch(matches:Array<Dynamic>, combo:Match):MatchID
	{
		var exact = exactMatch(matches, combo);
		if (exact != null)
		{
			return exact;
		}
		
		//	if the combo matches, but ends before it resolves
		if (incompleteMatch(matches, combo))
		{
			return MatchID.Incomplete;
		}
		
		return NoMatchPossible;
	}
	
	private static function exactMatch(matches:Array<Dynamic>, combo:Match):Null<MatchID>
	{
		for (i in 0...matches.length)
		{
			var match:Match = matches[i];
			if (arraysEqual(combo, match, true))
			{
				return Type.createEnumIndex(MatchID, i);
			}
		}
		
		return null;
	}
	
	private static function arraysEqual(combo:Match, match:Match, checkLength:Bool):Bool
	{
		if (combo.length != match.length && checkLength)
		{
			return false;
		}
		
		for (i in 0...combo.length)
		{
			var comboItem:Dynamic = combo[i];
			var matchItem:Dynamic = match[i];
			
			if (tokenTypesEqual(comboItem, matchItem))
			{
				continue;
			}
			
			if (literalTypesEqual(comboItem, matchItem))
			{
				continue;
			}
			
			if (instanceTypeEqual(comboItem, matchItem))
			{
				continue;
			}
			
			return false;
		}
		
		
		return true;
	}
	
	private static function incompleteMatch(matches:Array<Dynamic>, combo:Match):Bool
	{
		for (i in 0...matches.length)
		{
			var match:Match = matches[i];
			if (arraysEqual(combo, match, false))
			{
				return true;
			}
		}
		
		return false;
	}
	
	private static function tokenTypesEqual(comboItem:Dynamic, matchItem:Dynamic):Bool
	{
		if (Std.is(comboItem, Token) && Std.is(matchItem, Token))
		{
			var t1:Token = cast comboItem;
			var t2:Token = cast matchItem;
			
			return t1 == t2;
		}
		
		return false;
	}
	
	private static function literalTypesEqual(comboItem:Dynamic, matchItem:Dynamic):Bool
	{
		if (Std.is(comboItem, Literal) && Std.is(matchItem, Token))
		{
			var lit:Literal = cast comboItem;
			var token:Token = cast matchItem;
			
			return lit.type == token;
		}
		
		return false;
	}
	
	private static function instanceTypeEqual(comboItem:Dynamic, matchItem:Dynamic):Bool
	{
		var c:Class<Dynamic> = null;
		
		try
		{
			c = cast(matchItem, Class<Dynamic>);
		}
		catch (err:Dynamic)
		{
			return false;
		}
		
		return Std.is(comboItem, c);
	}
	
	private function newVar(combo:Match):ScriptVariable
	{
		var id:Literal = cast combo[1];
		var name:String = Std.string(id.value);
		var variable = new ScriptVariable(name, null);
		
		if (vars[name] != null)
		{
			throw "A variable with the name '" + name + "' is already defined.";
		}
		
		return setVar(name, variable);
	}
	
	/**
	 * Set a variable in the scope.
	 * @param	name The name of the variable.
	 * @param	variable The variable to set.
	 * @return The variable that was set.
	 */
	public function setVar(name:String, variable:ScriptVariable):ScriptVariable
	{
		vars.set(name, variable);
		return variable;
	}
	
	/**
	 * Add a function to the scope.
	 * @param	name The name of the function.
	 * @param	func The function to add.
	 * @return The function that was added.
	 */
	public function setFunction(func:SlangFunction):SlangFunction
	{
		functions.set(func.name, func);
		return func;
	}
	
	private function newFunc(combo:Array<Dynamic>, type:FunctionType):Void
	{
		var id:Literal = cast combo[1];
		var name:String = Std.string(id.value);
		var params:Tuple = cast combo[2];
		var scope:Scope = cast combo[3];
		var func = new ScriptFunction(name, type, params, scope);
		
		if (functions[name] != null)
		{
			throw "A function or procedure with the name '" + name + "' is already defined.";
		}
		
		functions.set(name, func);
	}
	
	public function toString():String
	{
		var a:Array<String> = [];
		a.push("symbols:");
		for (x in symbols)
		{
			a.push("\t" + Std.string(x));
		}
		
		a.push("functions:");
		for (f in functions)
		{
			 a.push("\t" + f.name);
		}
		
		a.push("variables:");
		for (v in vars)
		{
			a.push("\t" + v);
		}
		
		return "[object Scope" + (parent == null ? " (global) " : "") + "] {\n\t" + a.join("\n\t") + "\n}";
	}
	
}