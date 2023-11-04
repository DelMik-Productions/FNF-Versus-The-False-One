package engine.objects;

import engine.objects.Receptor.NoteSpriteGroup;
import engine.objects.Receptor.StrumNoteSpriteGroup;
import engine.states.PlayState.NoteData;
import engine.utils.ClientPrefs;
import engine.utils.MathUtil;
import flixel.FlxG;
import flixel.math.FlxRect;

class StrumLine extends NoteSpriteGroup
{
	public var index:Int;
	public var receptor:Receptor;
	public var strumNote:StrumNote;

	public var pressed:Bool = false;
	public var remainedNotes:Array<Int> = [];

	private var lastNoteIndex:Int = 0;
	private var calculatedSongPosition:Float = 0.0;

	public function new(index:Int, receptor:Receptor)
	{
		super();
		this.index = index;
		this.receptor = receptor;
	}

	override function onUpdate(songPosition:Float):Void
	{
		super.onUpdate(songPosition);
		updateStrum();
	}

	public function updateStrum():Void
	{
		calculatedSongPosition = receptor.calculateNotePosition(songPosition);
		for (index in lastNoteIndex...remainedNotes.length)
		{
			var note:NoteData = receptor.notes[index];
			var diff:Float = (note.strumTime - songPosition);
			if (diff > 3000.0)
			{
				break;
			}
			else if (diff < -1000.0)
			{
				lastNoteIndex = index;
				break;
			}

			if (((note.sustainType < 1 && diff < -Receptor.safeZoneOffset * 0.5)
				|| (note.sustainType > 0 && diff < -Receptor.safeZoneOffset))
				&& receptor.missedNote.indexOf(index) < 0) // Missed
			{
				receptor.missNote(index);
			}
			if (receptor.pressedNote.indexOf(index) > -1 && note.sustainType < 1) // Skip PressedNote
			{
				continue;
			}

			if (diff >= -1000.0 && diff <= 3000.0)
				updateNote(index);
		}
	}

	private function updateNote(index:Int):Void
	{
		var note:NoteData = receptor.notes[index];
		var diff:Float = (note.strumTime - songPosition);

		var noteIndex:Int = (note.strumIndex % 4);
		var isSustainNote:Bool = (note.sustainType > 0);

		// UpdateSystem

		if (isSustainNote && pressed && diff <= 0.0 && receptor.pressedNote.indexOf(index) < 0)
		{
			receptor.pressedNote.push(index);
			strumNote.playAnim('confirm', true);
			receptor.onPlayerPressNote.dispatch(index);
		}

		// RenderNote

		var activatedNoteY:Float = strumNote.y + (Note.swagHeight * 0.5);
		var notePosition:Float = receptor.calculateNotePosition(note.strumTime) - calculatedSongPosition;
		var sustainHeight:Float = note.sustainLength * receptor.calculateSongSpeed(note.strumTime);
		if (ClientPrefs.downScroll)
			activatedNoteY -= notePosition + sustainHeight;
		else
			activatedNoteY += notePosition;

		if (activatedNoteY < -(sustainHeight + 100.0) || activatedNoteY > FlxG.height + 100.0)
			return;

		var noteRenderGroup:NoteSpriteGroup = (isSustainNote ? receptor.activatedSustainNote : receptor.activatedNote);
		var activatedNote:Note = receptor.recycleNote(noteRenderGroup);
		activatedNote.strumTime = note.strumTime;
		activatedNote.index = noteIndex;

		if (isSustainNote)
		{
			activatedNote.playAnim((note.sustainType > 1 ? 'holdend' : 'holdpiece'), true);

			var newScaleY:Float = (sustainHeight / activatedNote.frameHeight);
			activatedNote.scale.y = newScaleY;
			activatedNote.updateHitbox();

			activatedNote.x = strumNote.x + (Note.swagWidth - activatedNote.width) * 0.5;
			activatedNote.y = activatedNoteY;
			if (ClientPrefs.downScroll)
				activatedNote.angle = 180;
			else
				activatedNote.angle = 0;

			if (activatedNote.clipRect == null)
				activatedNote.clipRect = FlxRect.get();
			var clipRect:FlxRect = activatedNote.clipRect;

			clipRect.set(0, 0, activatedNote.frameWidth, activatedNote.frameHeight);

			var clipRectY:Float = (strumNote.y + (Note.swagHeight * 0.5) - activatedNote.y) / activatedNote.scale.y;
			clipRectY = MathUtil.clamp(clipRectY, 0.0, activatedNote.frameHeight);

			if (pressed)
				receptor.sustainProgress.set(index, clipRectY);
			clipRectY = receptor.sustainProgress.get(index) ?? (ClientPrefs.downScroll ? activatedNote.frameHeight : 0.0);

			if (ClientPrefs.downScroll)
				clipRectY = activatedNote.frameHeight - clipRectY;
			clipRect.y = clipRectY;

			activatedNote.clipRect = clipRect;
		}
		else
		{
			activatedNote.playAnim('note', true);

			activatedNote.setGraphicSize(Note.swagWidth, Note.swagHeight);
			activatedNote.updateHitbox();
			activatedNote.centerOffsets();

			activatedNote.x = strumNote.x;
			activatedNote.y = strumNote.y + (ClientPrefs.downScroll ? -notePosition : notePosition);

			if (activatedNote.clipRect == null)
				activatedNote.clipRect = FlxRect.get();
			var clipRect:FlxRect = activatedNote.clipRect;
			clipRect.set(0, 0, activatedNote.frameWidth, activatedNote.frameHeight);
			activatedNote.clipRect = clipRect;
		}

		if (receptor.missedNote.indexOf(index) > -1)
			activatedNote.alpha = 0.4;
		else
			activatedNote.alpha = 1.0;
	}

	override function onKeyDown(i:Int):Void
	{
		pressed = true;
		strumNote.playAnim('arrow', true);

		for (index in lastNoteIndex...remainedNotes.length)
		{
			var note:NoteData = receptor.notes[index];
			var noteIndex:Int = (note.strumIndex % 4);
			var isPlayerNote:Bool = (note.strumIndex > 3);

			if (isPlayerNote
				&& (noteIndex == i)
				&& (note.sustainType < 1) // Only ArrowNote
				&& (receptor.missedNote.indexOf(index) < 0)
				&& (receptor.pressedNote.indexOf(index) < 0)
				&& note.strumTime >= songPosition - (Receptor.safeZoneOffset * 0.5)
				&& note.strumTime <= songPosition + Receptor.safeZoneOffset)
			{
				receptor.pressedNote.push(index);
				strumNote.playAnim('confirm', true);
				receptor.onPlayerPressNote.dispatch(index);
				break;
			}
		}
	}

	override function onKeyUp(i:Int):Void
	{
		pressed = false;
		strumNote.playAnim('arrow', true);
	}

	public function addNoteIndex(index:Int):Void
	{
		remainedNotes.push(index);
	}
}
