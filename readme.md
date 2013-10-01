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
#### Haxe
Slang is on Haxelib:
```shell
haxelib install slang
```

#### Actionscript
If you want to use Slang in a Flash project, you can download the .swc from the downloads page.
Before a SWC built with Haxe can be used, the Haxe subsystem must be initialized:

```actionscript
haxe.initSwc(MovieClip(root));
```

#### Javascript
Download the .js file in the downloads page and do javascript things with it. I haven't tested it at all.

#### Neko
I only use Neko as a Haxe target, so I also haven't tested out the neko build. You can get the .ndll file from the downloads page and do with it what you will.