package engine.states;

import engine.substates.MusicBeatSubState;
import engine.utils.Controls;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.math.FlxPoint;

class MusicBeatState extends TransitionState
{
	public static var current(default, null):MusicBeatState;

	@:access(flixel.FlxGame)
	public static function switchState(NextState:MusicBeatState):Void
	{
		var nextState:MusicBeatState = NextState;
		if (current != null)
		{
			current.fadeOut(nextState);
		}
		else
		{
			FlxG.switchState(NextState);
		}
	}

	public static function resetState():Void
	{
		if (current != null)
		{
			switchState(Type.createInstance(Type.getClass(current), []));
		}
		else
		{
			FlxG.resetState();
		}
	}

	public var controls(get, null):Controls;

	public var camBack(default, null):FlxCamera;
	public var camGame(default, null):FlxCamera;
	public var camHUD(default, null):FlxCamera;
	public var camOther(default, null):FlxCamera;

	public var musicSubState(get, never):MusicBeatSubState;

	private var cameraSize:Int = 0;
	private var cameraOffset:FlxPoint = FlxPoint.get();

	@:noCompletion
	private var _musicSubState:MusicBeatSubState;

	@:noCompletion
	override function create():Void
	{
		current = this;

		cameraSize = Math.ceil(Math.sqrt(FlxG.width * FlxG.width + FlxG.height * FlxG.height));
		cameraOffset.set((FlxG.width - cameraSize) * 0.5, (FlxG.height - cameraSize) * 0.5);

		function createCamera():FlxCamera
		{
			var camera:FlxCamera = new FlxCamera(0, 0, cameraSize, cameraSize);
			camera.bgColor = 0;
			camera.follow(new FlxObject(FlxG.width * 0.5, FlxG.height * 0.5), LOCKON, 1.0);
			camera.setPosition(cameraOffset.x, cameraOffset.y);
			return camera;
		}

		camBack = createCamera();
		camGame = createCamera();
		camHUD = createCamera();
		camOther = createCamera();

		FlxG.cameras.reset(camBack);
		FlxG.cameras.add(camGame, false);
		FlxG.cameras.add(camHUD, false);
		FlxG.cameras.add(camOther, false);

		@:privateAccess
		flixel.FlxCamera._defaultCameras = [camGame];
		FlxG.camera = camGame;

		init();
		fadeIn();
	}

	public function init():Void
	{
	}

	@:access(engine.substates.MusicBeatSubState)
	public function openMusicSubState(SubState:MusicBeatSubState):Void
	{
		_musicSubState = SubState;
		super.openSubState(SubState);
	}

	override function closeSubState():Void
	{
		super.closeSubState();
		_musicSubState = null;
	}

	@:noCompletion
	@:deprecated('Use openMusicSubState instead')
	override function openSubState(SubState:FlxSubState):Void
	{
		if (SubState is MusicBeatSubState)
			openMusicSubState(cast(SubState, MusicBeatSubState));
	}

	private inline function get_controls():Controls
	{
		return Controls.instance;
	}

	private function get_musicSubState():MusicBeatSubState
	{
		return _musicSubState;
	}
}
