package engine.objects;

import engine.states.PlayState;
import engine.utils.Paths;
import flixel.FlxSprite;
import flixel.animation.FlxAnimation;

class Character extends FlxSprite implements IPlayable
{
	public var playState:PlayState;

	public var character:String;

	public var arrowAnimations:Array<String> = ['left', 'down', 'up', 'right'];

	public function new(character:String)
	{
		super();
		changeCharacter(character);
	}

	public function changeCharacter(character:String):Void
	{
		if (this.character != character)
		{
			this.character = character;
			frames = Paths.sparrow('characters/' + character);
			addAnim('idle');
			addAnim('left');
			addAnim('down');
			addAnim('up');
			addAnim('right');
			addAnim('missleft');
			addAnim('missdown');
			addAnim('missup');
			addAnim('missright');
		}
	}

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);
		if (playState.isBeatHit)
		{
			onBeatHit(playState.curBeat);
		}
	}

	public function onBeatHit(beat:Int):Void
	{
		if (beat % 2 == 0)
		{
			var curAnim:FlxAnimation = animation.curAnim;
			if (curAnim == null || curAnim.finished)
			{
				playAnim('idle', true);
			}
		}
	}

	public function addAnim(animName:String, ?animPrefix:String):Void
	{
		if (animPrefix == null)
			animPrefix = animName;
		#if FLX_DEBUG
		var noAnim:Bool = true;
		@:privateAccess
		for (frame in animation._sprite.frames.frames)
		{
			if (frame.name != null && StringTools.startsWith(frame.name, animPrefix))
			{
				noAnim = false;
				break;
			}
		}

		if (noAnim)
			return;
		#end
		animation.addByPrefix(animName, animPrefix + '0', 24, false);
	}

	public function addAnimIndices(animName:String, ?animPrefix:String, indices:Array<Int>):Void
	{
		if (animPrefix == null)
			animPrefix = animName;
		animation.addByIndices(animName, animPrefix + '0', indices, '', 24, false);
	}

	public function playAnim(animName:String, force:Bool = false):Void
	{
		if (animation.exists(animName))
			animation.play(animName, force);
	}
}
