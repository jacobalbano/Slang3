package com.jacobalbano.slang3;
import flash.display.DisplayObjectContainer;
import flash.display.GraphicsStroke;
import flash.display.InteractiveObject;
import flash.system.System;
import haxe.remoting.SocketConnection;

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
		var i = 0;
		for (s in symbols)
		{
			trace(Std.string(s) + "\t" + i++);
		}
		
		trace("---");
		
		var collapsed = collapse(symbols);
		for (s in collapsed)
		{
			trace(s);
		}
	}
	
	private function matchStringWithToken(source:String):Bool
	{
		return tokens.exists(source);
	}
	
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
	
	
	private static function collapse(symbols:Array<Dynamic>):Array<Dynamic>
	{
		var read = readAhead(symbols, 0, Token.ModuleEnd);
		return read.contents;
	}
	
	private static function readAhead(symbols:Array<Dynamic>, start:Int, seek:Token):Read
	{
		var i = start + 1;
		var result:Array<Dynamic> = [];
		
		while (i < symbols.length)
		{
			var symbol:Dynamic = symbols[i];
			
			if (symbol == seek)
			{
				break;
			}
			else
			{
				if (symbol == Token.ArrayBegin)
				{
					var read = readAhead(symbols, i, Token.ArrayEnd);
					trace(read);
					i += read.length;
					result.push(read.contents);
				}
				else
				{
					result.push(symbols[i]);
				}
			
				++i;
			}
		}
		
		return {
			contents : result,
			length : i - start
		};
	}
}


typedef Read = {
	var length:Int;
	var contents:Array<Dynamic>;
};

