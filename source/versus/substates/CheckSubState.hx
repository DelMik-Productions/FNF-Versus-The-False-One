package versus.substates;

import engine.states.MusicBeatState;
import engine.substates.MusicBeatSubState;
import engine.utils.MathUtil;
import engine.utils.Paths;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxShader;
import versus.states.MainMenuState;
import versus.states.PlayState;

class CheckSubState extends MusicBeatSubState
{
	public var index:Int = 0;

	private var background:FlxSprite;
	private var label:FlxSprite;
	private var yesText:MainMenuButton;
	private var noText:MainMenuButton;

	private var time:Float = 0.0;
	private var tick:Int = 0;

	override function create():Void
	{
		background = new FlxSprite();
		background.makeGraphic(1, 1);
		background.color = 0xff0b0c0f;
		background.scale.set(FlxG.width, FlxG.height);
		background.updateHitbox();
		background.alpha = 0.0;
		add(background);

		label = new FlxSprite(Paths.image('menus/areyousure'));
		label.alpha = 0.0;
		label.screenCenter(X);
		label.y = (FlxG.height / 3) - (label.height * 0.5);
		add(label);

		yesText = new MainMenuButton(this, 0, YES);
		yesText.shader = new FlxShader();
		yesText.color = 0xffffffff;
		yesText.scaleVal = 0.4;
		yesText.alpha = 0.0;
		yesText.x = (label.x + label.width / 4) - (yesText.width * 0.5);
		yesText.y = (FlxG.height / 3 * 2) - (yesText.height * 0.5);
		add(yesText);

		noText = new MainMenuButton(this, 1, NO);
		noText.shader = new FlxShader();
		noText.color = 0xffffffff;
		noText.scaleVal = 0.4;
		noText.alpha = 0.0;
		noText.x = (label.x + label.width / 4 * 3) - (noText.width * 0.5);
		noText.y = (FlxG.height / 3 * 2) - (noText.height * 0.5);
		add(noText);
	}

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (closed)
		{
			if (time <= -0.5)
			{
				_parentState.closeSubState();
			}
		}
		else if (tick > 0)
		{
			if (controls.UI_LEFT_P)
				changeIndex(-1);
			if (controls.UI_RIGHT_P)
				changeIndex(1);

			if (controls.ACCEPT)
			{
				switch (index)
				{
					case 0:
						yes();
					case 1:
						no();
				}
			}
			else if (controls.BACK)
			{
				no();
			}
		}

		time += elapsed * (closed ? -1.0 : 1.0);
		background.alpha = MathUtil.clamp(time, 0.0, 0.2) * 3.0;
		label.alpha = MathUtil.clamp(time, 0.0, 0.2) * 5.0;
		yesText.alpha = MathUtil.clamp(time, 0.0, 0.2) * 5.0;
		noText.alpha = MathUtil.clamp(time, 0.0, 0.2) * 5.0;

		tick++;
	}

	public function changeIndex(add:Int):Void
	{
		index = MathUtil.repeatInt(index + add, 4);
		FlxG.sound.play(Paths.sound('select'));
	}

	public function yes():Void
	{
		MusicBeatState.switchState(new PlayState());
		if (FlxG.sound.music != null)
			FlxG.sound.music.fadeOut(0.5);
		FlxG.sound.play(Paths.sound('confirm')).persist = true;
	}

	public function no():Void
	{
		time = MathUtil.clamp(time, 0.0, 0.2);
		closed = true;
		FlxG.sound.play(Paths.sound('cancel'));
	}
}
