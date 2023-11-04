package engine.objects;

import engine.objects.music.MusicGroup;
import engine.objects.music.MusicObject;
import engine.objects.music.MusicSpriteGroup.MusicTypedSpriteGroup;
import engine.states.PlayState;
import engine.utils.ClientPrefs;
import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.util.FlxSignal.FlxTypedSignal;
import flixel.util.FlxSort;

typedef StrumNoteSpriteGroup = MusicTypedSpriteGroup<StrumNote>;
typedef NoteSpriteGroup = MusicTypedSpriteGroup<Note>;
typedef IndexSignal = FlxTypedSignal<Int->Void>;

class Receptor extends MusicGroup
{
	public static inline var safeZoneOffset:Float = 160.0;
	public static inline var strumOffset:Float = 144.0 / 2.0;

	public var notes:Array<NoteData> = [];
	public var notesCount:Int = 0;

	public var strumLines:Array<StrumLine> = [];
	public var strumLine(get, never):Float;

	// Events
	public var songSpeedEvents:Array<EventData> = [];

	// Signals
	public var onOpponentPressNote(default, null):IndexSignal = new IndexSignal();
	public var onPlayerPressNote(default, null):IndexSignal = new IndexSignal();
	public var onPlayerMissNote(default, null):IndexSignal = new IndexSignal();

	// StrumNotesGroup
	public var opponentStrums:StrumNoteSpriteGroup;
	public var playerStrums:StrumNoteSpriteGroup;

	// RenderedNotesGroup
	public var activatedNote:NoteSpriteGroup;
	public var activatedSustainNote:NoteSpriteGroup;

	public var sustainProgress:Map<Int, Float> = [];
	public var pressedNote:Array<Int> = [];
	public var missedNote:Array<Int> = [];

	public function new()
	{
		super();

		var halfWidth:Float = (FlxG.width * 0.5);

		opponentStrums = createStrums();
		opponentStrums.x = (halfWidth - opponentStrums.width) * 0.5;
		opponentStrums.y = strumLine;
		add(cast opponentStrums);

		playerStrums = createStrums();
		playerStrums.x = halfWidth + (halfWidth - playerStrums.width) * 0.5;
		playerStrums.y = strumLine;
		add(cast playerStrums);

		activatedSustainNote = new NoteSpriteGroup();
		activatedSustainNote.alpha = 0.6;
		for (i in 0...20)
		{
			var cachedNote:Note = noteFactory();
			cachedNote.kill();
			activatedSustainNote.add(cachedNote);
		}
		add(cast activatedSustainNote);

		activatedNote = new NoteSpriteGroup();
		for (i in 0...10)
		{
			var cachedNote:Note = noteFactory();
			cachedNote.kill();
			activatedNote.add(cachedNote);
		}
		add(cast activatedNote);

		for (i in 0...8)
		{
			var strumLine:StrumLine = new StrumLine(i, this);
			strumLine.pressed = (i < 4); // Auto Opponent StrumLines
			strumLine.playState = playState;
			strumLine.strumNote = (i < 4 ? opponentStrums.members[i] : playerStrums.members[i - 4]);
			strumLines.push(strumLine);
			add(cast strumLine);
		}
		resetSongSpeed(1.0);
	}

	public function createStrums(?strums:StrumNoteSpriteGroup):StrumNoteSpriteGroup
	{
		if (strums == null)
			strums = new StrumNoteSpriteGroup();

		for (i in 0...4)
		{
			var strumNote:StrumNote = new StrumNote(i);
			strumNote.x = Note.swagWidth * i;
			strums.add(strumNote);
		}
		return strums;
	}

	override function onPrefsChanged():Void
	{
		opponentStrums.y = strumLine;
		playerStrums.y = strumLine;

		updateStrums();
	}

	override function onKeyDown(i:Int):Void
	{
		// Exception of PauseSubState
		if (playState.paused)
			return;

		strumLines[4 + i].onKeyDown(i);
	}

	override function onKeyUp(i:Int):Void
	{
		strumLines[4 + i].onKeyUp(i);
	}

	public function updateStrums():Void
	{
		for (strumLine in strumLines)
		{
			strumLine.updateStrum();
		}
	}

	public function recycleNote(group:NoteSpriteGroup):Note
	{
		var note:Note = group.getFirstDead();
		if (note != null)
		{
			note.revive();
			return note;
		}
		return group.add(noteFactory());
	}

	private function noteFactory():Note
	{
		return new Note(0);
	}

	public function addNote(strumTime:Float, strumIndex:Int, ?sustainLength:Float):Void
	{
		if (sustainLength == null)
			sustainLength = 0.0;

		if (pushNote(strumTime, strumIndex, 0, sustainLength) > -1)
		{
			var remainedLength:Float = sustainLength;
			var stepCrochet:Float = calculateStepCrochet(strumTime);
			while (remainedLength > 0.0)
			{
				var holdSustainLength:Float = stepCrochet;
				var isHoldEnd:Bool = (remainedLength - holdSustainLength) <= 0.0;
				if (isHoldEnd)
					holdSustainLength = remainedLength;

				var holdStrumTime:Float = strumTime + (sustainLength - remainedLength);
				var cutPosition:Float = calculateBpmCutPosition(holdStrumTime, stepCrochet);
				if (cutPosition > holdStrumTime && cutPosition <= holdStrumTime + stepCrochet)
				{
					holdSustainLength = cutPosition - holdStrumTime;
					stepCrochet = calculateStepCrochet(cutPosition);
				}

				pushNote(holdStrumTime, strumIndex, isHoldEnd ? 2 : 1, holdSustainLength);
				remainedLength -= holdSustainLength;
			}
		}
	}

	private function pushNote(strumTime:Float, strumIndex:Int, sustainType:Int, sustainLength:Float):Int
	{
		for (note in notes)
		{
			if (FlxMath.equal(note.strumTime, strumTime)
				&& (note.strumIndex == strumIndex)
				&& (note.sustainType == sustainType)
				&& FlxMath.equal(note.sustainLength, sustainLength))
				return -1;
		}

		notes.push({
			strumTime: strumTime,
			strumIndex: strumIndex,
			sustainType: sustainType,
			sustainLength: sustainLength,
		});
		strumLines[strumIndex].addNoteIndex(notesCount);
		return ++notesCount;
	}

	public function missNote(index:Int):Void
	{
		if (missedNote.indexOf(index) < 0)
		{
			missedNote.push(index);
			onPlayerMissNote.dispatch(index);
		}
	}

	public function sortNote():Void
	{
		notes.sort((a, b) ->
		{
			if (FlxMath.equal(a.strumTime, b.strumTime))
			{
				if (a.strumIndex == b.strumIndex)
					return FlxSort.byValues(FlxSort.ASCENDING, a.sustainType, b.sustainType);
				return FlxSort.byValues(FlxSort.ASCENDING, a.strumIndex, b.strumIndex);
			}
			return FlxSort.byValues(FlxSort.ASCENDING, a.strumTime, b.strumTime);
		});
	}

	public function resetSongSpeed(songSpeed:Float):Void
	{
		songSpeedEvents[0] = {
			strumTime: 0.0,
			eventValue: songSpeed
		};
	}

	public function addSongSpeedEvent(strumTime:Float, songSpeed:Float):Void
	{
		songSpeedEvents.push({
			strumTime: strumTime,
			eventValue: songSpeed,
		});
	}

	public function calculateSongSpeed(strumTime:Float):Float
	{
		var songSpeed:Float = 1.0;
		for (i in 0...songSpeedEvents.length)
		{
			var event:EventData = songSpeedEvents[i];
			if (strumTime >= event.strumTime)
			{
				songSpeed = event.eventValue;
			}
		}
		return songSpeed;
	}

	public function calculateNotePosition(strumTime:Float):Float
	{
		var position:Float = 0.0;
		for (i in 0...songSpeedEvents.length)
		{
			var event:EventData = songSpeedEvents[i];
			if (event.strumTime > strumTime)
				break;

			if (i < songSpeedEvents.length - 1 && strumTime >= songSpeedEvents[i + 1].strumTime)
			{
				var nextEvent:EventData = songSpeedEvents[i + 1];
				position += (nextEvent.strumTime - event.strumTime) * event.eventValue;
			}
			else
			{
				position += (strumTime - event.strumTime) * event.eventValue;
			}
		}
		return position;
	}

	private inline function calculateStepCrochet(strumTime:Float):Float
	{
		return playState.calculator.calculateStepCrochet(strumTime);
	}

	private inline function calculateBpmCutPosition(strumTime:Float, stepCrochet:Float):Float
	{
		return playState.calculator.calculateBpmCutPosition(strumTime, stepCrochet);
	}

	private function get_strumLine():Float
	{
		return (ClientPrefs.downScroll ? FlxG.height - Receptor.strumOffset - Note.swagHeight : Receptor.strumOffset);
	}
}
