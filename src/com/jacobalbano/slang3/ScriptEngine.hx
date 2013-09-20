package com.jacobalbano.slang3;
import flash.display.DisplayObjectContainer;
import flash.display.GraphicsStroke;

/**
 * ...
 * @author Jake Albano
 */

private enum Token
{
	ModuleBegin;
	ModuleEnd;
	
	Define;
	
	LiteralNumber;
	LiteralBool;
	LiteralString;
	Identifier;
	
	ScopeBegin;
	ScopeEnd;
	
	ArrayBegin;
	ArrayEnd;
	
	TupleBegin;
	TupleEnd;
}

private typedef Literal = {
	var value:Dynamic;
	var type:Token;
}

class ScriptEngine
{
	private var tokens:Map<String, Token>;
	
	public function new() 
	{
		tokens = new Map<String, Token>();
		tokens.set("def", Token.Define);
		tokens.set("{", Token.ScopeBegin);
		tokens.set("}", Token.ScopeEnd);
		tokens.set("[", Token.ArrayBegin);
		tokens.set("]", Token.ArrayEnd);
		tokens.set("(", Token.TupleBegin);
		tokens.set(")", Token.TupleEnd);
	}
	
	public function parse(source:String):Void
	{
		source = source + "\n";	//	append a newline for super clean symbolification
		var symbols = new Array<String>();
		var stringbuilder = new StringBuf();
		var cursor = 0;
		var inString = false;
		var escape = false;
		
		function newSym(sym = null)
		{
			sym = (sym == null) ? stringbuilder.toString() : sym;
			if (sym.length != 0)
			{
				symbols.push(sym);
			}
			
			stringbuilder = new StringBuf();
		}
		
		while (cursor < source.length)
		{
			var char = source.charAt(cursor);
			cursor++;
			
			if (char == '"')
			{
				if (!(inString = !inString))
				{
					stringbuilder.add(char);
					newSym();
					continue;
				}
			}
			
			if (inString)
			{
				stringbuilder.add(char);
			}
			else
			{
				if (StringTools.isSpace(char, 0))
				{
					newSym();
				}
				else
				{
					if (matchStringWithToken(char))
					{
						newSym();
						newSym(char);
						continue;
					}
					else
					{
						//	continue appending to the current symbol
						stringbuilder.add(char);
					}
					
					//	if the symbol matches a reserved word or token, add it immediately without waiting for whitespace
					if (matchStringWithToken(stringbuilder.toString()))
					{
						newSym();
					}
				}
			}
		}
		
		
		var processedSymbols = new Array<Dynamic>();
		processedSymbols.push(Token.ModuleBegin);
		
		for (symbol in symbols) 
		{
			var t = tokens[symbol];
			if (t == null)
			{
				processedSymbols.push(getLiteral(symbol));
			}
			else
			{
				processedSymbols.push(t);
			}
		}
		
		processedSymbols.push(Token.ModuleEnd);
		
		compile(processedSymbols);
	}
	
	private function compile(symbols:Array<Dynamic>) 
	{
		var collapsed = collapse(symbols, 0, Token.ModuleEnd, 0);
		for	(symbol in collapsed)
		{
			trace(symbol);
		}
	}
	
	private function matchStringWithToken(source:String):Bool
	{
		return tokens.exists(source);
	}
	
	//TODO:	rename this?
	private static function getLiteral(string:String):Literal
	{
		var type = Token.Identifier;
		if (string == "true" || string == "false")
		{
			type = Token.LiteralBool;
		}
		
		if (!Math.isNaN(Std.parseFloat(string)))
		{
			type = Token.LiteralNumber;
		}
		
		if (StringTools.startsWith(string, '"') && StringTools.endsWith(string, '"'))
		{
			type = Token.LiteralString;
		}
		
		var value:Dynamic = switch(type)
		{
			case Token.LiteralBool:
				(string == "true");
			case Token.LiteralNumber:
				Std.parseFloat(string);
			case Token.LiteralString:
				string.substr(1, string.length - 2);	//	trip quotation marks
			case Token.Identifier:
				string;
			default:
				throw "oh noooooo";
		}
		
		return { value : value, type : type };
	}
	
	private static function collapse(symbols:Array<Dynamic>, start:Int, seek:Token, depth:Int):Array<Dynamic>
	{
		trace(depth, symbols[start]);
		var result:Array<Dynamic> = [];
		var i = start;
		var symbol:Dynamic = null;
		
		var all:Array<Dynamic> = [];
		
		while (symbol != seek)
		{
			if (i >= symbols.length)
			{
				throw "bad bad bad";
			}
			
			symbol = symbols[i];
			
			if (symbol == Token.ModuleEnd && seek != Token.ModuleEnd)
			{
				throw "Unexpected end of module; " + Std.string(seek) + " expected.";
			}
			
			function err(t) { throw "Unexpected " + Std.string(t); }
			
			if (Std.is(symbol, Token))
			{
				var token:Token = cast symbol;
				switch (token)
				{
					//	pass
					case Token.ModuleBegin:
					case Token.ModuleEnd:
					
					//	error
					//case Token.ScopeEnd: err(token);
					//case Token.TupleEnd: err(token);
					//case Token.ArrayEnd: err(token);
					
					case Token.ScopeBegin:
						var contents = collapse(symbols, i + 1, Token.ScopeEnd, depth + 1);
						i += contents.length;
						contents.pop();
						
						result.push(new Scope(contents));
						
					case Token.ArrayBegin:
						var contents = collapse(symbols, i + 1, Token.ArrayEnd, depth + 1);
						i += contents.length;
						contents.pop();
						
						result.push(new SlangArray(contents));
						
					case Token.TupleBegin:
						var contents = collapse(symbols, i + 1, Token.TupleEnd, depth + 1);
						i += contents.length;
						contents.pop();
						
						var IDs = [];
						for (id in contents) 
						{
							var lit:Literal = cast id;
							if (Std.is(id, Token) || lit.type != Token.Identifier)
							{
								throw "Tuples can only contain identifiers!";
							}
							
							IDs.push(lit.value);
						}
						
						result.push(new Tuple(IDs));
						
					default:
						result.push(token);
				}
			}
			else
			{
				result.push(symbol);
			}
			
			++i;
		}
		
		return result;
	}
}