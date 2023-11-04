package engine.utils;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.input.keyboard.FlxKey;
import flixel.util.FlxSave;
import openfl.Lib;

@:build(macros.RuntimeSharedFieldsBuilder.build())
@:build(macros.StaticaFieldsBuilder.build())
class ClientPrefs
{
	public var frameRate(get, set):Int;
	public var antialiasing(get, set):Bool;

	@:field public var downScroll:Bool = false;
	@:field public var played:Bool = false;
	@:field public var maxScore:Float = 0.0;

	@:allow(versus.states.CreditState)
	@:field private var unfreezed:Bool = true;

	@:field @:allow(engine.utils.Controls) var UI_UP:Array<FlxKey> = [FlxKey.UP, FlxKey.NONE];
	@:field @:allow(engine.utils.Controls) var UI_LEFT:Array<FlxKey> = [FlxKey.LEFT, FlxKey.NONE];
	@:field @:allow(engine.utils.Controls) var UI_RIGHT:Array<FlxKey> = [FlxKey.RIGHT, FlxKey.NONE];
	@:field @:allow(engine.utils.Controls) var UI_DOWN:Array<FlxKey> = [FlxKey.DOWN, FlxKey.NONE];
	@:field @:allow(engine.utils.Controls) var NOTE_UP:Array<FlxKey> = [FlxKey.J, FlxKey.UP];
	@:field @:allow(engine.utils.Controls) var NOTE_LEFT:Array<FlxKey> = [FlxKey.D, FlxKey.LEFT];
	@:field @:allow(engine.utils.Controls) var NOTE_RIGHT:Array<FlxKey> = [FlxKey.K, FlxKey.RIGHT];
	@:field @:allow(engine.utils.Controls) var NOTE_DOWN:Array<FlxKey> = [FlxKey.F, FlxKey.DOWN];
	@:field @:allow(engine.utils.Controls) var RESET:Array<FlxKey> = [FlxKey.R, FlxKey.NONE];
	@:field @:allow(engine.utils.Controls) var ACCEPT:Array<FlxKey> = [FlxKey.SPACE, FlxKey.ENTER];
	@:field @:allow(engine.utils.Controls) var BACK:Array<FlxKey> = [FlxKey.ESCAPE, FlxKey.BACKSPACE];
	@:field @:allow(engine.utils.Controls) var PAUSE:Array<FlxKey> = [FlxKey.ESCAPE, FlxKey.ENTER];

	@:field var _frameRate:Int = -1;
	@:field var _antialiasing:Bool = true;

	@:field var _initialized:Bool = false;

	public function init():Void
	{
		_conn = new FlxSave();
		_conn.bind('ClientPrefs');

		#if debug
		// _conn.data._antialiasing = null;
		// _conn.data.downScroll = null;
		// _conn.data.unfreezed = null;
		// _conn.data.UI_UP = null;
		// _conn.data.UI_LEFT = null;
		// _conn.data.UI_RIGHT = null;
		// _conn.data.UI_DOWN = null;
		// _conn.data.NOTE_UP = null;
		// _conn.data.NOTE_LEFT = null;
		// _conn.data.NOTE_RIGHT = null;
		// _conn.data.NOTE_DOWN = null;
		// _conn.data.RESET = null;
		// _conn.data.ACCEPT = null;
		// _conn.data.BACK = null;
		// _conn.data.PAUSE = null;
		_conn.data.played = false;
		_conn.data.maxScore = 0.0;
		#end

		if (frameRate > FlxG.drawFramerate)
		{
			FlxG.updateFramerate = frameRate;
			FlxG.drawFramerate = frameRate;
		}
		else
		{
			FlxG.drawFramerate = frameRate;
			FlxG.updateFramerate = frameRate;
		}

		FlxSprite.defaultAntialiasing = antialiasing;

		if (_initialized == false)
		{
			_initialized = true;
		}
	}

	private function get_frameRate():Int
	{
		if (_frameRate < 1)
			return Lib.application.window.displayMode.refreshRate;
		return _frameRate;
	}

	private function set_frameRate(value:Int):Int
	{
		return _frameRate = value;
	}

	private function get_antialiasing():Bool
	{
		return _antialiasing;
	}

	private function set_antialiasing(value:Bool):Bool
	{
		FlxSprite.defaultAntialiasing = value;
		_antialiasing = value;
		return _antialiasing;
	}
}
