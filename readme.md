Slang is an experimental stack-based scripting language for Haxe.

### Usage
```actionscript
var source:String = getSource(); // load Slang code into a string

var engine = new ScriptEngine();
var scope = engine.compile(source);
scope.execute();
```

### Example code
```
func greet (name) {
    print string:format "Hello, {0}!" [name]
}

greet "World"
```
### Installation
Slang is on Haxelib:
```shell
haxelib install slang
```