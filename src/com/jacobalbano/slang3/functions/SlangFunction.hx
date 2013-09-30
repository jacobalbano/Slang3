package com.jacobalbano.slang3.functions;
import com.jacobalbano.slang3.Scope;

 /**
  * A native function registered as a Function must return a value.
  * A native function registered as a Procedured will have its return value ignored.
  */
enum FunctionType
{
	Function;
	Procedure;
}

/**
 * Base class for a function that can be pushed onto Slang's callstack
 */
class SlangFunction
{
	private static var EMPTY_REFS:Array<Int> = [];

	@:allow(com.jacobalbano.slang3) var context:Scope;
	
	/**
	 * The number of arguments this function requires.
	 */
	public var argc (get, never) : Int;
	
	/**
	 * Which arguments should be passed as variable references instead of values.
	 */
	public var refs (get, never) : Array<Int>;
	
	/**
	 * The name of this function
	 */
	public var name (default, null) : String;
	
	private var type:FunctionType;
	
	/**
	 * Constructor
	 * Don't invoke this directly!
	 * @param	name The name of the function.
	 */
	public function new(name:String)
	{
		this.name = name;
	}
	
	/**
	 * Call the funciton.
	 * @param	args an array of parameters to pass the function.
	 * @return The underlying function's return value, if any.
	 */
	public function call(args:Array<Dynamic>):Dynamic
	{
		throw "must override this method!";
		return null;
	}
	
	private var _refs:Array<Int>;
	function get_refs():Array<Int>
	{
		return _refs;
	}
	
	private var _argc:Int;
	function get_argc():Int
	{
		return _argc;
	}
}