package versus.states;

import engine.effects.ColorInvertEffect;
import engine.states.MusicBeatState;
import engine.utils.ClientPrefs;
import engine.utils.MathUtil;
import engine.utils.Paths;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import versus.substates.CheckSubState;
import versus.substates.OptionSubState;

private enum abstract MainMenu(String) to String
{
	var PLAY = 'play';
	var OPTIONS = 'options';
	var CREDITS = 'credits';
	var YES = 'yes';
	var NO = 'no';
}

@:noCompletion
@:access(versus.states.MainMenuState)
class MainMenuButton extends FlxSprite
{
	public final mainmenu:Dynamic;
	public final index:Int;

	public var scaleVal:Float = 0.12;

	private var maxVib:Float = 0.0;
	private var effect:ColorInvertEffect = new ColorInvertEffect();

	public function new(mainmenu:Dynamic, index:Int, menu:MainMenu)
	{
		super();

		this.mainmenu = mainmenu;
		this.index = index;

		shader = effect.shader;

		loadGraphic(Paths.image('menus/' + menu));
		color = 0xffcdd5ff;

		maxVib = (mainmenu.index == index ? 1.0 : 0.0);
	}

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		var lerpTo:Float = (mainmenu.index == index ? 1.0 : 0.0);
		maxVib = FlxMath.lerp(lerpTo, maxVib, 1.0 - MathUtil.clamp01(elapsed * 2.2));

		effect.ratio = maxVib;
		offset.set(getVib(), getVib());
		scale.set(1.0 + maxVib * scaleVal, 1.0 + maxVib * scaleVal);
	}

	private function getVib():Float
	{
		return (FlxG.random.float(0.0, 1.0) - 0.5) * maxVib * 6.0;
	}
}

class MainMenuState extends MusicBeatState
{
	private static var _index:Int = 0;

	public var index:Int = _index;

	private var menus:FlxTypedSpriteGroup<MainMenuButton>;
	private var arrow:FlxSprite;

	private var maxScore:FlxText;

	override function init():Void
	{
		var background:FlxSprite = new FlxSprite(Paths.image('background'));
		add(background);

		menus = new FlxTypedSpriteGroup();
		add(menus);

		addMenu(PLAY);
		addMenu(OPTIONS);
		addMenu(CREDITS);

		menus.x += 150;
		menus.screenCenter(Y);

		var arrowGraphic:FlxGraphic = Paths.image('arrow');
		var startX:Float = menus.members[index].x + menus.members[index].width + 150;
		var startY:Float = menus.members[index].y + (menus.members[index].height - arrowGraphic.height) * 0.5;
		arrow = new FlxSprite(startX, startY, arrowGraphic);
		add(arrow);

		maxScore = new FlxText(FlxG.width, 20);
		maxScore.setFormat(Paths.font('arirang'), 64, 0xff46495b, LEFT, OUTLINE, 0xff17181e);
		maxScore.borderSize = 2.0;
		maxScore.text = (ClientPrefs.played && ClientPrefs.maxScore > 0.0 ? 'MaxScore: ${Std.int(ClientPrefs.maxScore)}' : '');
		add(maxScore);

		FlxG.sound.playMusic(Paths.music('title'), 0.0);
		FlxG.sound.music.fadeIn(0.5);
		persistentUpdate = true;
	}

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (musicSubState == null || (musicSubState is OptionSubState && cast(musicSubState, OptionSubState).closed))
		{
			if (controls.UI_UP_P)
				selectMenu(-1);
			if (controls.UI_DOWN_P)
				selectMenu(1);
			if (controls.ACCEPT)
				confirmMenu();
		}

		var lerpToX:Float = menus.members[index].x + menus.members[index].width + 150;
		var lerpToY:Float = menus.members[index].y + (menus.members[index].height - arrow.height) * 0.5;
		var lerpVal:Float = 1.0 - MathUtil.clamp01(elapsed * 9.4);
		arrow.x = FlxMath.lerp(lerpToX, arrow.x, lerpVal);
		arrow.y = FlxMath.lerp(lerpToY, arrow.y, lerpVal);

		lerpToX = FlxG.width;
		if (index == 0)
			lerpToX -= maxScore.width + 20;
		maxScore.x = FlxMath.lerp(lerpToX, maxScore.x, 1.0 - MathUtil.clamp01(elapsed * 11.2));
	}

	public function selectMenu(add:Int):Void
	{
		_index = index = MathUtil.repeatInt(index + add, menus.length);
		FlxG.sound.play(Paths.sound('select'));
	}

	public function confirmMenu():Void
	{
		switch (index)
		{
			case 0:
				openMusicSubState(new CheckSubState(this));
			case 1:
				openMusicSubState(new OptionSubState(this));
			case 2:
				MusicBeatState.switchState(new CreditState());
		}
		FlxG.sound.play(Paths.sound('confirm')).persist = true;
	}

	public function addMenu(menu:MainMenu):Void
	{
		var menuButton:MainMenuButton = new MainMenuButton(this, menus.length, menu);
		if (menus.length > 0)
		{
			var last = menus.members[menus.length - 1];
			menuButton.y = last.y + last.height + 50;
		}
		menus.add(menuButton);
	}
}
