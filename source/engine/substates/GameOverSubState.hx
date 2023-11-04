package engine.substates;

import engine.states.MusicBeatState;
import engine.utils.MathUtil;
import engine.utils.Paths;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import versus.states.MainMenuState;
import versus.states.PlayState;

class GameOverSubState extends MusicBeatSubState
{
	public var canSkip:Bool = false;

	private var label:FlxText;
	private var alpha = 0.0;

	override function create():Void
	{
		super.create();

		var board:FlxSprite = new FlxSprite();
		board.camera = camOther;
		board.makeGraphic(1, 1);
		board.scale.set(FlxG.width, FlxG.height);
		board.updateHitbox();
		board.color = FlxColor.BLACK;
		add(board);

		label = new FlxText(0, 0, FlxG.width, 'Retry?');
		label.camera = camOther;
		label.setFormat(Paths.font('arirang'), 128, FlxColor.BLACK, CENTER, OUTLINE, 0xff909090);
		label.borderSize = 4.0;
		label.alpha = 0.0;
		label.screenCenter();
		add(label);

		_parentState.persistentUpdate = false;

		FlxG.sound.play(Paths.sound('fnf_loss_sfx'), onCompleteInitSFX);
	}

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (canSkip)
		{
			if (controls.ACCEPT)
			{
				MusicBeatState.switchState(new PlayState());
				FlxG.sound.play(Paths.sound('retry')).persist = true;
				FlxG.sound.music.fadeOut(0.45);
				canSkip = false;
				alpha = 0.0;
			}
			else if (controls.BACK)
			{
				MusicBeatState.switchState(new MainMenuState());
				FlxG.sound.play(Paths.sound('cancel'));
				canSkip = false;
				alpha = 0.0;
			}
		}

		label.alpha = FlxMath.lerp(alpha, label.alpha, 1.0 - MathUtil.clamp01(elapsed * 9.8));
	}

	private function onCompleteInitSFX():Void
	{
		FlxG.sound.playMusic(Paths.music('gameover'));
		canSkip = true;
		alpha = 1.0;
	}
}
