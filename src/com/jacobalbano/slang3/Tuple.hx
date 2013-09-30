package com.jacobalbano.slang3;
using com.jacobalbano.slang3.Utils;

/**
 * A simple data structure that contains script identifier names.
 */
class Tuple
{
	/**
	 * How many IDs are contained in this Tuple.
	 */
	public var count (get, never) : Int;
	@:allow(com.jacobalbano.slang3) var IDs:Array<String>;
	
	/**
	 * Constructor.
	 * @param	IDs An array of strings to use as IDs.
	 */
	public function new(IDs:Array<String>) 
	{
		this.IDs = [];
		
		for (id in IDs)
		{
			if (this.IDs.indexOf(id) >= 0)
			{
				throw "A tuple cannot contain the same value twice!";
			}
			
			this.IDs.push(id);
		}
	}
	
	public function toString():String
	{
		return "[object Tuple] (" + IDs.join(", ") + ")";
	}
	
	function get_count():Int
	{
		return IDs.length;
	}
}