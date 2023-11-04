package engine.timeline;

class FieldTimeline
{
	public var timeline:Timeline;
	public var parentRef:Dynamic;
	public var field:String;

	public var time:Float = 0.0;

	public function new(timeline:Timeline, parentRef:Dynamic, field:String)
	{
		this.timeline = timeline;
		this.parentRef = parentRef;
		this.field = field;
	}

	public function applyTime(time:Float):Void
	{
		this.time = time;
		apply();
	}

	public function apply():Void
	{
		Reflect.setProperty(parentRef, field, timeline.calculate(time));
	}
}
