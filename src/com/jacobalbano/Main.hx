package com.jacobalbano;
#if neko
import com.jacobalbano.slang3.FileTrace;
#end

import com.jacobalbano.slang3.ScriptEngine;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.Event;
import flash.Lib;
import openfl.Assets;

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
		#if neko
		FileTrace.setRedirection();
		#end
	}
	
	function init(e) 
	{
		var source = Assets.getText("assets/source.s");
		
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
