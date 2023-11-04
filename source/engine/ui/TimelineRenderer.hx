package engine.ui;

import engine.timeline.BezierEasing;
import engine.timeline.Keyframe;
import engine.timeline.StringTimeline;
import engine.timeline.Timeline;
import engine.utils.MathUtil;
import engine.utils.Paths;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.plugin.taskManager.FlxTaskManager;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.util.FlxSpriteUtil;
import openfl.display.Graphics;

class TimelineRenderer extends FlxSpriteGroup
{
	public var xRange(get, set):Float;
	public var yRange(get, set):Float;

	public var xOffset(get, set):Float;
	public var yOffset(get, set):Float;

	public var minRange:FlxPoint = FlxPoint.get(0.0, 0.0);
	public var maxRange:FlxPoint = FlxPoint.get(1.0, 1.0);

	public var timeline(get, set):Timeline;
	public var selected(default, null):Int = -1;

	public var curve:FlxSprite;
	public var handles:FlxSpriteGroup;

	public var inHandle:FlxSprite;
	public var outHandle:FlxSprite;

	public var isString:Bool = false;

	private var _timeline:Timeline;
	private var horizontalLabels:FlxTypedSpriteGroup<FlxText>;
	private var verticalLabels:FlxTypedSpriteGroup<FlxText>;

	public function new(timeline:Timeline, ?width:Int, ?height:Int)
	{
		super();

		_timeline = timeline;

		if (width == null)
			width = FlxG.width;
		if (height == null)
			height = 380;

		curve = new FlxSprite();
		curve.makeGraphic(width, height);
		add(curve);

		handles = new FlxSpriteGroup();
		add(handles);

		inHandle = new FlxSprite(Paths.image('circle', 'ui'));
		inHandle.color = 0xffff0000;
		inHandle.exists = false;
		add(inHandle);

		outHandle = new FlxSprite(Paths.image('circle', 'ui'));
		outHandle.color = 0xff0000ff;
		outHandle.exists = false;
		add(outHandle);

		horizontalLabels = new FlxTypedSpriteGroup();
		add(horizontalLabels);
		verticalLabels = new FlxTypedSpriteGroup();
		add(verticalLabels);

		updateGrid();
		updateCurve();
		updateHandles();
	}

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}

	public function updateGrid():Void
	{
		horizontalLabels.group.killMembers();
		verticalLabels.group.killMembers();
	}

	public function getTick(v:Float):Float
	{
		if (v <= 0.18)
			return 0.01;
		else if (v <= 1.2)
			return 0.1;
		else if (v <= 11.0)
			return 1.0;
		else if (v <= 19.0)
			return 2.0;
		return 2.0;
	}

	public function updateCurve():Void
	{
		if (timeline == null)
			return;

		var graphics:Graphics = FlxSpriteUtil.flashGfx;
		graphics.clear();

		graphics.lineStyle(2, 0xff808080);
		var step:Float = getTick(xRange);
		var x:Float = MathUtil.quantize(minRange.x, step);
		while (x <= maxRange.x)
		{
			graphics.moveTo(MathUtil.inverseLerp(minRange.x, maxRange.x, x) * curve.width, 0);
			graphics.lineTo(MathUtil.inverseLerp(minRange.x, maxRange.x, x) * curve.width, curve.height);
			x += step;
		}

		var step:Float = getTick(yRange);
		var y:Float = MathUtil.quantize(maxRange.y, step);
		while (y >= minRange.y)
		{
			graphics.moveTo(0, MathUtil.inverseLerp(maxRange.y, minRange.y, y) * curve.height);
			graphics.lineTo(curve.width, MathUtil.inverseLerp(maxRange.y, minRange.y, y) * curve.height);
			y -= step;
		}

		graphics.lineStyle(3, 0xff00ff00);
		graphics.moveTo(getX(0), getY(0));

		var duration:Float = 0.0;
		if (timeline.keys.length > 1)
			duration = (timeline.keys[timeline.keys.length - 1].time - timeline.keys[0].time);

		var t:Float = 0.0, step:Float = (xRange / duration) * 0.01;
		while (t < 1.0)
		{
			t = Math.min(t + step, 1.0);
			graphics.lineTo(getX(t), getY(t));
		}

		if (selected > -1)
		{
			var handle:FlxSprite = null;
			handles.forEachAlive(spr ->
			{
				if (spr.ID == selected)
				{
					handle = spr;
				}
			});

			if (selected > 0)
			{
				graphics.lineStyle(5, 0xffa60000);
				graphics.moveTo(handle.x - this.x + (handle.width * 0.5), handle.y - this.y + (handle.height * 0.5));
				var keyframe:Keyframe = timeline.keys[selected];
				var toX:Float = toCurveX(keyframe.time - ((keyframe.time - timeline.keys[selected - 1].time) * keyframe.inWeight));
				var toY:Float = toCurveY(keyframe.value - ((keyframe.value - timeline.keys[selected - 1].value) * keyframe.inWeight * keyframe.inTangent));
				graphics.lineTo(toX - curve.x, toY - curve.y);
			}
			if (selected < timeline.keys.length - 1)
			{
				graphics.lineStyle(5, 0xff0000a6);
				graphics.moveTo(handle.x - this.x + (handle.width * 0.5), handle.y - this.y + (handle.height * 0.5));
				var keyframe:Keyframe = timeline.keys[selected];
				var toX:Float = toCurveX(keyframe.time + ((timeline.keys[selected + 1].time - keyframe.time) * keyframe.outWeight));
				var toY:Float = toCurveY(keyframe.value + ((timeline.keys[selected + 1].value - keyframe.value) * keyframe.outWeight * keyframe.outTangent));
				graphics.lineTo(toX - curve.x, toY - curve.y);
			}
		}

		graphics.endFill();

		curve.pixels.fillRect(curve.pixels.rect, 0xff404040);
		curve.pixels.draw(FlxSpriteUtil.flashGfxSprite);
	}

	public function updateHandles():Void
	{
		handles.group.killMembers();
		if (timeline == null)
			return;

		for (index => keyframe in timeline.keys)
		{
			var time:Float = keyframe.time;
			var value:Float = keyframe.value;
			if (time >= minRange.x && time <= maxRange.x && value >= minRange.y && value <= maxRange.y)
			{
				var handle:FlxSprite = handles.recycle(FlxSprite);
				handle.loadGraphic(Paths.image('circle', 'ui'));
				handle.x = FlxMath.remapToRange(time, minRange.x, maxRange.x, x, curve.x + curve.width) - (handle.width * 0.5);
				handle.y = FlxMath.remapToRange(value, minRange.y, maxRange.y, curve.y + curve.height, curve.y) - (handle.height * 0.5);
				handle.ID = index;
			}
		}
	}

	public function select(index:Int):Void
	{
		var handle:FlxSprite = null;
		var sprIndex:Int = -1;
		handles.forEachAlive(spr ->
		{
			if (spr.ID == index)
			{
				handle = spr;
				sprIndex = handles.members.indexOf(spr);
			}
		});

		inHandle.exists = false;
		outHandle.exists = false;
		selected = -1;

		if (sprIndex > -1)
		{
			if (index > 0)
				inHandle.exists = true;
			if (index < timeline.keys.length - 1)
				outHandle.exists = true;
			selected = index;
			updateInOutHandles();
		}
		updateCurve();
	}

	public function updateInOutHandles():Void
	{
		if (selected > -1)
		{
			var keyframe:Keyframe = timeline.keys[selected];
			if (selected > 0)
			{
				var weight:Float = (keyframe.time - timeline.keys[selected - 1].time);
				inHandle.x = toCurveX(keyframe.time - (weight * keyframe.inWeight)) - (inHandle.width * 0.5);
				var weight:Float = (keyframe.value - timeline.keys[selected - 1].value);
				inHandle.y = toCurveY(keyframe.value - (weight * keyframe.inWeight * keyframe.inTangent)) - (inHandle.height * 0.5);
				inHandle.exists = curve.overlaps(inHandle);
			}

			if (selected < timeline.keys.length - 1)
			{
				var weight:Float = (timeline.keys[selected + 1].time - keyframe.time);
				outHandle.x = toCurveX(keyframe.time + (weight * keyframe.outWeight)) - (outHandle.width * 0.5);
				var weight:Float = (timeline.keys[selected + 1].value - keyframe.value);
				outHandle.y = toCurveY(keyframe.value + (weight * keyframe.outWeight * keyframe.outTangent)) - (outHandle.height * 0.5);
				outHandle.exists = curve.overlaps(outHandle);
			}
		}
	}

	public function isHandle(spr:FlxSprite):Bool
	{
		return (handles.members.indexOf(spr) > -1 || spr == inHandle || spr == outHandle);
	}

	public function toCurveX(x:Float):Float
	{
		return FlxMath.remapToRange(x, minRange.x, maxRange.x, curve.x, curve.x + curve.width);
	}

	public function toCurveY(y:Float):Float
	{
		return FlxMath.remapToRange(y, minRange.y, maxRange.y, curve.y + curve.height, curve.y);
	}

	public function fromCurveX(x:Float):Float
	{
		return FlxMath.remapToRange(x, curve.x, curve.x + curve.width, minRange.x, maxRange.x);
	}

	public function fromCurveY(y:Float):Float
	{
		return FlxMath.remapToRange(y, curve.y + curve.height, curve.y, minRange.y, maxRange.y);
	}

	private function getX(ratio:Float):Float
	{
		return ratio * curve.width;
	}

	private function getY(ratio:Float):Float
	{
		return FlxMath.remapToRange(calculate(FlxMath.lerp(minRange.x, maxRange.x, ratio)), minRange.y, maxRange.y, curve.height, 0);
	}

	public function calculate(time:Float):Float
	{
		if (timeline == null)
			return 0.0;

		var keys:Array<Keyframe> = timeline.keys;
		if (keys.length == 0)
			return 0.0;
		else if (keys.length == 1)
			return keys[0].value;

		time = timeline.wrapTime(time);
		for (i in 0...keys.length - 1)
		{
			var keyframe:Keyframe = keys[i];
			var nextKeyframe:Keyframe = keys[i + 1];
			if (time >= keyframe.time && time <= nextKeyframe.time)
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

	public function changeTimeline(timeline:Timeline):Void
	{
		_timeline = timeline;
		select(-1);
		if (curve != null && _timeline != null)
		{
			updateCurve();
			updateHandles();
		}
		isString = (timeline is StringTimeline);
	}

	private function get_timeline():Timeline
	{
		return _timeline;
	}

	private function set_timeline(value:Timeline):Timeline
	{
		changeTimeline(value);
		return timeline;
	}

	private function get_xRange():Float
	{
		return maxRange.x - minRange.x;
	}

	private function set_xRange(value:Float):Float
	{
		var midX:Float = minRange.x + (xRange * 0.5);
		minRange.x = midX - (value * 0.5);
		maxRange.x = midX + (value * 0.5);
		return value;
	}

	private function get_yRange():Float
	{
		return maxRange.y - minRange.y;
	}

	private function set_yRange(value:Float):Float
	{
		var midY:Float = minRange.y + (yRange * 0.5);
		minRange.y = midY - (value * 0.5);
		maxRange.y = midY + (value * 0.5);
		return value;
	}

	private function get_xOffset():Float
	{
		return minRange.x;
	}

	private function set_xOffset(value:Float):Float
	{
		var xRange:Float = maxRange.x - minRange.x;
		minRange.x = value;
		maxRange.x = value + xRange;
		return value;
	}

	private function get_yOffset():Float
	{
		return minRange.y;
	}

	private function set_yOffset(value:Float):Float
	{
		var yRange:Float = maxRange.y - minRange.y;
		minRange.y = value;
		maxRange.y = value + yRange;
		return value;
	}
}
