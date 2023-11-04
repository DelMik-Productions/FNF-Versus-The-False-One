package engine.substates.transition;

import engine.effects.GradientEffect;
import engine.states.MusicBeatState;
import engine.utils.MathUtil;
import flixel.util.FlxColor;

typedef TransitionData =
{
	cl:Class<Transition>,
	duration:Float,
}

typedef Transition = BaseTransition;

class BaseTransition extends MusicBeatSubState
{
	public static var defaultTransIn:TransitionData;
	public static var defaultTransOut:TransitionData;

	public static function createTransition(data:TransitionData):Transition
	{
		if (data == null)
			return null;

		var trans:Transition = Type.createInstance(data.cl, [MusicBeatState.current, data.duration]);
		return trans;
	}

	@:access(engine.substates.transition.FadeTransition)
	public static function init():Void
	{
		FadeTransition.effect = new GradientEffect(FlxColor.BLACK, 1080, 1080 * FadeTransition.GRADIENT_SCALE);

		defaultTransIn = {
			cl: FadeTransition,
			duration: 0.46,
		}
		defaultTransOut = {
			cl: FadeTransition,
			duration: 0.51,
		}
	}

	public var nextState:MusicBeatState;
	public var finishCallback:Void->Void;
	public var duration:Float;
	public var fadeIn:Bool = false;

	var _delta:Float = 0;

	public function new(parentMusicState:MusicBeatState, Duration:Float)
	{
		super(parentMusicState);
		duration = Duration;
	}

	public function play():Void
	{
		_delta = 0;
	}

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		_delta += elapsed;

		onUpdate(MathUtil.clamp(_delta, 0, duration) / duration);

		if (_delta >= duration)
		{
			onComplete();
		}
	}

	public function onUpdate(percent:Float):Void
	{
	}

	public function onComplete():Void
	{
		if (finishCallback != null)
			finishCallback();
		finishCallback = null;
	}
}
