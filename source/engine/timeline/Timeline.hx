package engine.timeline;

import engine.utils.MathUtil;
import flixel.math.FlxMath;
import flixel.util.FlxSort;

enum TimelineType
{
	FLOAT;
	STRING(values:Array<String>);
}

typedef TimelineData =
{
	var type:TimelineType;
	var keys:Array<Keyframe>;
	var preWrapMode:WrapMode;
	var postWrapMode:WrapMode;
}

class Timeline
{
	public var keys:Array<Keyframe> = [];
	public var preWrapMode:WrapMode;
	public var postWrapMode:WrapMode;

	public function new()
	{
		preWrapMode = CONSTANT;
		postWrapMode = CONSTANT;
	}

	public function clear():Void
	{
		keys = [];
		preWrapMode = CONSTANT;
		postWrapMode = CONSTANT;
	}

	public function addKeyValue(time:Float, value:Float):Void
	{
		addKey(Keyframe.create(time, value));
	}

	public function addKeyValueEx(time:Float, value:Float, inTangent:Float, inWeight:Float, outTangent:Float, outWeight:Float):Void
	{
		addKey(Keyframe.createEx(time, value, inTangent, inWeight, outTangent, outWeight));
	}

	public function addKey(keyframe:Keyframe):Void
	{
		keys.push(keyframe);
		keys.sort((a, b) -> FlxSort.byValues(FlxSort.ASCENDING, a.time, b.time));
	}

	public function calculate(time:Float):Dynamic
	{
		if (keys.length == 0)
			return 0.0;
		else if (keys.length == 1)
			return keys[0].value;

		time = wrapTime(time);
		for (i in 0...keys.length - 1)
		{
			var keyframe:Keyframe = keys[i];
			var nextKeyframe:Keyframe = keys[i + 1];
			if (time >= keyframe.time && time < nextKeyframe.time)
			{
				var x1:Float = keyframe.outWeight;
				var y1:Float = keyframe.outWeight * keyframe.outTangent;
				var x2:Float = 1.0 - nextKeyframe.inWeight;
				var y2:Float = 1.0 - nextKeyframe.inWeight * nextKeyframe.inTangent;
				var ratio:Float = MathUtil.inverseLerp(keyframe.time, nextKeyframe.time, time);
				var value:Float = BezierEasing.calcValue(x1, y1, x2, y2, ratio);
				return FlxMath.lerp(keyframe.value, nextKeyframe.value, value);
			}
		}
		return 0.0;
	}

	public function wrapTime(time:Float):Float
	{
		if (keys.length > 1)
		{
			var startTime:Float = keys[0].time;
			var endTime:Float = keys[keys.length - 1].time;

			if (time < startTime)
			{
				switch (preWrapMode)
				{
					case CONSTANT:
						time = startTime;
					case LOOPING:
						var max:Float = endTime - startTime;
						time = (max - MathUtil.repeatAB(time * -1, 0.0, max)) + startTime;
					case PINGPONG:
						time = MathUtil.pingpongAB(time * -1, 0.0, endTime - startTime) + startTime;
					case LOOPED(from, to):
						time = MathUtil.repeatAB(time * -1, 0.0, to - from) + from;
				}
			}
			else if (time > endTime)
			{
				switch (postWrapMode)
				{
					case CONSTANT:
						time = endTime;
					case LOOPING:
						time = MathUtil.repeatAB(time - endTime, 0.0, endTime + startTime) + startTime;
					case PINGPONG:
						var max:Float = endTime - startTime;
						time = (max - MathUtil.pingpongAB(time - endTime, 0.0, max)) + startTime;
					case LOOPED(from, to):
						time = MathUtil.repeatAB(time - endTime, 0.0, to - from) + from;
				}
			}
		}

		return time;
	}
}
