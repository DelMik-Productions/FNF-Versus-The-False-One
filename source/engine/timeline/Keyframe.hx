package engine.timeline;

class Keyframe
{
	public static function create(time:Float, value:Float):Keyframe
	{
		return new Keyframe(time, value, 0.0, 0.0, 0.0, 0.0);
	}

	public static function createEx(time:Float, value:Float, inTangent:Float, inWeight:Float, outTangent:Float, outWeight:Float):Keyframe
	{
		return new Keyframe(time, value, inTangent, inWeight, outTangent, outWeight);
	}

	public var time:Float;
	public var value:Float;
	public var inTangent:Float;
	public var inWeight:Float;
	public var outTangent:Float;
	public var outWeight:Float;

	private function new(time:Float, value:Float, inTangent:Float, inWeight:Float, outTangent:Float, outWeight:Float)
	{
		this.time = time;
		this.value = value;
		this.inTangent = inTangent;
		this.inWeight = inWeight;
		this.outTangent = outTangent;
		this.outWeight = outWeight;
	}

	public function toString():String
	{
		return '(time: $time, value: $value, inTangent: $inTangent, outTangent: $outTangent, inWeight: $inWeight, outWeight: $outWeight)';
	}
}
