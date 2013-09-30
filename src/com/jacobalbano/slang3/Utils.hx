package com.jacobalbano.slang3;

/**
 * Utility stuff.
 */
class Utils
{
	/**
	 * Get the index of an item in an array, or -1 if the item does not exist.
	 */
	public static function indexOf<T>(a:Array<T>, v:T):Int
	{
		var i = 0;
		
		for (v2 in a)
		{
			if( v == v2 ) return i;
			i++;
		}
		
		return -1;
	}
	
}