package com.jacobalbano.slang3;

/**
 * A small wrapper around Array<Dynamic>. Used internally.
 */
class SlangArray
{
	@:allow(com.jacobalbano.slang3) var symbols:Array<Dynamic>;
	@:allow(com.jacobalbano.slang3) var contents:Array<Dynamic>;
	
	/**
	 * The contents of this array.
	 */
	public var array (get, never) :Array<Dynamic>;
	private function get_array():Array<Dynamic>
	{
		return contents;
	}
	
	/**
	 * Constructor. Used internally by the script engine; do not call directly!
	 * @param	symbols
	 */
	public function new(symbols:Array<Dynamic>) 
	{
		this.symbols = symbols;
	}
	
	@:allow(com.jacobalbano.slang3) function process(scope:Scope):Void
	{
		if (contents != null)
		
		{
			//	processing is already done
			return;
		}
		
		contents = scope.evalExpression(symbols);
	}
	
	public function toString():String
	{
		var a = [for (x in contents) Std.string(x)];
		return "[object Array] [\n\t" + a.join(", \n\t") + "\n]";
	}
	
}