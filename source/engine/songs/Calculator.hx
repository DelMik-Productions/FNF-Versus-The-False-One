package engine.songs;

import engine.states.PlayState;

class Calculator
{
	public var bpm(default, null):Float;
	public var crochet(default, null):Float;
	public var stepCrochet(default, null):Float;

	public var curBeat:Int = -1;
	public var curStep:Int = -1;

	public var bpmEvents:Array<EventData> = [];

	private var curBPMEventIndex:Int = -1;
	private var nextBPMEventStrumTime:Float = 0.0;

	private var lastStep:Int = 0;
	private var lastStepOffset:Float = 0.0;
	private var lastPosition:Float = 0.0;

	public function new()
	{
	}

	public function resetBPM(bpm:Float):Void
	{
		setBPM(bpm);
		bpmEvents[0] = {
			strumTime: 0.0,
			eventValue: bpm
		}
	}

	public function addBPMEvent(strumTime:Float, bpm:Float):Void
	{
		bpmEvents.push({strumTime: strumTime, eventValue: bpm});
	}

	private function setBPM(newBPM:Float):Void
	{
		bpm = newBPM;
		crochet = (60.0 / bpm) * 1000.0;
		stepCrochet = ((60.0 / bpm) * 1000.0) / 4.0;
	}

	public function calculcate(songPosition:Float):Void
	{
		if (songPosition >= 0.0)
		{
			if (songPosition >= nextBPMEventStrumTime && curBPMEventIndex < bpmEvents.length - 1)
			{
				var newBPM:Float = bpmEvents[bpmEvents.length - 1].eventValue;
				for (i in (curBPMEventIndex + 1)...bpmEvents.length - 1)
				{
					var event:EventData = bpmEvents[i];
					var nextEvent:EventData = bpmEvents[i + 1];

					var stepPosition:Float = (nextEvent.strumTime - lastPosition + lastStepOffset);
					var stepCrochet:Float = ((60.0 / event.eventValue) * 1000.0) / 4.0;
					var step:Int = Math.floor(stepPosition / stepCrochet);

					lastStep += step;
					lastStepOffset = nextEvent.strumTime - lastPosition - (step * stepCrochet);
					lastPosition = nextEvent.strumTime;

					if (songPosition >= event.strumTime && songPosition < nextEvent.strumTime)
					{
						newBPM = event.eventValue;
						curBPMEventIndex = i;
						nextBPMEventStrumTime = nextEvent.strumTime;
						break;
					}
				}

				setBPM(newBPM);
			}

			var position:Float = songPosition - lastPosition;
			curStep = lastStep + Math.floor((position + lastStepOffset) / stepCrochet);
			curBeat = Std.int(curStep / 4.0);
		}
	}

	public function calculateBPM(strumTime:Float):Float
	{
		for (i in 0...bpmEvents.length - 1)
		{
			var event:EventData = bpmEvents[i];
			var nextEvent:EventData = bpmEvents[i + 1];
			if (strumTime >= event.strumTime && strumTime < nextEvent.strumTime)
			{
				return event.eventValue;
			}
		}
		return bpmEvents[bpmEvents.length - 1].eventValue;
	}

	public function calculateStepCrochet(strumTime:Float):Float
	{
		return ((60.0 / calculateBPM(strumTime)) * 1000.0) / 4.0;
	}

	public function calculateBpmCutPosition(strumTime:Float, stepCrochet:Float):Float
	{
		var curPosition:Float = strumTime + stepCrochet;
		for (i in 0...bpmEvents.length)
		{
			var event:EventData = bpmEvents[i];
			if (event.strumTime >= strumTime && event.strumTime <= strumTime + stepCrochet)
			{
				curPosition = event.strumTime;
			}
		}
		return curPosition;
	}
}
