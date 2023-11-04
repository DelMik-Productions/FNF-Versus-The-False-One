package engine.states;

#if debug
import engine.objects.music.MusicObject;
import engine.songs.Calculator;
import engine.songs.NoteRenderer;
import engine.states.PlayState;
import engine.timeline.BezierEasing;
import engine.timeline.Keyframe;
import engine.timeline.StringTimeline;
import engine.timeline.Timeline;
import engine.ui.Dragger;
import engine.ui.Slider;
import engine.ui.TimelineRenderer;
import engine.utils.CoolUtil;
import engine.utils.MathUtil;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.animation.FlxAnimation;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import haxe.DynamicAccess;
import haxe.Serializer;
import sys.io.File;

@:access(engine.states.PlayState)
class PlayStateEditor extends MusicBeatState
{
	public final playState:PlayState;

	public var songPosition:Float = 0.0;
	public var timeSlider:Slider;

	public var dragger:Dragger;

	private var diff:FlxPoint = FlxPoint.get();
	private var handling:Bool = false;

	private var lastSongPosition:Float = 0.0;

	public function new(playState:PlayState)
	{
		super();
		this.playState = playState;
	}

	override function init():Void
	{
		super.init();

		playState.camBack = camBack;
		playState.camGame = camGame;
		playState.camHUD = camHUD;
		playState.camOther = camOther;
		playState.init();
		playState.pause();
		playState.inst.play(true, 0.0).pause();
		playState.voiceOpponent.play(true, 0.0).pause();
		playState.voicePlayer.play(true, 0.0).pause();
		playState.played = true;
		playState.renderer.pressedIndex = [true, true, true, true];

		timeSlider = new Slider(FlxG.width - 50, 30, this, 'songPosition', 0.0, 237873.0);
		timeSlider.camera = camOther;
		timeSlider.x = 25;
		timeSlider.y = 25;
		timeSlider.color = FlxColor.BLACK;
		timeSlider.borderColor = FlxColor.WHITE;
		timeSlider.borderSize = 5;
		add(timeSlider);

		dragger = new Dragger();
		dragger.camera = camOther;
		add(dragger);

		FlxG.mouse.visible = true;
	}

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (FlxG.keys.justPressed.P)
		{
			timeSlider.exists = !timeSlider.exists;
		}

		if (handling || timeSlider.overlapsPoint(dragger.currentCameraPosition))
		{
			if (FlxG.keys.pressed.SHIFT && FlxG.mouse.pressed)
			{
				var minX:Float = timeSlider.x + timeSlider.borderSize;
				var maxX:Float = timeSlider.x + timeSlider.width - timeSlider.borderSize;
				var x:Float = MathUtil.clamp(dragger.currentCameraPosition.x, minX, maxX);
				songPosition = FlxMath.remapToRange(x, minX, maxX, 0.0, 237870.0);
				handling = true;
			}
			else
			{
				handling = false;
			}
		}
		else
		{
			handling = false;

			var diff:Float = (-FlxG.mouse.wheel * 0.05) * playState.defaultCameraZoomValue;
			playState.defaultCameraZoomValue += diff;

			playState.camFollowPos.x += (FlxG.stage.mouseX / FlxG.stage.stageWidth - 0.5) * FlxG.width * diff;
			playState.camFollowPos.y += (FlxG.stage.mouseY / FlxG.stage.stageHeight - 0.5) * FlxG.height * diff;

			if (FlxG.mouse.pressedRight)
			{
				if (FlxG.mouse.justPressedRight)
				{
					this.diff.x = playState.camFollowPos.x;
					this.diff.y = playState.camFollowPos.y;
				}

				playState.camFollowPos.x = this.diff.x - dragger.movedPosition.x;
				playState.camFollowPos.y = this.diff.y - dragger.movedPosition.y;
			}
		}

		if (playState.paused)
		{
			if (FlxG.keys.justPressed.SPACE)
			{
				playState.resume();
				playState.renderer.pressedIndex = [false, false, false, false];
				playState.inst.time = songPosition;
				playState.voiceOpponent.time = songPosition;
				playState.voicePlayer.time = songPosition;
			}
			playState.songPositionOffset = playState.getSystemMillisecondsFromStarted() - songPosition;
			playState.renderer.pressedIndex = [true, true, true, true];
			updateState(elapsed);
		}
		else
		{
			if (FlxG.keys.justPressed.SPACE)
			{
				playState.pause();
			}
			updateState(elapsed);
		}

		if (FlxG.keys.justPressed.LBRACKET)
		{
			camGame.angle -= 5;
		}
		if (FlxG.keys.justPressed.RBRACKET)
		{
			camGame.angle += 5;
		}

		#if FLX_DEBUG
		FlxG.watch.addQuick('SongPosition', songPosition);
		FlxG.watch.addQuick('CurBeat', playState.curBeat);
		FlxG.watch.addQuick('CurStep', playState.curStep);
		FlxG.watch.addQuick('Paused', playState.paused);
		FlxG.watch.addQuick('CamFollow', playState.camFollowPos);
		#end
	}

	@:access(engine.songs.NoteRenderer)
	public function updateState(elapsed:Float):Void
	{
		updateMember(elapsed);
		updateSongPosition();
		if (playState.paused)
		{
			var renderer:NoteRenderer = playState.renderer;
			CoolUtil.clearArray(renderer.pressed);
			CoolUtil.clearArray(renderer.opponentPressed);
			CoolUtil.clearArray(renderer.missed);
			renderer.lastNoteIndex = 0;
		}
		else
		{
			playState.voicePlayer.volume = 1.0;
		}
		playState.updateCameraZoom(elapsed);
		playState.updateCameraFollow(elapsed);
	}

	private function updateMember(elapsed:Float):Void
	{
		var i:Int = 0;
		var basic:FlxBasic = null;

		while (i < playState.length)
		{
			basic = playState.members[i++];

			if (basic != null && basic.exists && basic.active)
			{
				basic.update(elapsed);
			}
		}
	}

	@:access(engine.songs.Calculator)
	@:access(engine.states.PlayState)
	public function updateSongPosition():Void
	{
		if (!playState.paused)
			songPosition = playState.getSystemMillisecondsFromStarted() - playState.songPositionOffset;
		playState.songPosition = songPosition;

		if (lastSongPosition != songPosition)
		{
			lastSongPosition = songPosition;

			var calculator:Calculator = playState.calculator;

			calculator.lastStep = 0;
			calculator.lastStepOffset = 0.0;
			calculator.lastPosition = 0.0;
			calculator.nextBPMEventStrumTime = 0.0;
			calculator.curBPMEventIndex = -1;
			calculator.calculcate(playState.songPosition);

			playState.bpm = calculator.bpm;
			playState.crochet = calculator.crochet;
			playState.stepCrochet = calculator.stepCrochet;

			playState.curBeat = calculator.curBeat;
			playState.curStep = calculator.curStep;

			if (playState.oldBeat != playState.curBeat)
			{
				playState.oldBeat = playState.curBeat;
				playState.beatHit();
			}
			if (playState.oldStep != playState.curStep)
			{
				playState.oldStep = playState.curStep;
				playState.stepHit();
			}

			for (index in 0...playState.renderer.notes.length)
			{
				var note:NoteData = playState.renderer.notes[index];
				var diff:Float = (note.strumTime - songPosition);
				if (diff > 3000.0)
					break;

				if (note.sustainType < 1 && diff <= 0.0)
				{
					if (note.strumIndex > 3) // isPlayerNote
					{
						playState.renderer.playerPressNote(index, note.strumIndex - 4);
					}
					else
					{
						playState.renderer.opponentPressNote(index, note.strumIndex);
					}
				}
			}

			playState.forEachPlayable(o -> o.onUpdate(playState.songPosition));
			playState.updateTick();
		}

		for (strumNote in playState.renderer.playerStrums)
		{
			var curAnim:FlxAnimation = strumNote.animation.curAnim;
			if (curAnim.name != 'arrow' && curAnim.finished)
			{
				strumNote.playAnim('arrow', true);
			}
		}

		if (playState is versus.states.PlayState)
		{
			var playState:versus.states.PlayState = cast playState;
			for (i in 0...playState.beatPosition.length)
			{
				if (songPosition < playState.beatPosition[i].strumTime)
				{
					playState.beat = i;
				}
			}
		}
	}

	override function draw():Void
	{
		playState.draw();
		super.draw();
	}

	override function destroy():Void
	{
		FlxG.mouse.visible = false;
		playState.draw();
		super.destroy();
	}
}
#end
