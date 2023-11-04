package;

import engine.substates.transition.Transition;
import flixel.FlxGame;
import openfl.Lib;
import openfl.display.Sprite;
import openfl.events.Event;
import versus.states.TitleState;

class Main extends Sprite
{
	@:noCompletion
	static function main():Void
	{
		Lib.application.window.resizable = false;
		Lib.current.addChild(new Main());

		#if debug
		new ImportAll();
		#end
	}

	public function new()
	{
		super();

		if (stage != null)
		{
			init();
		}
		else
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}

	private function init(?e:Event):Void
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}

		setupGame();
	}

	private function setupGame():Void
	{
		Transition.init();
		addChild(new FlxGame(1920, 1080, TitleState, 160, 160, true, false));
	}
}
