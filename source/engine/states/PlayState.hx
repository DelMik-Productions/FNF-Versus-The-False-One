package engine.states;

import engine.effects.AlphaEffect;
import engine.objects.Character;
import engine.objects.music.MusicObject;
import engine.objects.music.MusicSprite;
import engine.songs.Calculator;
import engine.songs.NoteRenderer;
import engine.substates.GameOverSubState;
import engine.substates.PauseSubState;
import engine.ui.Slider;
import engine.utils.ClientPrefs;
import engine.utils.CoolUtil;
import engine.utils.MathUtil;
import engine.utils.Paths;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import openfl.Lib;
import openfl.events.KeyboardEvent;
import openfl.filters.ShaderFilter;
import versus.states.MainMenuState;

typedef EventData =
{
	var strumTime:Float;
	var eventValue:Float;
}

typedef NoteData =
{
	var strumTime:Float;
	var strumIndex:Int;
	var sustainType:Int;
	@:optional var sustainLength:Float;
};

class PlayState extends MusicBeatState
{
	public var startedSongPosition:Float = 0.0;
	public var songPosition:Float = 0.0;
	public var songPositionOffset:Float = 0.0;

	public var tick:Int = -1;

	public var curBeat:Int = -1;
	public var curStep:Int = -1;

	public var score:Int = 0;
	public var scoreFloat:Float = 0.0;

	public var noteCount:Int = 0;
	public var sick:Int = 0;
	public var good:Int = 0;

	public var inst:FlxSound;
	public var voiceOpponent:FlxSound;
	public var voicePlayer:FlxSound;
	public var played:Bool = false;

	public var camFollowPos(default, null):FlxPoint;
	public var camFollow(default, null):FlxObject;

	public var camUI:FlxCamera;
	public var uiAlphaEffect:AlphaEffect;

	public var opponent:Character;
	public var player:Character;

	public var health:Float = 0.5;
	public var healthBar:Slider;
	public var opponentIcon:FlxSprite;
	public var playerIcon:FlxSprite;
	public var opponentIconScale:Float = 1.0;
	public var playerIconScale:Float = 1.0;

	public var renderer:NoteRenderer;
	public var paused:Bool = false;

	public var bpm(default, null):Float = 100.0;
	public var crochet(default, null):Float; // beats in milliseconds
	public var stepCrochet(default, null):Float; // steps in milliseconds

	public var calculator:Calculator = new Calculator();

	private var oldBeat:Int = -1;
	private var oldStep:Int = -1;

	// LEFT, DOWN, UP, RIGHT
	public var pressed:Array<Int> = [-1, -1, -1, -1];
	public var keys:Array<Int> = [];

	private var defaultCameraZoomValue:Float = 1.0;
	private var cameraZoomValue:Float = 1.0;
	private var beatZoomValue:Float = 0.0;
	private var cameraZoomLerpScale:Float = 1.0;

	private var cameraFollowLerpScale:Float = 1.0;

	private var fakeHealth:Float = 0.5;

	private var scoreText:FlxText;
	private var lerpScore:Float = 0.0;

	private var scorePerNote:Float = 0.0;

	private var songLength:Float = 0.0;
	private var fakeSongLength:Float = 0.0;

	private var absolutePressed:Array<Int> = [-1, -1, -1, -1];

	override function init():Void
	{
		// Check if this is wrong access
		if (Type.getClass(this) == engine.states.PlayState)
		{
			throw 'engine.states.PlayState is base component for Playing. Extend(Inheritance) this.';
		}

		super.init();

		camUI = new FlxCamera(0, 0, cameraSize, cameraSize);
		camUI.bgColor = 0;
		camUI.follow(new FlxObject(FlxG.width * 0.5, FlxG.height * 0.5), LOCKON, 1.0);
		camUI.setPosition(cameraOffset.x, cameraOffset.y);

		uiAlphaEffect = new AlphaEffect();
		camUI.filters = [new ShaderFilter(uiAlphaEffect.shader)];

		FlxG.cameras.remove(camOther, false);
		FlxG.cameras.add(camUI, false);
		FlxG.cameras.add(camOther, false);

		camFollowPos = new FlxPoint(FlxG.width * 0.5, FlxG.height * 0.5);
		camFollow = camGame.target;

		addPlayElements();
		addPlayUI();
		addPlayHUD();

		startedSongPosition = CoolUtil.getSystemMilliseconds() + (calculator.crochet * 3.0);

		registerControls();
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();
		inst = FlxG.sound.load(Paths.getSound('subterfuge/Inst'));
		voiceOpponent = FlxG.sound.load(Paths.getSound('subterfuge/VoiceOpponent'));
		voicePlayer = FlxG.sound.load(Paths.getSound('subterfuge/VoicePlayer'));
		voicePlayer.volume = 0.0;

		songLength = inst.length;
		fakeSongLength = inst.length;

		#if FLX_DEBUG
		registerObjects();
		#end
	}

	public function addBackground():Void
	{
	}

	public function addPlayElements():Void
	{
		addBackground();

		opponent = new Character(getStartOpponentCharacter());
		add(opponent);
		player = new Character(getStartPlayerCharacter());
		add(player);
	}

	public function addPlayUI():Void
	{
		healthBar = new Slider(FlxG.width / 9 * 5, 40, this, 'fakeHealth', 0.0, 1.0);
		healthBar.camera = camUI;
		healthBar.leftToRight = false;
		healthBar.borderColor = FlxColor.BLACK;
		healthBar.borderSize = 10;
		healthBar.screenCenter(X);
		healthBar.y = (ClientPrefs.downScroll ? 100 : FlxG.height - healthBar.height - 100);
		add(healthBar);

		opponentIcon = new FlxSprite();
		opponentIcon.camera = camUI;
		opponentIcon.loadGraphic(Paths.image('icons/lookalike'), true, 150, 150);
		opponentIcon.animation.frameIndex = 0;
		opponentIcon.x = healthBar.x + healthBar.width * 0.5 - opponentIcon.width;
		opponentIcon.y = healthBar.y + (healthBar.height - opponentIcon.height) * 0.5;
		add(opponentIcon);

		playerIcon = new FlxSprite();
		playerIcon.camera = camUI;
		playerIcon.loadGraphic(Paths.image('icons/boyfriend'), true, 150, 150);
		playerIcon.animation.frameIndex = 0;
		playerIcon.x = healthBar.x + healthBar.width * 0.5;
		playerIcon.y = healthBar.y + (healthBar.height - playerIcon.height) * 0.5;
		playerIcon.flipX = true;
		add(playerIcon);
	}

	public function addPlayHUD():Void
	{
		renderer = new NoteRenderer();
		renderer.camera = camHUD;
		add(renderer);

		registerCalculator();
		registerRenderer();

		scoreText = new FlxText(-10, 0, FlxG.width, 'Score: 0000000');
		scoreText.camera = camHUD;
		scoreText.setFormat(Paths.font('arirang'), 64, 0xff46495b, CENTER, OUTLINE, 0xff17181e);
		scoreText.borderSize = 2;
		scoreText.y = (ClientPrefs.downScroll ? 30 : FlxG.height - scoreText.height - 30);
		add(scoreText);
	}

	public function registerCalculator():Void
	{
		resetBPM(100.0);
	}

	public function registerRenderer():Void
	{
		renderer.onOpponentPressNote.add(onOpponentPressNote);
		renderer.onPlayerPressNote.add(onPlayerPressNote);
		renderer.onPlayerMissNote.add(onPlayerMissNote);

		registerChart();

		for (note in renderer.notes)
		{
			if (note.strumIndex > 3)
				noteCount++;
		}

		scorePerNote = 1000000.0 / noteCount;
	}

	public function registerChart():Void
	{
	}

	#if FLX_DEBUG
	public function registerObjects():Void
	{
		FlxG.console.registerObject('camBack', camBack);
		FlxG.console.registerObject('camGame', camGame);
		FlxG.console.registerObject('camHUD', camHUD);
		FlxG.console.registerObject('camOther', camOther);

		FlxG.console.registerObject('camFollow', camFollowPos);
		FlxG.console.registerObject('opponent', opponent);
		FlxG.console.registerObject('player', player);

		FlxG.console.registerObject('defaultCameraZoomValue', defaultCameraZoomValue);
		FlxG.console.registerObject('cameraZoomValue', cameraZoomValue);
		FlxG.console.registerObject('beatZoomValue', beatZoomValue);
		FlxG.console.registerObject('cameraZoomLerpScale', cameraZoomLerpScale);

		FlxG.console.registerFunction('setDefaultCameraZoomValue', (v:Float) -> defaultCameraZoomValue = v);
		FlxG.console.registerFunction('setCameraZoomValue', (v:Float) -> cameraZoomValue = v);
		FlxG.console.registerFunction('setBeatZoomValue', (v:Float) -> beatZoomValue = v);
		FlxG.console.registerFunction('setCameraZoomLerpScale', (v:Float) -> cameraZoomLerpScale = v);

		FlxG.console.registerObject('playState', this);

		FlxG.console.registerFunction('pause', pause);
		FlxG.console.registerFunction('resume', resume);
		FlxG.console.registerFunction('setPosition', (value:Float) ->
		{
			songPositionOffset = getSystemMillisecondsFromStarted() - value;
			inst.time = value;
			voiceOpponent.time = value;
			voicePlayer.time = value;
		});

		FlxG.console.registerFunction('resetCamera', () ->
		{
			camGame.zoom = 1.0;
			camFollowPos.set(FlxG.width * 0.5, FlxG.height * 0.5);
		});
	}
	#end

	public function resetBPM(bpm:Float):Void
	{
		calculator.resetBPM(bpm);
		bpm = calculator.bpm;
		crochet = calculator.crochet;
		stepCrochet = calculator.stepCrochet;
	}

	public function reStart():Void
	{
		inst.fadeOut(0.45);
		voiceOpponent.fadeOut(0.45);
		voicePlayer.fadeOut(0.45);
		MusicBeatState.switchState(Type.createInstance(Type.getClass(this), []));
	}

	override function tryUpdate(elapsed:Float):Void
	{
		if (persistentUpdate || subState == null)
			update(elapsed);
		else if (Std.isOfType(subState, PauseSubState) && cast(subState, PauseSubState).closed)
			update(elapsed);

		if (_requestSubStateReset)
		{
			_requestSubStateReset = false;
			resetSubState();
		}
		if (subState != null)
		{
			subState.tryUpdate(elapsed);
		}
	}

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);
		updateSongPosition();
		updateCameraZoom(elapsed);
		updateCameraFollow(elapsed);

		if (controls.PAUSE)
		{
			pause();
		}
		if (controls.RESET)
		{
			reStart();
		}
	}

	public function updateSongPosition():Void
	{
		songPosition = getSystemMillisecondsFromStarted() - songPositionOffset;
		if (songPosition >= 0.0)
		{
			if (!played)
			{
				inst.play(false, songPosition);
				voiceOpponent.play(false, songPosition);
				voicePlayer.play(false, songPosition);
				played = true;
			}

			calculator.calculcate(songPosition);

			bpm = calculator.bpm;
			crochet = calculator.crochet;
			stepCrochet = calculator.stepCrochet;

			curBeat = calculator.curBeat;
			curStep = calculator.curStep;

			while (oldBeat < curBeat)
			{
				oldBeat++;
				beatHit();
			}

			while (oldStep < curStep)
			{
				oldStep++;
				stepHit();
			}

			forEachPlayable(o -> o.onUpdate(songPosition));
			updateTick();

			if (songPosition >= songLength && lerpScore >= scoreFloat)
			{
				songEnd();
			}
		}

		#if FLX_DEBUG
		FlxG.watch.addQuick('SongPosition', FlxMath.roundDecimal(songPosition, 2));
		FlxG.watch.addQuick('CurBeat', curBeat);
		FlxG.watch.addQuick('CurStep', curStep);
		FlxG.watch.addQuick('BPM', bpm);
		FlxG.watch.addQuick('Health', '$fakeHealth / $health');
		FlxG.watch.addQuick('HealthBar', Std.string(healthBar.getRatio()));
		#end
	}

	public function updateTick():Void
	{
		tick++;

		if (scoreFloat > lerpScore)
			lerpScore += scorePerNote * (FlxG.elapsed / (stepCrochet * 0.001));
		if (lerpScore > scoreFloat)
			lerpScore = scoreFloat;
		score = Std.int(lerpScore);
		scoreText.text = 'Score: ' + StringTools.lpad(Std.string(score), '0', 7);

		if (health < 0.0)
		{
			gameOver();
			health = 0.001;
		}
		else if (health > 1.0)
		{
			health = 1.0;
		}

		if (fakeHealth != health)
		{
			var healthAdd:Float = FlxG.elapsed * (crochet * 0.001);
			fakeHealth += healthAdd * (health - fakeHealth > 0.0 ? 1.0 : -1.0);
			if (Math.abs(health - fakeHealth) < healthAdd)
				fakeHealth = health;
		}

		var healthBarX:Float = healthBar.x + healthBar.borderSize;
		var healthBarWidth:Float = healthBar.width - healthBar.borderSize * 2.0;
		opponentIcon.x = healthBarX + healthBarWidth * (1.0 - fakeHealth) - opponentIcon.width;
		playerIcon.x = healthBarX + healthBarWidth * (1.0 - fakeHealth);

		var lerpVal:Float = 1.0 - MathUtil.clamp01(FlxG.elapsed * (bpm / 60));
		opponentIconScale = FlxMath.lerp(1.0, opponentIconScale, lerpVal);
		playerIconScale = FlxMath.lerp(1.0, playerIconScale, lerpVal);
		opponentIcon.scale.set(opponentIconScale, opponentIconScale);
		playerIcon.scale.set(playerIconScale, playerIconScale);

		if (fakeHealth <= 0.2)
		{
			playerIcon.animation.frameIndex = 1;
			opponentIcon.animation.frameIndex = 2;
		}
		else if (fakeHealth >= 0.8)
		{
			playerIcon.animation.frameIndex = 2;
			opponentIcon.animation.frameIndex = 1;
		}
		else
		{
			playerIcon.animation.frameIndex = 0;
			opponentIcon.animation.frameIndex = 0;
		}

		var uiAlpha:Float = (fakeHealth >= 1.0 ? 0.0 : 1.0);
		uiAlphaEffect.alpha = FlxMath.lerp(uiAlpha, uiAlphaEffect.alpha, lerpVal);

		forEachPlayable(o -> o.onTick(tick));
	}

	public function updateCameraFollow(elapsed:Float):Void
	{
		var lerpVal:Float = 1.0 - MathUtil.clamp01(elapsed * (bpm / 60) * cameraFollowLerpScale);
		camFollow.x = FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal);
		camFollow.y = FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal);
	}

	public function updateCameraZoom(elapsed:Float):Void
	{
		var lerpVal:Float = 1.0 - MathUtil.clamp01(elapsed * (bpm / 60) * cameraZoomLerpScale);
		cameraZoomValue = FlxMath.lerp(defaultCameraZoomValue, cameraZoomValue, lerpVal);
		beatZoomValue = FlxMath.lerp(0.0, beatZoomValue, lerpVal);

		camGame.zoom = cameraZoomValue + beatZoomValue;
		camHUD.zoom = 1.0 + beatZoomValue * 1.5;
		camUI.zoom = camHUD.zoom;
	}

	public function songEnd():Void
	{
		ClientPrefs.played = true;
		ClientPrefs.maxScore = scoreFloat;
		MusicBeatState.switchState(new MainMenuState());
	}

	public function gameOver():Void
	{
		pause();
		openMusicSubState(new GameOverSubState(this));
	}

	public function beatHit():Void
	{
		forEachPlayable(o -> o.onBeatHit(oldBeat));
	}

	public function stepHit():Void
	{
		forEachPlayable(o -> o.onStepHit(oldStep));
	}

	public function setCamFollow(?x:Float, ?y:Float, fix:Bool = false):Void
	{
		camFollowPos.x = (x ?? camFollowPos.x);
		camFollowPos.y = (y ?? camFollowPos.y);
		if (fix)
		{
			camFollow.x = camFollowPos.x;
			camFollow.y = camFollowPos.y;
		}
	}

	public function onOpponentPressNote(index:Int):Void
	{
		opponent.playAnim(opponent.arrowAnimations[renderer.notes[index].strumIndex], true);
		opponentIconScale = 1.4;
	}

	public function onPlayerPressNote(index:Int):Void
	{
		var safeZoneOffset:Float = NoteRenderer.safeZoneOffset;
		var diff:Float = Math.abs(renderer.notes[index].strumTime - songPosition);
		if (diff > safeZoneOffset * 0.5)
		{
			scoreFloat += scorePerNote * 0.5;
		}
		else
		{
			scoreFloat += scorePerNote;
		}
		score = Std.int(score);
		player.playAnim(player.arrowAnimations[renderer.notes[index].strumIndex - 4], true);
		voicePlayer.volume = 1.0;
		playerIconScale = 1.4;
		health += 0.025;
	}

	public function onPlayerMissNote(index:Int):Void
	{
		player.playAnim('miss' + player.arrowAnimations[renderer.notes[index].strumIndex - 4], true);
		voicePlayer.volume = 0.0;
		health -= 0.0475;
		FlxG.sound.play(CoolUtil.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
	}

	public function pause():Void
	{
		paused = true;

		inst.pause();
		voiceOpponent.pause();
		voicePlayer.pause();
		inst.time = songPosition;
		voiceOpponent.time = songPosition;
		voicePlayer.time = songPosition;
		openMusicSubState(new PauseSubState(this, songPosition));

		forEachPlayable(o -> o.onPause());
	}

	public function resume():Void
	{
		paused = false;

		inst.resume();
		voiceOpponent.resume();
		voicePlayer.resume();

		for (i in 0...4)
		{
			if (pressed[i] < 0 || absolutePressed[i] < 0 || pressed[i] != absolutePressed[i])
				keyUp(i);
		}

		forEachPlayable(o -> o.onResume());
	}

	public function keyDown(i:Int, ?keyCode:Int):Bool
	{
		if (pressed[i] > -1)
			return false;

		if (keyCode == null)
			keyCode = keys[i * 2];
		pressed[i] = keyCode;

		forEachPlayable(o -> o.onKeyDown(i));

		return true;
	}

	public function keyUp(i:Int):Bool
	{
		if (pressed[i] < 0)
			return false;
		pressed[i] = -1;

		forEachPlayable(o -> o.onKeyUp(i));

		return true;
	}

	public function onPrefsChanged():Void
	{
		scoreText.y = (ClientPrefs.downScroll ? 30 : FlxG.height - scoreText.height - 30);
		healthBar.y = (ClientPrefs.downScroll ? 100 : FlxG.height - healthBar.height - 100);
		opponentIcon.y = healthBar.y + (healthBar.height - opponentIcon.height) * 0.5;
		playerIcon.y = healthBar.y + (healthBar.height - playerIcon.height) * 0.5;
		registerControls();

		forEachPlayable(o -> o.onPrefsChanged());
	}

	@:access(engine.utils.ClientPrefs)
	private function registerControls():Void
	{
		keys.push(ClientPrefs.NOTE_LEFT[0]);
		keys.push(ClientPrefs.NOTE_LEFT[1]);
		keys.push(ClientPrefs.NOTE_DOWN[0]);
		keys.push(ClientPrefs.NOTE_DOWN[1]);
		keys.push(ClientPrefs.NOTE_UP[0]);
		keys.push(ClientPrefs.NOTE_UP[1]);
		keys.push(ClientPrefs.NOTE_RIGHT[0]);
		keys.push(ClientPrefs.NOTE_RIGHT[1]);
	}

	public function forEachPlayable(func:IPlayable->Void):Void
	{
		forEach(o ->
		{
			if (o is MusicObject)
				func(cast(o, MusicObject));
			if (o is MusicSprite)
				func(cast(o, MusicSprite));
		});
	}

	private function onKeyDown(e:KeyboardEvent):Void
	{
		var keyCode:Int = e.keyCode;
		var index:Int = keys.indexOf(keyCode);
		var arrowIndex:Int = Std.int(index / 2);

		if (index > -1)
		{
			absolutePressed[arrowIndex] = keyCode;
			if (!paused && pressed[arrowIndex] < 0)
			{
				keyDown(arrowIndex, keyCode);
			}
		}
	}

	private function onKeyUp(e:KeyboardEvent):Void
	{
		var keyCode:Int = e.keyCode;
		var index:Int = keys.indexOf(keyCode);
		var arrowIndex:Int = Std.int(index / 2);

		if (index > -1)
		{
			absolutePressed[arrowIndex] = -1;
			if (!paused && keyCode == pressed[arrowIndex])
				keyUp(Std.int(index / 2));
		}
	}

	public function getStartOpponentCharacter():String
	{
		return '';
	}

	public function getStartPlayerCharacter():String
	{
		return '';
	}

	public function getSystemMillisecondsFromStarted():Float
	{
		return CoolUtil.getSystemMilliseconds() - startedSongPosition;
	}

	override function add(basic:FlxBasic):FlxBasic
	{
		if (basic is MusicObject)
			cast(basic, MusicObject).playState = this;
		if (basic is MusicSprite)
			cast(basic, MusicSprite).playState = this;
		return super.add(basic);
	}

	override function destroy():Void
	{
		Lib.current.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		Lib.current.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		camFollowPos = FlxDestroyUtil.put(camFollowPos);
		super.destroy();
	}
}

interface IPlayable
{
	public var playState:PlayState;

	public var songPosition:Float;
	public var tick:Int;
	public var curBeat:Int;
	public var curStep:Int;

	public function onUpdate(songPosition:Float):Void;
	public function onTick(tick:Int):Void;
	public function onBeatHit(beat:Int):Void;
	public function onStepHit(step:Int):Void;
	public function onPause():Void;
	public function onResume():Void;
	public function onPrefsChanged():Void;
	public function onKeyDown(i:Int):Void;
	public function onKeyUp(i:Int):Void;
}
