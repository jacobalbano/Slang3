package com.jacobalbano.slang3;

/**
 * ...
 * @author Jake Albano
 */
class Utils
{
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