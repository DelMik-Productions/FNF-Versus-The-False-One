package engine.objects;

import engine.effects.ColorMaskEffect;
import engine.objects.music.MusicSprite;
import engine.utils.Paths;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxRect;
import flixel.util.FlxColor;

class Note extends MusicSprite
{
	public static inline var swagWidth:Float = 168.0;
	public static inline var swagHeight:Float = 164.0;

	private static inline var scaleX:Float = 1.07;
	private static inline var scaleY:Float = 1.06;

	public var strumTime:Float = 0.0;

	public var effect:ColorMaskEffect;
	public var index(get, set):Int;

	public var isPlayerNote:Bool = true;

	@:noCompletion
	private var _index:Int;

	public function new(index:Int)
	{
		super();

		effect = new ColorMaskEffect();
		shader = effect.shader;

		frames = getFrames();
		syncAnimations();
		setIndex(index);

		scale.set(scaleX, scaleY);
		updateHitbox();
		centerOffsets();
	}

	public function setIndex(index:Int):Void
	{
		_index = index;
		syncIndexColor();
		syncIndexAnimation();
		syncIndexAngle();
	}

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);
		updateHitbox();
		centerOffsets();
	}

	override function centerOffsets(AdjustPosition:Bool = false):Void
	{
		super.centerOffsets(AdjustPosition);
		offset.x -= (swagWidth - width) * 0.5;
		offset.y -= (swagHeight - height) * 0.5;
	}

	public function addAnim(name:String, ?prefix:String, frameRate:Float = 24, looped:Bool = false):Void
	{
		if (prefix == null)
			prefix = name;
		animation.addByPrefix(name, prefix + '0', frameRate, looped);
	}

	public function playAnim(name:String, force:Bool = false):Void
	{
		animation.play(name, force);
		updateHitbox();
		centerOffsets();
	}

	private function getFrames():FlxAtlasFrames
	{
		return Paths.sparrow('note');
	}

	private function syncIndexColor():Void
	{
		var redChannel:FlxColor = 0xffff0000;
		var greenChannel:FlxColor = 0xff00ff00;
		var blueChannel:FlxColor = 0xff0000ff;

		if (isPlayerNote)
		{
			switch (index)
			{
				case 0:
					redChannel = 0xffc24b99;
					blueChannel = 0xff3c1f56;
				case 1:
					redChannel = 0xff00ffff;
					blueChannel = 0xff1542b7;
				case 2:
					redChannel = 0xff12fa05;
					blueChannel = 0xff0a4447;
				case 3:
					redChannel = 0xfff9393f;
					blueChannel = 0xff651038;
			}
		}
		else
		{
			switch (index)
			{
				case 0:
					redChannel = 0xff9a728c;
					blueChannel = 0xff3b3143;
				case 1:
					redChannel = 0xff54aaaa;
					blueChannel = 0xff4a5981;
				case 2:
					redChannel = 0xff5aa955;
					blueChannel = 0xff1e3132;
				case 3:
					redChannel = 0xffb9787a;
					blueChannel = 0xff482c39;
			}
		}
		greenChannel = 0xffffffff;

		effect.redChannel = redChannel;
		effect.greenChannel = greenChannel;
		effect.blueChannel = blueChannel;
	}

	private function syncAnimations():Void
	{
		addAnim('note');
		addAnim('holdpiece');
		addAnim('holdend');
	}

	private function syncIndexAnimation():Void
	{
		playAnim('note', true);
	}

	private function syncIndexAngle():Void
	{
		switch (index)
		{
			case 0:
				angle = 270;
			case 1:
				angle = 180;
			case 2:
				angle = 0;
			case 3:
				angle = 90;
		}
	}

	private function get_index():Int
	{
		return _index;
	}

	private function set_index(value:Int):Int
	{
		setIndex(value);
		return _index;
	}

	@:noCompletion
	override function set_clipRect(rect:FlxRect):FlxRect
	{
		if (rect != null)
			clipRect = rect;
		else
			clipRect = null;

		if (frames != null)
			frame = frames.frames[animation.frameIndex];

		return rect;
	}
}
