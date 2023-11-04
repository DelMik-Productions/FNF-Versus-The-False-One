package versus.states;

import engine.effects.BlurEffect;
import engine.states.MusicBeatState;
import engine.utils.ClientPrefs;
import engine.utils.CoolUtil;
import engine.utils.MathUtil;
import engine.utils.Paths;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import openfl.geom.Matrix;
import openfl.text.TextField;
import openfl.text.TextFormat;

private class CreditIcon extends FlxSprite
{
	@:allow(versus.states.CreditState)
	private static var iconWidth:Float = 200.0;

	public final credits:CreditState;
	public final index:Int;

	public var name:String;
	public var description:String;
	public var link:String;

	private var effect:BlurEffect;
	private var difference:Float = 6.0;

	public function new(credits:CreditState, index:Int)
	{
		super();

		this.credits = credits;
		this.index = index;

		effect = new BlurEffect();
		shader = effect.shader;

		color.lightness = 0.2;
		effect.blurSize = 16.0;
		updateColorTransform();
	}

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		var lerpTo:Float = (credits.index > -1 ? Math.abs(credits.index - index) : credits.creditsLength - 1);
		difference = FlxMath.lerp(lerpTo, difference, 1.0 - MathUtil.clamp01(elapsed * 5.8));

		color.lightness = 1.0 - Math.min(difference, 2) * 0.4;
		effect.blurSize = difference * 4;
		updateColorTransform();
	}

	public function setCredit(name:String, description:String, link:String):CreditIcon
	{
		this.name = name;
		this.description = description;
		this.link = link;

		var original:FlxGraphic = Paths.image('credits/' + this.name);
		makeGraphic(200, 200, 0, false, 'creditIconOf' + this.name);

		_matrix.identity();
		_matrix.tx = (graphic.width - original.width) * 0.5;
		_matrix.ty = (graphic.height - original.height) * 0.5;

		graphic.bitmap.draw(original.bitmap, _matrix);
		return this;
	}
}

class CreditState extends MusicBeatState
{
	private static var lastIndex:Int = 0;

	public var index:Int = -1;
	public var creditsLength:Int = 0;

	private var credits:FlxTypedSpriteGroup<CreditIcon>;

	private var arrow:FlxSprite;

	private var label:FlxText;
	private var desc:FlxText;

	private var labelBlur:Float = 16.0;
	private var labelAlpha:Float = 0.0;

	private var freezed:Float = 0.0;

	private static inline var freezeTime:Float = 6.0;

	override function init():Void
	{
		camGame.bgColor = 0xff0b0c0f;

		credits = new FlxTypedSpriteGroup();
		add(credits);

		addCredit('Choma41', 'Director, Composer, Animator', 'https://twitter.com/Choma411');
		addCredit('delmik', 'from DELMIK PRODUCTIONS, Programmer', 'https://twitter.com/delmik__');
		addCredit('HSI', 'Concept assistance', 'https://twitter.com/hong_sam1004');
		addCredit('Saster', 'Owner of LookALike', 'https://twitter.com/sub0ru');
		addCredit('MarStarBro', 'Composer of Eye To Eye', 'https://twitter.com/MarstarMain');
		addCredit('Honkish', 'Known as Composer of Subterfuge', 'https://twitter.com/H0nkish');

		credits.screenCenter();

		var arrowGraphic:FlxGraphic = Paths.image('arrow');
		var focusedIcon:CreditIcon = credits.members[CreditState.lastIndex];
		var startX:Float = focusedIcon.x + (focusedIcon.width - arrowGraphic.width) * 0.5;
		arrow = new FlxSprite(startX, credits.y - (arrowGraphic.height * 0.5) - 20, arrowGraphic);
		arrow.scale.set(0.5, 0.5);
		arrow.updateHitbox();
		arrow.alpha = 0.0;
		arrow.angle = -90;
		add(arrow);

		label = new FlxText(0, 720);
		label.camera = camHUD;
		label.setFormat(Paths.font('arirang'), 64, FlxColor.BLACK, CENTER, OUTLINE, 0xff909090);
		add(label);

		desc = new FlxText(0, 780);
		desc.camera = camHUD;
		desc.setFormat(Paths.font('arirang'), 48, FlxColor.BLACK, CENTER, OUTLINE, 0xff909090);
		desc.text = 'Press LeftArrow or RightArrow to Select Credit Icon';
		desc.alpha = 0;
		add(desc);
	}

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (index < 0)
		{
			if (controls.UI_LEFT_P || controls.UI_RIGHT_P)
			{
				index = lastIndex;
				changeIndex(0);
			}
			if (controls.BACK)
			{
				MusicBeatState.switchState(new MainMenuState());
				FlxG.sound.play(Paths.sound('cancel'));
			}
		}
		else
		{
			if (controls.UI_LEFT_P && index > 0)
			{
				changeIndex(-1);
			}
			if (controls.UI_RIGHT_P && index < credits.length - 1)
			{
				changeIndex(1);
			}
			if (controls.ACCEPT && !(FlxG.keys.pressed.ALT && FlxG.keys.pressed.ENTER))
			{
				CoolUtil.browserLoad(credits.members[index].link);
			}
			if (controls.BACK)
			{
				lastIndex = index;
				index = -1;
				FlxG.sound.play(Paths.sound('cancel'));
			}
		}

		if (ClientPrefs.unfreezed)
		{
			freezed += elapsed;
			if (freezed > freezeTime)
			{
				index = 0;
			}
		}

		updateLabel(elapsed);
	}

	public function changeIndex(add:Int):Void
	{
		index = index + add;
		if (index > -1)
		{
			label.text = credits.members[index].name;
			desc.text = credits.members[index].description;
			labelBlur = 16.0;
		}
		FlxG.sound.play(Paths.sound('select'));
		ClientPrefs.unfreezed = false;
		freezed = 0.0;
	}

	public function updateLabel(elapsed:Float):Void
	{
		if (index > -1 || freezed > freezeTime)
		{
			labelBlur = FlxMath.lerp(0.0, labelBlur, 1.0 - MathUtil.clamp01(elapsed * 5.4));
			labelAlpha = FlxMath.lerp(1.0, labelAlpha, 1.0 - MathUtil.clamp01(elapsed * 3.14));
		}
		else
		{
			labelBlur = FlxMath.lerp(16.0, labelBlur, 1.0 - MathUtil.clamp01(elapsed * 3.14));
			labelAlpha = FlxMath.lerp(0.0, labelAlpha, 1.0 - MathUtil.clamp01(elapsed * 5.4));
		}

		// effect.blurSize = labelBlur;
		label.alpha = labelAlpha;
		label.screenCenter(X);
		label.x -= labelBlur;

		desc.alpha = labelAlpha;
		desc.screenCenter(X);
		desc.x -= labelBlur;

		var focusedIndex:Int = (index > -1 ? index : CreditState.lastIndex);
		var focusedIcon:CreditIcon = credits.members[focusedIndex];
		var lerpTo:Float = focusedIcon.x + (focusedIcon.width - arrow.width) * 0.5;
		arrow.x = FlxMath.lerp(lerpTo, arrow.x, 1.0 - MathUtil.clamp01(elapsed * 7.8));
		arrow.alpha = labelAlpha;
	}

	public function addCredit(name:String, description:String, link:String):Void
	{
		var creditIcon:CreditIcon = new CreditIcon(this, credits.length).setCredit(name, description, link);
		creditIcon.x = credits.length * (CreditIcon.iconWidth + 30);
		credits.add(creditIcon);
		creditsLength++;
	}
}
