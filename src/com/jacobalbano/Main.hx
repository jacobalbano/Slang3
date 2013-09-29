package com.jacobalbano;
import com.jacobalbano.slang3.ScriptEngine;
import flash.display.Sprite;
import flash.events.Event;
import flash.Lib;

/**
 * ...
 * @author Jake Albano
 */

class Main extends Sprite 
{
	public function new() 
	{
		super();	
		addEventListener(Event.ADDED_TO_STAGE, init);
	}
	
	function init(e) 
	{
		var source =
		'func greet (name) { ' + 
		'	printf "Hello, {0}!" [name] ' + 
		'} ' + 
		'greet "Jake"';
		
		var engine = new ScriptEngine();
		var scope = engine.compile(source);
		scope.execute();
	}

	public static function main() 
	{
		// static entry point
		Lib.current.stage.align = flash.display.StageAlign.TOP_LEFT;
		Lib.current.stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
		Lib.current.addChild(new Main());
	}
}
