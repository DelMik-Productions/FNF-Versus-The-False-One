package versus.substates;

import engine.effects.GradientEffect;
import engine.objects.Note;
import engine.states.PlayState;
import engine.substates.MusicBeatSubState;
import engine.utils.ClientPrefs;
import engine.utils.MathUtil;
import engine.utils.Paths;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxSpriteGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class OptionSubState extends MusicBeatSubState
{
	private static var index:Int = 0;
	private static var arrowIndex:Int = 0;

	private var background:FlxSprite;
	private var safeArea:FlxSpriteGroup;
	private var labels:Array<FlxText> = [];

	private var strumNotes:FlxSpriteGroup;
	private var arrowlabels:Array<FlxText> = [];

	private var effect:GradientEffect;
	private var frame:Int = 0;

	override function create():Void
	{
		background = new FlxSprite();
		background.makeGraphic(FlxG.height, FlxG.width, 0);
		background.screenCenter();
		background.angle = -90;
		add(background);

		effect = new GradientEffect(0xff17181e, 0, FlxG.width / 5 * 3, 0);
		effect.offset = FlxG.width / 5 * 3;
		background.shader = effect.shader;

		safeArea = new FlxSpriteGroup();
		add(safeArea);

		var antialiasing:FlxText = createLabel();
		antialiasing.x = 30;
		antialiasing.text = (ClientPrefs.antialiasing ? 'Antialiasing' : 'No Antialiasing');
		antialiasing.offset.x = -20;
		labels.push(antialiasing);
		safeArea.add(antialiasing);

		var downScroll:FlxText = createLabel();
		downScroll.x = 30;
		downScroll.y = antialiasing.y + antialiasing.height;
		downScroll.text = (ClientPrefs.downScroll ? 'DownScroll' : 'UpScroll');
		labels.push(downScroll);
		safeArea.add(downScroll);

		var strumNoteLabel:FlxText = createLabel();
		strumNoteLabel.color = 0xff5b5f76;
		strumNoteLabel.fieldWidth = 0;
		strumNoteLabel.text = '~ StrumNotes ~';
		strumNoteLabel.size = 96;
		strumNoteLabel.x = FlxG.width - strumNoteLabel.width + 30;
		strumNoteLabel.y = downScroll.y + downScroll.height + 10;
		labels.push(strumNoteLabel);
		safeArea.add(strumNoteLabel);

		strumNotes = new FlxSpriteGroup();
		safeArea.add(strumNotes);

		@:privateAccess
		for (i in 0...4)
		{
			var brightness:Float = (index == 2 && arrowIndex == i ? 1.0 : 0.6);

			var note:Note = new Note(i);
			note.x = note.width * i;
			note.color = FlxColor.fromHSB(0.0, 0.0, brightness);
			strumNotes.add(note);

			var label:FlxText = new FlxText();
			label.setFormat(Paths.font('pixel'), 64, FlxColor.WHITE);
			label.text = switch (i)
			{
				case 0: getString(ClientPrefs.NOTE_LEFT[0]);
				case 1: getString(ClientPrefs.NOTE_DOWN[0]);
				case 2: getString(ClientPrefs.NOTE_UP[0]);
				case 3: getString(ClientPrefs.NOTE_RIGHT[0]);
				default: '';
			}
			label.x = note.x + (note.width - label.width) * 0.5;
			label.y = note.y + (note.height - label.height) * 0.5;
			label.color = FlxColor.fromHSB(0.0, 0.0, brightness);
			arrowlabels.push(label);
			strumNotes.add(label);
		}

		strumNotes.x = strumNoteLabel.x + (strumNoteLabel.width - strumNotes.width) * 0.5 - 20;
		strumNotes.y = strumNoteLabel.y + strumNoteLabel.height;

		var resetKey:FlxText = createLabel();
		resetKey.x = 30;
		resetKey.y = strumNotes.y + strumNotes.height + 10;
		@:privateAccess
		resetKey.text = 'Reset Key: ' + getString(ClientPrefs.RESET[0]);
		labels.push(resetKey);
		safeArea.add(resetKey);

		safeArea.screenCenter(Y);

		var camOther:FlxCamera = FlxG.cameras.list[FlxG.cameras.list.length - 1];
		forEach(basic -> basic.camera = camOther);
	}

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (closed)
		{
			if (effect.offset >= FlxG.width + 100)
				close();
			effect.offset = FlxMath.lerp(FlxG.width + 200, effect.offset, 1.0 - MathUtil.clamp01(elapsed * 8.2));
			safeArea.x = FlxMath.lerp(800, safeArea.x, 1.0 - MathUtil.clamp01(elapsed * 11.6));
			return;
		}

		if (controls.UI_UP_P)
			changeIndex(-1);
		if (controls.UI_DOWN_P)
			changeIndex(1);

		if (frame > 0 && index < 2 && controls.ACCEPT && !(FlxG.keys.pressed.ALT && FlxG.keys.pressed.ENTER))
		{
			switch (index)
			{
				case 0:
					ClientPrefs.antialiasing = !ClientPrefs.antialiasing;
					labels[0].text = (ClientPrefs.antialiasing ? 'Antialiasing' : 'No Antialiasing');
					labels[0].x = 30;

					var state:FlxState = FlxG.state;
					while (state != null)
					{
						state.forEachOfType(FlxSprite, sprite -> sprite.antialiasing = ClientPrefs.antialiasing, true);
						state = state.subState;
					}
				case 1:
					ClientPrefs.downScroll = !ClientPrefs.downScroll;
					labels[1].text = ((ClientPrefs.downScroll ? 'DownScroll' : 'UpScroll'));
					labels[1].x = 30;
			}
			sendPrefsChangeEvent();
			FlxG.sound.play(Paths.sound('select'));
		}

		if (frame > 0 && (index == 2 || index == 3))
		{
			@:privateAccess
			var oldKey:FlxKey = ClientPrefs.RESET[0];
			if (index == 2)
			{
				@:privateAccess
				oldKey = switch (arrowIndex)
				{
					case 0: ClientPrefs.NOTE_LEFT[0];
					case 1: ClientPrefs.NOTE_DOWN[0];
					case 2: ClientPrefs.NOTE_UP[0];
					case 3: ClientPrefs.NOTE_RIGHT[0];
					default: FlxKey.NONE;
				}

				if (controls.UI_LEFT_P)
					changeArrowIndex(-1);
				if (controls.UI_RIGHT_P)
					changeArrowIndex(1);
			}

			var newKey:Int = FlxG.keys.firstJustPressed();
			if (newKey > -1)
			{
				@:privateAccess
				if ((newKey > 64 && newKey < 91) || (newKey > 48 && newKey < 58) || (newKey > 96 && newKey < 112) || newKey == FlxKey.LBRACKET
					|| newKey == FlxKey.RBRACKET || newKey == FlxKey.SEMICOLON || newKey == FlxKey.QUOTE || newKey == FlxKey.COMMA
					|| newKey == FlxKey.PERIOD || newKey == FlxKey.SLASH)
				{
					if (index == 2)
					{
						switch (arrowIndex)
						{
							case 0:
								controls.changeKeys(NOTE_LEFT, newKey);
							case 1:
								controls.changeKeys(NOTE_DOWN, newKey);
							case 2:
								controls.changeKeys(NOTE_UP, newKey);
							case 3:
								controls.changeKeys(NOTE_RIGHT, newKey);
						}
					}
					else if (index == 3)
					{
						controls.changeKeys(RESET, newKey);
						labels[3].x = 30;
					}

					if (!(index == 2 && arrowIndex == 0) && ClientPrefs.NOTE_LEFT[0] == newKey)
						controls.changeKeys(NOTE_LEFT, oldKey);
					if (!(index == 2 && arrowIndex == 1) && ClientPrefs.NOTE_DOWN[0] == newKey)
						controls.changeKeys(NOTE_DOWN, oldKey);
					if (!(index == 2 && arrowIndex == 2) && ClientPrefs.NOTE_UP[0] == newKey)
						controls.changeKeys(NOTE_UP, oldKey);
					if (!(index == 2 && arrowIndex == 3) && ClientPrefs.NOTE_RIGHT[0] == newKey)
						controls.changeKeys(NOTE_RIGHT, oldKey);
					if (index != 3 && ClientPrefs.RESET[0] == newKey)
						controls.changeKeys(RESET, oldKey);
					sendPrefsChangeEvent();

					if (index == 2)
						arrowIndex = MathUtil.repeatInt(arrowIndex + 1, 4);
					FlxG.sound.play(Paths.sound('select'));

					arrowlabels[0].text = getString(ClientPrefs.NOTE_LEFT[0]);
					arrowlabels[1].text = getString(ClientPrefs.NOTE_DOWN[0]);
					arrowlabels[2].text = getString(ClientPrefs.NOTE_UP[0]);
					arrowlabels[3].text = getString(ClientPrefs.NOTE_RIGHT[0]);
					for (i in 0...4)
					{
						var label:FlxText = arrowlabels[i];
						var arrow:FlxSprite = strumNotes.members[i * 2];
						label.x = arrow.x + (arrow.width - label.width) * 0.5;
						label.y = arrow.y + (arrow.height - label.height) * 0.5;
					}
					labels[3].text = 'Reset Key: ' + getString(ClientPrefs.RESET[0]);
				}
			}
		}

		@:privateAccess
		for (i in 0...4)
		{
			var strumNote:FlxSprite = strumNotes.members[i * 2];
			var label:FlxSprite = strumNotes.members[i * 2 + 1];

			label.x = strumNote.x + (strumNote.width - label.width) * 0.5;
			label.y = strumNote.y + (strumNote.height - label.height) * 0.5;

			var lerpTo:Float = (index == 2 && arrowIndex == i ? 1.0 : 0.6);
			var lerpVal:Float = 1.0 - MathUtil.clamp01(elapsed * 8.5);
			strumNote.color = FlxColor.fromHSB(0.0, 0.0, FlxMath.lerp(lerpTo, strumNote.color.brightness, lerpVal));
			label.color = FlxColor.fromHSB(0.0, 0.0, FlxMath.lerp(lerpTo, strumNote.color.brightness, lerpVal));
		}

		var lerpVal:Float = 1.0 - MathUtil.clamp01(elapsed * 12.9);
		labels[0].x = FlxMath.lerp(-20 + (index == 0 ? -30 : 0), labels[0].x, lerpVal);
		labels[1].x = FlxMath.lerp(-20 + (index == 1 ? -30 : 0), labels[1].x, lerpVal);
		labels[2].x = FlxMath.lerp(FlxG.width - labels[2].width - 20, labels[2].x, lerpVal);
		labels[3].x = FlxMath.lerp(-20 + (index == 3 ? -30 : 0), labels[3].x, lerpVal);
		strumNotes.x = labels[2].x + (labels[2].width - strumNotes.width) * 0.5;

		effect.offset = FlxMath.lerp(FlxG.width - effect.top, effect.offset, 1.0 - MathUtil.clamp01(elapsed * 18.2));

		if (frame > 0 && controls.BACK)
		{
			closed = true;
			FlxG.sound.play(Paths.sound('cancel'));
		}
		frame++;
	}

	public function changeIndex(add:Int):Void
	{
		index = MathUtil.repeatInt(index + add, labels.length);
		FlxG.sound.play(Paths.sound('select'));
	}

	public function changeArrowIndex(add:Int):Void
	{
		arrowIndex = MathUtil.repeatInt(arrowIndex + add, 4);
		FlxG.sound.play(Paths.sound('select'));
	}

	public function sendPrefsChangeEvent():Void
	{
		var state:FlxState = FlxG.state;
		while (state != null)
		{
			if (state is PlayState)
			{
				cast(state, PlayState).onPrefsChanged();
				break;
			}
			state = state.subState;
		}
	}

	private function getString(key:FlxKey):String
	{
		return switch (key)
		{
			case FlxKey.ONE | FlxKey.NUMPADONE: '1';
			case FlxKey.TWO | FlxKey.NUMPADTWO: '2';
			case FlxKey.THREE | FlxKey.NUMPADTHREE: '3';
			case FlxKey.FOUR | FlxKey.NUMPADFOUR: '4';
			case FlxKey.FIVE | FlxKey.NUMPADFIVE: '5';
			case FlxKey.SIX | FlxKey.NUMPADSIX: '6';
			case FlxKey.SEVEN | FlxKey.NUMPADSEVEN: '7';
			case FlxKey.EIGHT | FlxKey.NUMPADEIGHT: '8';
			case FlxKey.NINE | FlxKey.NUMPADNINE: '9';
			case FlxKey.NUMPADMINUS: '-';
			case FlxKey.NUMPADPLUS: '+';
			case FlxKey.NUMPADPERIOD | FlxKey.PERIOD: '.';
			case FlxKey.NUMPADMULTIPLY: '*';
			case FlxKey.NUMPADSLASH | FlxKey.SLASH: '/';
			case FlxKey.LBRACKET: '[';
			case FlxKey.RBRACKET: ']';
			case FlxKey.SEMICOLON: ';';
			case FlxKey.QUOTE: '\'';
			case FlxKey.COMMA: ',';
			default: key.toString();
		}
	}

	private function createLabel():FlxText
	{
		var label:FlxText = new FlxText(0, 0, FlxG.width);
		label.setFormat(Paths.font('arirang'), 84, 0xff46495b, RIGHT, OUTLINE, 0xff17181e);
		label.borderSize = 4;
		return label;
	}
}
