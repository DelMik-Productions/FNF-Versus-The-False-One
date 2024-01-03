package engine.songs;

import engine.effects.ColorMaskEffect;
import engine.objects.Note;
import engine.objects.StrumNote;
import engine.states.PlayState;
import engine.utils.ClientPrefs;
import engine.utils.MathUtil;
import flixel.FlxG;
import flixel.animation.FlxAnimation;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.math.FlxRect;
import flixel.util.FlxColor;
import flixel.util.FlxSignal.FlxTypedSignal;
import flixel.util.FlxSort;

typedef StrumNoteSpriteGroup = FlxTypedSpriteGroup<StrumNote>;
typedef NoteSpriteGroup = FlxTypedSpriteGroup<Note>;
typedef IndexSignal = FlxTypedSignal<Int->Void>;

class NoteRenderer extends FlxSpriteGroup implements IPlayable
{
	public static inline var safeZoneOffset:Float = 160.0;
	public static inline var strumOffset:Float = 144.0 / 2.0;

	public var playState:PlayState;

	public var notes:Array<NoteData> = [];
	public var strumLine(get, never):Float;

	public var pressedIndex:Array<Bool> = [false, false, false, false];

	// LEFT, DOWN, UP, RIGHT
	// public var nearestNotes:Array<NoteData> = [null, null, null, null];
	public var missed:Array<Int> = [];
	public var pressed:Array<Int> = [];
	public var opponentPressed:Array<Int> = [];

	// StrumNotesGroup
	public var opponentStrums:StrumNoteSpriteGroup;
	public var playerStrums:StrumNoteSpriteGroup;

	// RenderedNotesGroup
	public var activatedNote:NoteSpriteGroup;
	public var activatedsustainNote:NoteSpriteGroup;

	// Events
	public var songSpeedEvents:Array<EventData> = [];

	// Signals
	public var onOpponentPressNote(default, null):IndexSignal = new IndexSignal();
	public var onPlayerPressNote(default, null):IndexSignal = new IndexSignal();
	public var onPlayerMissNote(default, null):IndexSignal = new IndexSignal();

	private var sustainProgress:Map<Int, Float> = [];
	private var lastNoteIndex:Int = 0;

	private var lastCalculatedNotePosition:Float = 0.0;
	private var songPosition:Float = 0.0;

	#if FLX_DEBUG
	private var calcNote:Int = 0;
	private var drawNote:Int = 0;
	#end

	public function new()
	{
		super();

		var halfWidth:Float = (FlxG.width * 0.5);

		opponentStrums = createStrums(false);
		opponentStrums.x = (halfWidth - opponentStrums.width) * 0.5;
		opponentStrums.y = strumLine;
		add(opponentStrums);

		playerStrums = createStrums(true);
		playerStrums.x = halfWidth + (halfWidth - playerStrums.width) * 0.5;
		playerStrums.y = strumLine;
		add(playerStrums);

		activatedsustainNote = new NoteSpriteGroup();
		for (i in 0...20)
		{
			var cachedNote:Note = noteFactory();
			cachedNote.kill();
			activatedsustainNote.add(cachedNote);
		}
		add(activatedsustainNote);

		activatedNote = new NoteSpriteGroup();
		for (i in 0...10)
		{
			var cachedNote:Note = noteFactory();
			cachedNote.kill();
			activatedNote.add(cachedNote);
		}
		add(activatedNote);

		resetSongSpeed(1.0);
	}

	public function createStrums(isPlayerNote:Bool, ?strums:StrumNoteSpriteGroup):StrumNoteSpriteGroup
	{
		if (strums == null)
			strums = new StrumNoteSpriteGroup();

		for (i in 0...4)
		{
			var strumNote:StrumNote = new StrumNote(i);
			strumNote.isPlayerNote = isPlayerNote;
			strumNote.x = Note.swagWidth * i;
			strums.add(strumNote);
		}
		return strums;
	}

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		opponentStrums.y = strumLine;
		playerStrums.y = strumLine;

		onUpdate(this.songPosition = playState.songPosition);

		if (playState.isKeyDown)
		{
			onKeyDown(playState.isKeyDownValue);
		}
		if (playState.isKeyUp)
		{
			onKeyUp(playState.isKeyUpValue);
		}
	}

	public function onUpdate(songPosition:Float):Void
	{
		updateNotes();
		for (strumNote in opponentStrums)
		{
			var curAnim:FlxAnimation = strumNote.animation.curAnim;
			if (curAnim.name != 'arrow' && curAnim.finished)
			{
				strumNote.playAnim('arrow', true);
			}
		}
	}

	public function updateNotes():Void
	{
		activatedsustainNote.group.killMembers();
		activatedNote.group.killMembers();

		#if FLX_DEBUG
		calcNote = 0;
		drawNote = 0;
		#end

		lastCalculatedNotePosition = calculateNotePosition(songPosition);
		for (index in lastNoteIndex...notes.length)
		{
			var note:NoteData = notes[index];
			var diff:Float = (note.strumTime - songPosition);
			if (diff > 3000.0)
				break;

			if (note.strumIndex > 3 && !isPressed(index) && missed.indexOf(index) < 0 && diff < -safeZoneOffset * 0.5)
			{
				playerMissNote(index);
			}
			else if (diff < -3000.0)
			{
				lastNoteIndex = index;
			}
			else if (note.sustainType < 1 && isPressed(index))
				continue;

			if (diff >= -500.0 && diff <= 3000.0)
			{
				updateNote(index);
				#if FLX_DEBUG
				calcNote++;
				#end
			}
		}

		#if FLX_DEBUG
		FlxG.watch.addQuick('CalcNote', calcNote);
		FlxG.watch.addQuick('DrawNote', drawNote);
		#end
	}

	private function updateNote(index:Int):Void
	{
		var note:NoteData = notes[index];
		var diff:Float = (note.strumTime - songPosition);

		var noteIndex:Int = (note.strumIndex % 4);
		var isPlayerNote:Bool = (note.strumIndex > 3);
		var isSustainNote:Bool = (note.sustainType > 0);

		// UpdateSystem

		if (isPlayerNote)
		{
			if (isSustainNote && pressedIndex[noteIndex] && diff <= 0.0 && pressed.indexOf(index) < 0 && missed.indexOf(index) < 0)
			{
				playerPressNote(index, noteIndex);
			}
		}
		else
		{
			if (diff <= 0 && opponentPressed.indexOf(index) < 0)
			{
				opponentPressNote(index, noteIndex);
			}
		}

		// RenderNote

		var strumNotes:StrumNoteSpriteGroup = (note.strumIndex > 3 ? playerStrums : opponentStrums);
		var strumNote:StrumNote = strumNotes.members[noteIndex];
		var renderedNoteY:Float = strumNote.y + (Note.swagHeight * 0.5);
		var notePosition:Float = calculateNotePosition(note.strumTime) - lastCalculatedNotePosition;
		var sustainHeight:Float = note.sustainLength * calculateSongSpeed(note.strumTime);
		if (ClientPrefs.downScroll)
			renderedNoteY -= notePosition + sustainHeight;
		else
			renderedNoteY += notePosition;

		if (renderedNoteY < -(sustainHeight + 100) || renderedNoteY > FlxG.height + 100)
			return;

		var noteRenderGroup:NoteSpriteGroup = (isSustainNote ? activatedsustainNote : activatedNote);
		var renderedNote:Note = recycleNote(noteRenderGroup);
		renderedNote.strumTime = note.strumTime;
		renderedNote.index = noteIndex;
		renderedNote.isPlayerNote = isPlayerNote;

		if (isSustainNote)
		{
			renderedNote.playAnim((note.sustainType > 1 ? 'holdend' : 'holdpiece'), true);

			var newScaleY:Float = (sustainHeight / renderedNote.frameHeight);
			renderedNote.scale.y = newScaleY;
			renderedNote.updateHitbox();

			renderedNote.x = strumNote.x + (Note.swagWidth - renderedNote.width) * 0.5;
			renderedNote.y = renderedNoteY;
			if (ClientPrefs.downScroll)
				renderedNote.angle = 180;
			else
				renderedNote.angle = 0;

			if (renderedNote.clipRect == null)
				renderedNote.clipRect = FlxRect.get();
			var clipRect:FlxRect = renderedNote.clipRect;

			clipRect.set(0, 0, renderedNote.frameWidth, renderedNote.frameHeight);

			var clipRectY:Float = (strumNote.y + (Note.swagHeight * 0.5) - renderedNote.y) / renderedNote.scale.y;
			clipRectY = MathUtil.clamp(clipRectY, 0.0, renderedNote.frameHeight);

			if (isPlayerNote)
			{
				if (pressedIndex[noteIndex])
					sustainProgress.set(index, clipRectY);
				clipRectY = sustainProgress.get(index) ?? (ClientPrefs.downScroll ? renderedNote.frameHeight : 0.0);
			}

			if (ClientPrefs.downScroll)
				clipRectY = renderedNote.frameHeight - clipRectY;
			clipRect.y = clipRectY;

			renderedNote.clipRect = clipRect;
		}
		else
		{
			renderedNote.playAnim('note', true);

			renderedNote.setGraphicSize(Note.swagWidth, Note.swagHeight);
			renderedNote.updateHitbox();
			renderedNote.centerOffsets();

			renderedNote.x = strumNote.x;
			renderedNote.y = strumNote.y + (ClientPrefs.downScroll ? -notePosition : notePosition);

			if (renderedNote.clipRect == null)
				renderedNote.clipRect = FlxRect.get();
			var clipRect:FlxRect = renderedNote.clipRect;
			clipRect.set(0, 0, renderedNote.frameWidth, renderedNote.frameHeight);
			renderedNote.clipRect = clipRect;
		}

		renderedNote.alpha = (isSustainNote ? 0.6 : 1.0);
		if (missed.indexOf(index) > -1)
			renderedNote.alpha *= 0.4;
		else
			renderedNote.alpha *= 1.0;

		#if FLX_DEBUG
		drawNote++;
		#end
	}

	private function recycleNote(group:NoteSpriteGroup):Note
	{
		var note:Note = group.getFirstDead();
		if (note != null)
		{
			note.revive();
			return note;
		}
		return group.add(noteFactory());
	}

	public function onKeyDown(i:Int):Void
	{
		playerStrums.members[i].playAnim('pressed', true);

		// Exception of PauseSubState
		if (playState.paused)
			return;

		pressedIndex[i] = true;

		for (index in lastNoteIndex...notes.length)
		{
			var note:NoteData = notes[index];
			var noteIndex:Int = (note.strumIndex % 4);
			var isPlayerNote:Bool = (note.strumIndex > 3);

			if (isPlayerNote
				&& (noteIndex == i)
				&& (note.sustainType < 1) // Only ArrowNote
				&& (missed.indexOf(index) < 0)
				&& !isPressed(index)
				&& note.strumTime >= songPosition - (safeZoneOffset * 0.5)
				&& note.strumTime <= songPosition + safeZoneOffset)
			{
				playerPressNote(index, i);
				break;
			}
		}
	}

	public function onKeyUp(i:Int):Void
	{
		playerStrums.members[i].playAnim('arrow', true);
		pressedIndex[i] = false;
	}

	public function isPressed(index:Int):Bool
	{
		if (index > -1 && index < notes.length)
		{
			if (notes[index].strumIndex > 3)
				return pressed.indexOf(index) > -1;
			else
				return opponentPressed.indexOf(index) > -1;
		}
		return false;
	}

	public function addNote(strumTime:Float, strumIndex:Int, ?sustainLength:Float):Void
	{
		if (sustainLength == null)
			sustainLength = 0.0;

		notes.push({
			strumTime: strumTime,
			strumIndex: strumIndex,
			sustainType: 0,
			sustainLength: 0.0
		});

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

			notes.push({
				strumTime: holdStrumTime,
				strumIndex: strumIndex,
				sustainType: (isHoldEnd ? 2 : 1),
				sustainLength: holdSustainLength,
			});

			remainedLength -= holdSustainLength;
		}
	}

	public function sortNotes():Void
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

	public function playerPressNote(noteIndex:Int, strumIndex:Int):Void
	{
		if (pressed.indexOf(noteIndex) < 0)
		{
			pressed.push(noteIndex);
			playerStrums.members[strumIndex].playAnim('confirm', true);
			onPlayerPressNote.dispatch(noteIndex);
		}
	}

	public function opponentPressNote(noteIndex:Int, strumIndex:Int):Void
	{
		if (opponentPressed.indexOf(noteIndex) < 0)
		{
			opponentPressed.push(noteIndex);
			opponentStrums.members[strumIndex].playAnim('confirm', true);
			onOpponentPressNote.dispatch(noteIndex);
		}
	}

	public function playerMissNote(index:Int):Void
	{
		if (missed.indexOf(index) < 0)
		{
			missed.push(index);
			onPlayerMissNote.dispatch(index);
		}
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
			eventValue: songSpeed
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

	private function noteFactory():Note
	{
		return new Note(0);
	}

	private function get_strumLine():Float
	{
		return (ClientPrefs.downScroll ? FlxG.height - strumOffset - Note.swagHeight : strumOffset);
	}
}
