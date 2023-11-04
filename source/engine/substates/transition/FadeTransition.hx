package engine.substates.transition;

import engine.effects.GradientEffect;
import flixel.math.FlxMath;
import openfl.filters.ShaderFilter;

class FadeTransition extends Transition
{
	private static inline var GRADIENT_SCALE:Float = 1 / 5 * 3;
	private static var effect:GradientEffect;

	var filter:ShaderFilter = new ShaderFilter(effect.shader);

	var from:Float;
	var to:Float;

	override function create():Void
	{
		super.create();

		if (fadeIn)
		{
			from = -effect.top;
			to = effect.top + effect.height;
		}
		else
		{
			from = -(effect.top + effect.height + effect.bottom);
			to = -effect.top;
		}

		if (camOther.filters == null)
			camOther.filters = [];
		camOther.filters.push(filter);
	}

	override function onUpdate(percent:Float):Void
	{
		effect.offset = FlxMath.lerp(from, to, percent);
	}

	@:access(engine.flixel.FlxCamera)
	override function destroy():Void
	{
		camOther.filters.remove(filter);
		super.destroy();
	}
}
