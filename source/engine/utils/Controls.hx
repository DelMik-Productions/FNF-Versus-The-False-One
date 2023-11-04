package engine.utils;

import engine.utils.CoolUtil;
import flixel.FlxG;
import flixel.input.FlxInput;
import flixel.input.keyboard.FlxKey;
import flixel.util.FlxSave;

using StringTools;

/**
 * 
 * Add the Control.
 * You can set the input type of the key by specifying metadata.
 * 
 * - @:all          A (pressed A, justPressed A_P, justReleased A_R)
 * - @:pressed      A
 * - @:justPressed  A
 * - @:justReleased A
 * - @:released     A (only specified)
 */
enum Control
{
	@:all UI_UP;
	@:all UI_LEFT;
	@:all UI_RIGHT;
	@:all UI_DOWN;
	@:all NOTE_UP;
	@:all NOTE_LEFT;
	@:all NOTE_RIGHT;
	@:all NOTE_DOWN;
	@:justPressed RESET;
	@:justPressed ACCEPT;
	@:justPressed BACK;
	@:justPressed PAUSE;
}

@:build(macros.ControlPropsGenerator.generate(Control))
class Controls
{
	public static var instance(default, null):Controls;

	public static function init():Void
	{
		instance = new Controls();

		for (control in Control.createAll())
		{
			var keys:Array<FlxKey> = Reflect.getProperty(ClientPrefs, control.getName());
			instance.changeKeys(control, keys[0], keys[1]);
		}
	}

	#if debug
	var _debug:Action = new Action(0);

	public var DEBUG(get, never):Bool;

	inline function get_DEBUG():Bool
		return _debug.check();
	#end

	public function new()
	{
	}

	public function changeKeys(control:Control, key:FlxKey, ?alt:FlxKey):Void
	{
		var field:String = '_' + control.getName().toLowerCase();
		if (alt == null)
			alt = Reflect.getProperty(ClientPrefs, control.getName())[1];

		CoolUtil.callMethod(Reflect.field(this, field), 'change', key, alt);

		if (Reflect.field(this, field + '_p') != null)
			CoolUtil.callMethod(Reflect.field(this, field + '_p'), 'change', key, alt);

		if (Reflect.field(this, field + '_r') != null)
			CoolUtil.callMethod(Reflect.field(this, field + '_r'), 'change', key, alt);

		Reflect.setProperty(ClientPrefs, control.getName(), [key, alt]);
	}
}

class Action
{
	public var state:FlxInputState;
	public var inputs(get, set):Array<FlxKey>;

	var _inputs:Array<FlxKey> = [NONE, NONE];

	public function new(State:FlxInputState)
	{
		state = State;
		_inputs = [];
	}

	public function check():Bool
	{
		var pressed:Bool = false;

		for (input in _inputs)
		{
			if (input != NONE && FlxG.keys.checkStatus(input, state))
				return true;
		}

		return pressed;
	}

	public function change(?Main:FlxKey, ?Alt:FlxKey):Void
	{
		if (Main != null)
			_inputs[0] = Main;

		if (Alt != null)
			_inputs[1] = Alt;
	}

	private function get_inputs():Array<FlxKey>
	{
		return _inputs.filter(input -> input != NONE);
	}

	private function set_inputs(value:Array<FlxKey>):Array<FlxKey>
	{
		change(value[0], value[1]);
		return _inputs;
	}
}
