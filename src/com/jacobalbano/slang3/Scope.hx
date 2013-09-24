package com.jacobalbano.slang3;
import com.jacobalbano.slang3.functions.lib.SlangSTD;
import com.jacobalbano.slang3.Scope.Match;
import com.jacobalbano.slang3.ScriptEngine;
import com.jacobalbano.slang3.functions.ScriptFunction;
import com.jacobalbano.slang3.functions.NativeFunction;
import com.jacobalbano.slang3.functions.SlangFunction;

/**
 * ...
 * @author Jake Albano
 */

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
	
	private var parent:Scope;
	@:allow(com.jacobalbano.slang3)	var functions:Map<String, SlangFunction>;
	@:allow(com.jacobalbano.slang3)	var vars:Map<String, ScriptVariable>;
	
	public function new(parent:Scope = null) 
	{
		this.parent = parent;
		functions = new Map<String, SlangFunction>();
		vars = new Map<String, ScriptVariable>();
		
		if (parent == null)
		{
			SlangSTD.bindSTD(this);
		}
	}
	
	public function execute():Void
	{
		if (symbols == null)
		{
			throw "There was an error during compilation and execution cannot take place.";
		}
		
		var callstack:Array<SlangFunction> = [];
		var argstack:Array<Dynamic> = [];
		
		function checkCall()
		{
			if (callstack.length > 0)
			{
				var func = callstack[callstack.length - 1];
				if (func.argc == argstack.length)
				{
					func.call(argstack.concat([]));
					argstack = [];
				}
			}
		}
		
		for (sym in this.symbols)
		{
			if (Std.is(sym, Literal))
			{
				var l:Literal = cast sym;
				if (l.type == Identifier)
				{
					var name = Std.string(l.value);
					var func = getFunction(name);
					if (func != null)
					{
						callstack.push(func);
						checkCall();
						continue;
					}
					
					var variable = getVar(name);
					if (variable != null)
					{
						if (callstack.length > 0)
						{
							argstack.push(variable);
							checkCall();
							continue;
						}
					}
				}
				else
				{
					if (callstack.length > 0)
					{
						argstack.push(l.value);
						checkCall();
					}
				}
			}
			else if (Std.is(sym, SlangArray))
			{
				trace("arrayyyyy");
				var arr:SlangArray = cast sym;
				arr.process(this);
				argstack.push(sym);
				checkCall();
				continue;
			}
			else
			{
				//	literal values
				argstack.push(sym);
				checkCall();
				continue;
			}
		}
	}
	
	@:allow(com.jacobalbano.slang3) function getFunction(name:String):SlangFunction
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
	
	@:allow(com.jacobalbano.slang3) function getVar(name:String):Dynamic
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
		
		throw "'" + name + "' is undefined.";
		return null;
	}
	
	@:allow(com.jacobalbano.slang3)
	function process(symbols:Array<Dynamic>):Void
	{
		this.symbols = removeMatches(symbols);
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
						result.push(symbol);
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
		var variable = new ScriptVariable(null);
		
		if (vars[name] != null)
		{
			throw "A variable with the name '" + name + "' is already defined.";
		}
		
		vars.set(name, variable);
		
		return variable;
	}
	
	private function newFunc(combo:Array<Dynamic>, type:FunctionType):Void
	{
		var id:Literal = cast combo[1];
		var name:String = Std.string(id.value);
		var params:Tuple = cast combo[2];
		var scope:Scope = cast combo[3];
		var func = new ScriptFunction(type, params, scope);
		
		if (functions[name] != null)
		{
			throw "A function or procedure with the name '" + name + "' is already defined.";
		}
		
		functions.set(name, func);
	}
	
	public function toString():String
	{
		var a:Array<Dynamic> = [for (x in symbols) Std.string("\t" + x + "\n")];
		return "[object Scope] {\n" + a.join(" ") + "\n}";
	}
	
}