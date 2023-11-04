package engine.objects;

import engine.objects.music.MusicSprite;
import engine.utils.Paths;
import flixel.animation.FlxAnimation;

class Character extends MusicSprite
{
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

	override function onBeatHit(beat:Int):Void
	{
		super.onBeatHit(beat);

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
