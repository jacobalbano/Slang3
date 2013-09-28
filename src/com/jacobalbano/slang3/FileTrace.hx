package com.jacobalbano.slang3;
import neko.Lib;
import sys.FileSystem;
import sys.io.File;

/**
 * ...
 * @author Jake Albano
 */
class FileTrace
{
	public static function setRedirection()
	{
		File.write("out.log", false).writeString("");
		haxe.Log.trace = myTrace;
	}

	private static function myTrace( v : Dynamic, ?inf : haxe.PosInfos )
	{
		var filename = "out.log";
		var fin = File.read(filename, false);
		var text = fin.readAll().toString();
		
		var fout = File.write(filename, false);
		
		var _in = Std.string(v);
		if (inf != null && inf.customParams != null)
		{
			_in += " " + inf.customParams.join(" ");
		}
		
		var out = text;
		if (out.length > 0)
		{
			out += "\n";
		}
		
		out += _in;
		
		fout.writeString(out);
		fout.close();
		
		Lib.println(_in);
	}	
}