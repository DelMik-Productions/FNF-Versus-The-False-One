package engine.utils;

import flixel.math.FlxMath;

@:build(macros.StaticaFieldsBuilder.build())
class MathUtil
{
	public static inline var PI:Float = 3.14159265358979323846;
	public static inline var PI2:Float = 1.57079632679489661923;

	/**
	 * Clamps a value between a minimum and maximum value.
	 */
	public function clamp(value:Float, min:Float, max:Float):Float
	{
		if (value > max)
			return max;
		else if (value < min)
			return min;
		return value;
	}

	public inline function clamp01(value:Float):Float
	{
		return clamp(value, 0.0, 1.0);
	}

	public function clampInt(value:Int, min:Int, max:Int):Int
	{
		if (value > max)
			return max;
		else if (value < min)
			return min;
		return value;
	}

	public inline function lerp(a:Float, b:Float, ratio:Float):Float
	{
		return FlxMath.lerp(a, b, clamp01(ratio));
	}

	public inline function inBounds(Value:Float, Min:Float, Max:Float):Bool
	{
		return Value >= Min && Value <= Max;
	}

	/**
	 * Loops the value t, so that it is never larger than length and never smaller than 0.
	 * @param float t
	 * @param float length
	 */
	public function repeat(t:Float, length:Float):Float
	{
		return clamp(t - Math.floor(t / length) * length, 0.0, length);
	}

	public function repeatAB(t:Float, start:Float, end:Float):Float
	{
		return start + repeat(t - start, end - start);
	}

	/**
	 * Loops the value t, so that it is never larger than length and never smaller than 0.
	 * @param float t
	 * @param float length
	 */
	public inline function repeatInt(t:Int, length:Int):Int
	{
		return Std.int(repeat(t, length));
	}

	/**
	 * PingPongs the value t, so that it is never larger than length and never smaller than 0.
	 */
	public function pingpong(t:Float, length:Float):Float
	{
		t = repeat(t, length * 2);
		return length - Math.abs(t - length);
	}

	public function pingpongAB(t:Float, start:Float, end:Float):Float
	{
		return start + pingpong(t - start, end - start);
	}

	/**
	 * check number is zero.
	 */
	public inline function isZero(n:Float):Bool
	{
		return FlxMath.equal(n, 0.0);
	}

	/**
	 * ko @see https://ko.wikipedia.org/wiki/양자화_(물리학)
	 * 
	 * en @see https://en.wikipedia.org/wiki/Quantization_(signal_processing)
	 */
	public inline function quantize(f:Float, snap:Float):Float
	{
		var m:Float = Math.fround(f * snap);
		return (m / snap);
	}

	public function formatDecimal(v:Float, l:Int):String
	{
		if (l < 1)
			return Std.string(Math.round(v));

		var s:String = Std.string(FlxMath.roundDecimal(v, l));
		if (s.indexOf('.') < 0)
		{
			s += '.';
			for (_ in 0...l)
				s += '0';
		}
		else
		{
			for (_ in 0...(s.length - s.indexOf('.') - l - 1))
				s += '0';
		}
		return s;
	}

	/**
	 * Examples:
	 *
	 * ```haxe
	 * lerp(a, b, a) = 0
	 * lerp(a, b, b) = 1
	 * lerp(5, 15, 10) = 0.5
	 * lerp(5, 15, -5) = -1
	 * ```
	 */
	public inline function inverseLerp(a:Float, b:Float, value:Float):Float
	{
		return (value - a) / (b - a);
	}

	/**
	 * check the point is in the shape with even-odd algorithm
	 * @see https://en.wikipedia.org/wiki/Even%E2%80%93odd_rule
	 */
	public function isPointInPath(pointX:Float, pointY:Float, poly:Array<Float>):Bool
	{
		var num:Int = Std.int(poly.length / 2);
		var j:Int = num - 1;
		var c:Bool = false;
		for (i in 0...num)
		{
			if (pointX == poly[i] && pointY == poly[i + 1])
				return true;

			if ((poly[i + 1] > pointY) != (poly[j + 1] > pointY))
			{
				var slope:Float = (pointX - poly[i]) * (poly[j + 1] - poly[i + 1]) - (poly[j] - poly[i]) * (pointY - poly[i + 1]);

				if (slope == 0)
					return true;

				if ((slope < 0) != (poly[j + 1] < poly[i + 1]))
					c = !c;
			}
		}
		return c;
	}

	public function formatLevel(v:Float, step:Float):Int
	{
		return (v < 1.0) ? 0 : Std.int((v - 1.0) / 0.8);
	}

	public function formatValue(v:Float, step:Float):Float
	{
		return (v < 1.0) ? v : 0.2 + (v - 1.0) % 0.8;
	}

	public function areLinesIntersecting(x1:Float, y1:Float, x2:Float, y2:Float, x3:Float, y3:Float, x4:Float, y4:Float):Bool
	{
		return (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4) != 0;
	}

	public function getIntersectionPoint(x1:Float, y1:Float, x2:Float, y2:Float, x3:Float, y3:Float, x4:Float, y4:Float):Array<Float>
	{
		var det:Float = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4);

		if (det != 0)
		{
			var t:Float = ((x1 - x3) * (y3 - y4) - (y1 - y3) * (x3 - x4)) / det;
			return [x1 + t * (x2 - x1), y1 + t * (y2 - y1)];
		}

		return [];
	}
}
