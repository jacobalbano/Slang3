package com.jacobalbano.slang3.functions;
import com.jacobalbano.slang3.Scope;

/**
 * ...
 * @author Jake Albano
 */

enum FunctionType
{
	Function;
	Procedure;
}
 
class SlangFunction
{
	private static var EMPTY_REFS:Array<Int> = [];

	@:allow(com.jacobalbano.slang3) var context:Scope;	
	public var argc (get, never) : Int;
	public var refs (get, never) : Array<Int>;
	
	private var type:FunctionType;
	
	public function prepare(context:Scope):Void
	{
	}
	
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