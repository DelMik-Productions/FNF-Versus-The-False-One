/* package engine.ui;

import engine.states.PlayState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.group.FlxSpriteGroup;

class TimelineHandler extends FlxSpriteGroup
{
	public var playState:PlayState;

	public var background:FlxSprite;
	public var renderer:TimelineRenderer;

	public var labelMenu:FlxUIDropDownMenu;

	public function new(playState:PlayState)
	{
		super();
		this.playState = playState;

		background = new FlxSprite();
		background.makeGraphic(FlxG.width, 380, 0xff808080);
		add(background);

		renderer = new TimelineRenderer(null, 1640, 320);
		renderer.x = FlxG.width - 1640 - 30;
		renderer.y = 30;
		add(renderer);

		labelMenu = new FlxUIDropDownMenu(30, 30, FlxUIDropDownMenu.makeStrIdLabelArray(playState.labels), setRenderTarget);
		for (button in labelMenu.list)
		{
			button.onDown.callback = button.onUp.callback;
			button.onUp.callback = null;
		}
		add(labelMenu);

		setRenderTarget(playState.labels[0]);
	}

	public function setRenderTarget(label:String):Void
	{
		var index:Int = playState.labels.indexOf(label);
		if (index > -1)
		{
			labelMenu.selectedLabel = label;
			renderer.changeTimeline(playState.timelines[index]);
		}
	}
}
 */