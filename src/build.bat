@echo OFF
rem	//	this probably won't work for you lol
haxe -swf slang.swc com.jacobalbano.slang3.ScriptEngine --macro include('com.jacobalbano')
haxe -js slang.js com.jacobalbano.slang3.ScriptEngine --macro include('com.jacobalbano')
haxe -neko slang.ndll com.jacobalbano.slang3.ScriptEngine --macro include('com.jacobalbano')
"C:\Program Files\7-Zip\7z.exe" a -tzip slang.zip haxelib.json com