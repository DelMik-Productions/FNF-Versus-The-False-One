package engine.substates;

import engine.effects.GradientEffect;
import engine.states.MusicBeatState;
import engine.states.PlayState;
import engine.utils.MathUtil;
import engine.utils.Paths;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import versus.states.MainMenuState;
import versus.substates.OptionSubState;

class PauseSubState extends MusicBeatSubState
{
	public final playState:PlayState;
	public final pausedPosition:Float;

	public var index:Int = 0;

	// public var pauseMusic:FlxSound;
	private var background:FlxSprite;
	private var safeArea:FlxTypedSpriteGroup<FlxText>;

	private var time:Float = 0.0;

	public function new(playState:PlayState, pausedPosition:Float)
	{
		super(playState);
		this.playState = playState;
		this.pausedPosition = pausedPosition;
	}

	override function create():Void
	{
		background = new FlxSprite();
		background.makeGraphic(1, 1);
		background.color = 0xff0b0c0f;
		background.scale.set(FlxG.width, FlxG.height);
		background.updateHitbox();
		background.alpha = 0.0;
		add(background);

		safeArea = new FlxTypedSpriteGroup();
		add(safeArea);

		var y:Float = 0.0;
		for (pauseMenu in ['Resume', 'Restart', 'Options', 'Exit'])
		{
			var label:FlxText = createLabel();
			label.text = pauseMenu;
			label.x = -label.width;
			label.y = y;
			safeArea.add(label);

			y = label.y + label.height + 10;
		}

		safeArea.screenCenter(Y);

		forEach(basic -> basic.camera = camOther);

		// pauseMusic = FlxG.sound.load(Paths.music('untitled'), 0, true);
		// pauseMusic.play(true, FlxG.random.float(0, pauseMusic.length / 2.0));
		// pauseMusic.fadeIn(100.0, 0.0, 0.5);

		persistentUpdate = true;
	}

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (closed)
		{
			if (time <= -1.0)
			{
				playState.closeSubState();
			}
		}
		else if (subState == null || ((subState is OptionSubState) && cast(subState, OptionSubState).closed))
		{
			if (controls.UI_UP_P)
				changeIndex(-1);
			if (controls.UI_DOWN_P)
				changeIndex(1);

			if (controls.ACCEPT)
			{
				switch (index)
				{
					case 0:
						resume();
					case 1:
						playState.reStart();
					case 2:
						openSubState(new OptionSubState(null));
					case 3:
						switchState(new MainMenuState());
				}
			}
			else if (controls.BACK)
			{
				resume();
			}
		}

		time += elapsed * (closed ? -1.0 : 1.0);

		background.alpha = MathUtil.clamp(time, 0.0, 0.2) * 3.0;
		updateLabels(elapsed);
	}

	public function updateLabels(elapsed:Float):Void
	{
		for (index => text in safeArea.members)
		{
			var lerpVal:Float = 1.0 - MathUtil.clamp01(elapsed * 8.5);
			var lerpToX:Float;
			if (closed)
			{
				lerpToX = -(text.width + 50);
			}
			else if (subState != null && (subState is OptionSubState) && !cast(subState, OptionSubState).closed)
			{
				lerpToX = (this.index == index ? 50 : 20);
			}
			else
			{
				lerpToX = (FlxG.width - text.width) * 0.5;
			}
			text.x = FlxMath.lerp(lerpToX, text.x, lerpVal);

			var textScale:Float = text.scale.x;
			var lerpToScale:Float;
			if (closed || (subState != null && (subState is OptionSubState) && !cast(subState, OptionSubState).closed))
			{
				lerpToScale = 1.0;
			}
			else
			{
				lerpToScale = (this.index == index ? 1.2 : 1.0);
			}
			textScale = FlxMath.lerp(lerpToScale, textScale, lerpVal);
			text.scale.set(textScale, textScale);
		}
	}

	public function resume():Void
	{
		playState.songPositionOffset = playState.getSystemMillisecondsFromStarted() - pausedPosition;
		playState.resume();

		closed = true;
		time = Math.min(0.2, time);
		// pauseMusic.fadeOut(time, 0.0);
	}

	public function changeIndex(add:Int):Void
	{
		index = MathUtil.repeatInt(index + add, 4);
		FlxG.sound.play(Paths.sound('select'));
	}

	private function switchState(nextState:MusicBeatState):Void
	{
		MusicBeatState.switchState(nextState);
		// pauseMusic.fadeOut(Math.min(0.2, time), 0.0);
	}

	private function createLabel():FlxText
	{
		var label:FlxText = new FlxText();
		label.setFormat(Paths.font('arirang'), 84, 0xff46495b, RIGHT, OUTLINE, 0xff17181e);
		label.borderSize = 4;
		return label;
	}

	override function destroy():Void
	{
		// pauseMusic.destroy();
		super.destroy();
	}
}
