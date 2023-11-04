package engine.objects.music;

import engine.states.PlayState;
import flixel.FlxSprite;

class MusicSprite extends FlxSprite implements IPlayable
{
	public var playState:PlayState;

	public var songPosition:Float = 0.0;
	public var tick:Int = 0;
	public var curBeat:Int = 0;
	public var curStep:Int = 0;

	public function onUpdate(songPosition:Float):Void
	{
		this.songPosition = songPosition;
	}

	public function onTick(tick:Int):Void
	{
		this.tick = tick;
	}

	public function onBeatHit(beat:Int):Void
	{
		curBeat = beat;
	}

	public function onStepHit(step:Int):Void
	{
		curStep = step;
	}

	public function onPause():Void
	{
	}

	public function onResume():Void
	{
	}

	public function onPrefsChanged():Void
	{
	}

	public function onKeyDown(i:Int):Void
	{
	}

	public function onKeyUp(i:Int):Void
	{
	}
}
