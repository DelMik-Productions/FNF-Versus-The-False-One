package engine.states;

import engine.substates.transition.Transition;
import flixel.FlxG;
import flixel.FlxState;

class TransitionState extends FlxState
{
	public var transIn:TransitionData;
	public var transOut:TransitionData;

	private var _nextState:FlxState;

	public function new(?TransIn:TransitionData, ?TransOut:TransitionData)
	{
		super();

		if (TransIn == null)
			TransIn = Transition.defaultTransIn;
		if (TransOut == null)
			TransOut = Transition.defaultTransOut;

		transIn = TransIn;
		transOut = TransOut;
	}

	public function fadeIn():Void
	{
		var _transIn = Transition.createTransition(transIn);
		if (_transIn != null)
		{
			_transIn.fadeIn = true;

			var state:FlxState = this;
			while (state.subState != null)
			{
				state = state.subState;
			}
			state.openSubState(_transIn);

			_transIn.finishCallback = closeSubState;
			_transIn.play();
		}
	}

	public function fadeOut(NextState:MusicBeatState):Void
	{
		_nextState = NextState;

		var _transOut = Transition.createTransition(transOut);
		if (_transOut == null)
		{
			onFadeOut();
		}
		else
		{
			var state:FlxState = this;
			while (state.subState != null)
			{
				state = state.subState;
			}
			state.openSubState(_transOut);

			_transOut.finishCallback = onFadeOut;
			_transOut.play();
		}
	}

	private function onFadeOut():Void
	{
		FlxG.switchState(_nextState);
	}
}
