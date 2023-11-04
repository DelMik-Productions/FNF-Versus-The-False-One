package engine.substates;

import engine.states.MusicBeatState;
import engine.utils.Controls;
import flixel.FlxCamera;
import flixel.FlxSubState;

class MusicBeatSubState extends FlxSubState
{
	public final parentMusicState:MusicBeatState;

	public var closed:Bool = false;

	public var controls(get, never):Controls;

	public var camGame(get, never):FlxCamera;
	public var camHUD(get, never):FlxCamera;
	public var camOther(get, never):FlxCamera;

	public function new(parentMusicState:MusicBeatState)
	{
		super();
		this.parentMusicState = parentMusicState;
	}

	public inline function get_controls():Controls
		return Controls.instance;

	public inline function get_camGame():FlxCamera
		return parentMusicState.camGame;

	public inline function get_camHUD():FlxCamera
		return parentMusicState.camHUD;

	public inline function get_camOther():FlxCamera
		return parentMusicState.camOther;
}
