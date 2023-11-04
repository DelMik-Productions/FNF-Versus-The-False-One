package engine.timeline;

class StringTimeline extends Timeline
{
	public var values:Array<String> = [];

	public function new(values:Array<String>)
	{
		super();
		this.values = values;
	}

	override function calculate(time:Float):String
	{
		return values[Std.int(super.calculate(time))];
	}
}
