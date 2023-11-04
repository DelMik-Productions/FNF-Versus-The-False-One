package engine.ui;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.group.FlxGroup;
import flixel.input.mouse.FlxMouseButton;
import flixel.math.FlxPoint;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxStringUtil;

interface IDragable
{
	public function onBeginDrag(dragger:Dragger):Void;
	public function onDrag(dragger:Dragger):Void;
	public function onEndDrag(dragger:Dragger):Void;
}

typedef FlxMouseButtonPair =
{
	button:FlxMouseButton,
	id:FlxMouseButtonID
};

class Dragger extends FlxBasic
{
	public var buttonID:Null<FlxMouseButtonID>;

	public var currentCameraPosition:FlxPoint;
	public var latestCameraPosition:FlxPoint;

	public var currentWorldPosition:FlxPoint;
	public var movedPosition:FlxPoint;

	public var latestButtonID(default, null):Null<FlxMouseButtonID>;
	public var latestButton(default, null):FlxMouseButton;

	public var selectableTargets:Array<FlxBasic> = [];
	public var currentSelected(default, null):FlxBasic;

	public var ignoreGroup:Bool = false;
	public var groupDirectly:Bool = false;

	public var ignoreTargets:Array<FlxBasic> = [];

	var _buttonPairs:Array<FlxMouseButtonPair>;
	var _currentSelectedDragable:IDragable;

	@:access(flixel.input.mouse.FlxMouse)
	public function new(?ButtonIDS:Array<FlxMouseButtonID>)
	{
		super();

		if (ButtonIDS == null)
		{
			ButtonIDS = [
				LEFT,
				#if FLX_MOUSE_ADVANCED
				RIGHT, //
				MIDDLE,
				#end
			];
		}
		_buttonPairs = [];
		for (id in ButtonIDS)
		{
			_buttonPairs.push({button: FlxMouseButton.getByID(id), id: id});
		}

		currentWorldPosition = FlxPoint.get();
		currentCameraPosition = FlxPoint.get();
		latestCameraPosition = FlxPoint.get();
		movedPosition = FlxPoint.get();
	}

	public function reset():Void
	{
		latestButton = null;
		latestButtonID = null;

		currentSelected = null;

		if (_currentSelectedDragable != null)
		{
			_currentSelectedDragable.onEndDrag(this);
			_currentSelectedDragable = null;
		}
	}

	override function update(elapsed:Float):Void
	{
		updateDragger();
	}

	public function updateDragger():Void
	{
		updateButton();
		updatePosition();
		updateSelected();
	}

	public function updateButton():Void
	{
		if (latestButton != null)
			return;

		if (buttonID == null)
		{
			for (pair in _buttonPairs)
			{
				if (pair.button.justPressed)
				{
					latestButton = pair.button;
					latestButtonID = pair.id;
				}
			}
		}
		else
		{
			latestButton = FlxMouseButton.getByID(buttonID);
			latestButtonID = buttonID;
		}
	}

	public function updatePosition():Void
	{
		FlxG.mouse.getWorldPosition(camera, currentWorldPosition).add(camera.x, camera.y);
		FlxG.mouse.getScreenPosition(camera, currentCameraPosition).add(camera.x, camera.y);

		if (latestButton != null)
		{
			if (latestButton.justPressed)
			{
				latestCameraPosition.copyFrom(currentCameraPosition);
			}
			if (latestButton.justReleased)
			{
				reset();
			}

			movedPosition.set(currentCameraPosition.x - latestCameraPosition.x, currentCameraPosition.y - latestCameraPosition.y);

			if (_currentSelectedDragable != null && !movedPosition.isZero())
			{
				_currentSelectedDragable.onDrag(this);
			}
		}
		else
		{
			latestCameraPosition.copyFrom(currentCameraPosition);
			movedPosition.set();
		}
	}

	public function updateSelected():Void
	{
		if (latestButton == null || selectableTargets == null || selectableTargets.length < 1)
			return;

		if (latestButton.justPressed)
		{
			currentSelected = findSelected(selectableTargets);

			if (currentSelected != null && currentSelected is IDragable)
			{
				_currentSelectedDragable = cast currentSelected;
				_currentSelectedDragable.onBeginDrag(this);
			}
		}
	}

	private function findSelected(targets:Array<FlxBasic>):FlxBasic
	{
		var i:Int = targets.length;
		var basic:FlxBasic;
		while (i > 0)
		{
			basic = targets[--i];

			if (!basic.exists || !basic.visible || ignoreTargets.indexOf(basic) > -1)
				continue;

			if (_cameras != null && _cameras[0] != null && _cameras[0] != basic.camera)
				continue;

			if (!groupDirectly && (basic.flixelType == GROUP || basic.flixelType == SPRITEGROUP))
			{
				@:privateAccess
				var group = FlxTypedGroup.resolveGroup(basic);
				var result = findSelected(group.members);
				if (result == null || ignoreGroup)
					continue;
				return result;
			}

			if (overlapsPoint(basic))
			{
				return basic;
			}
		}
		return null;
	}

	private function overlapsPoint(basic:FlxBasic):Bool
	{
		if (basic == null && basic.cameras.indexOf(camera) > -1)
			return false;

		if (basic is FlxObject)
		{
			var object:FlxObject = cast basic;
			if (object.overlapsPoint(currentWorldPosition, camera))
				return true;
		}

		return false;
	}

	public function ignore(basic:FlxBasic):Void
	{
		if (ignoreTargets.indexOf(basic) < 0)
		{
			ignoreTargets.push(basic);
		}
	}

	override function destroy():Void
	{
		currentWorldPosition = FlxDestroyUtil.destroy(currentWorldPosition);
		currentCameraPosition = FlxDestroyUtil.destroy(currentCameraPosition);
		latestCameraPosition = FlxDestroyUtil.destroy(latestCameraPosition);
		movedPosition = FlxDestroyUtil.destroy(movedPosition);

		buttonID = null;
		latestButtonID = null;
		latestButton = null;

		currentSelected = null;
		_currentSelectedDragable = null;

		selectableTargets = null;
		_buttonPairs = null;

		super.destroy();
	}

	override function toString():String
	{
		return FlxStringUtil.getDebugString([
			LabelValuePair.weak('id', latestButtonID),
			LabelValuePair.weak('moved', movedPosition),
		]);
	}
}
