package versus.states;

import engine.states.MusicBeatState;
import engine.states.PlayStateEditor;
// import engine.states.PlayStateEditor;
import engine.ui.Slider;
import engine.utils.ClientPrefs;
import engine.utils.Controls;
import engine.utils.MathUtil;
import engine.utils.Paths;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import sys.FileSystem;
import sys.thread.Thread;

class TitleState extends MusicBeatState
{
	public var slider:Slider;
	public var loaded:Float = 0.0;

	private var loadTo:Float = 0.0;
	private var switched:Bool = false;

	override function create():Void
	{
		super.create();

		ClientPrefs.init();
		Controls.init();

		FlxG.autoPause = false;
		FlxG.mouse.visible = false;
		FlxG.mouse.useSystemCursor = true;

		Paths.setCurrentLevel('versus');

		var logo:FlxSprite = new FlxSprite(Paths.image('logo'));
		logo.y -= FlxG.height / 18;
		add(logo);

		slider = new Slider(FlxG.width - 80, 40, this, 'loadTo');
		slider.color = FlxColor.BLACK;
		slider.borderSize = 10;
		slider.y = FlxG.height / 9 * 8;
		slider.screenCenter(X);
		add(slider);

		persistentUpdate = true;

		Thread.create(cache);
	}

	public function cache():Void
	{
		function resolve(dir:String):Array<String>
		{
			var res:Array<String> = [];
			var files:Array<String> = FileSystem.readDirectory(dir);
			for (s in files)
			{
				var v:String = dir + '/' + s;
				if (FileSystem.isDirectory(v))
				{
					for (s in resolve(v))
						res.push(s);
				}
				else
				{
					if (StringTools.endsWith(v, '.png'))
					{
						v = StringTools.replace(v, 'assets/versus/images/', '');
						res.push(v.substr(0, v.length - 4));
					}
				}
			}
			return res;
		}

		var assets:Array<String> = resolve('assets/versus/images');
		var cur:Int = 0, max:Int = assets.length + 10;
		for (s in assets)
		{
			Paths.image(s);
			loaded = (++cur / max);
		}

		Paths.image('characters/BOYFRIEND_DEAD');
		loaded = (++cur / max);

		function cacheMusic(v:String):Void
		{
			Paths.music(v);
			loaded = (++cur / max);
		}

		cacheMusic('gameover');
		cacheMusic('title');
		// cacheMusic('untitled');

		function cacheSound(v:String):Void
		{
			Paths.sound(v);
			loaded = (++cur / max);
		}

		cacheSound('cancel');
		cacheSound('confirm');
		cacheSound('retry');
		cacheSound('select');

		function cacheSong(v:String):Void
		{
			Paths.getSound('subterfuge/' + v);
			loaded = (++cur / max);
		}

		cacheSong('Inst');
		cacheSong('VoiceOpponent');
		cacheSong('VoicePlayer');
	}

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (loaded >= 1.0 && !switched)
		{
			MusicBeatState.switchState(getNextState());
			switched = true;
		}

		loadTo = FlxMath.lerp(loaded, loadTo, 1.0 - MathUtil.clamp01(elapsed * 16.4));
	}

	public function getNextState():MusicBeatState
	{
		#if debug
		return new MainMenuState(); // new PlayStateEditor(new PlayState());
		#else
		return new MainMenuState();
		#end
	}
}
