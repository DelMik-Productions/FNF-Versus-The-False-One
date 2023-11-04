package versus.states;

import engine.effects.DrunkEffect;
import engine.objects.Character;
import engine.states.PlayState.EventData;
import engine.utils.MathUtil;
import engine.utils.Paths;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import haxe.Json;
import openfl.filters.ShaderFilter;

class PlayState extends engine.states.PlayState
{
	public var curState:Int = 0;
	public var beatPosition:Array<EventData> = [
		{
			strumTime: 57050.0,
			eventValue: 0.06,
		},
		{
			strumTime: 73601.72,
			eventValue: 0.06,
		},
		{
			strumTime: 84636.2,
			eventValue: 0.06,
		},
		{
			strumTime: 106705.17,
			eventValue: 0.06,
		},
		{
			strumTime: 111877.58,
			eventValue: 0.075,
		},
		{
			strumTime: 112222.41,
			eventValue: 0.075,
		},
		{
			strumTime: 112394.82,
			eventValue: 0.075,
		},
		{
			strumTime: 117739.65,
			eventValue: 0.06,
		},
		{
			strumTime: 117912.07,
			eventValue: 0.06,
		},
		{
			strumTime: 166015.51,
			eventValue: 0.075,
		},
		{
			strumTime: 171532.76,
			eventValue: 0.075,
		},
		{
			strumTime: 188084.48,
			eventValue: 0.06,
		},
		{
			strumTime: 199118.96,
			eventValue: 0.06,
		}
	];
	public var beat:Int = 0;

	// First Stage
	private var bg:FlxSprite;
	private var bg2:FlxSprite;
	private var bg3:FlxSprite;

	// Second Stage
	private var bg4:FlxSprite;

	// Effects
	private var drunk:DrunkEffect;
	private var board:FlxSprite;

	private var mirror:Character;

	override function init():Void
	{
		super.init();

		defaultCameraZoomValue = 1.15;
		camGame.zoom = 1.15;

		drunk = new DrunkEffect();
		drunk.intensity = 0.0;
		camGame.filters = [new ShaderFilter(drunk.shader)];
	}

	override function addBackground():Void
	{
		bg4 = new FlxSprite(0, -870, Paths.image('subterfuge/bg4'));
		bg4.screenCenter(X);
		bg4.visible = false;
		add(bg4);

		bg = new FlxSprite(Paths.image('subterfuge/bg'));
		add(bg);

		bg2 = new FlxSprite(Paths.image('subterfuge/bg2'));
		add(bg2);
	}

	override function addPlayElements():Void
	{
		super.addPlayElements();

		opponent.setPosition(484, 353);
		player.setPosition(1052, 353);

		remove(opponent);
		insert(members.indexOf(bg2), opponent);

		mirror = new Character('boyfriendLittle');
		mirror.setPosition(473, 353);
		mirror.flipX = true;
		mirror.alpha = 0.0;
		insert(members.indexOf(opponent) + 1, mirror);

		bg3 = new FlxSprite(Paths.image('subterfuge/bg3'));
		bg3.camera = camHUD;
		add(bg3);
	}

	override function addPlayHUD():Void
	{
		super.addPlayHUD();

		healthBar.color = 0xff569096;
		healthBar.sideColor = 0xff76beeb;

		board = new FlxSprite();
		board.camera = camHUD;
		board.makeGraphic(1, 1);
		board.scale.set(FlxG.width, FlxG.height);
		board.updateHitbox();
		board.alpha = 0.0;
		add(board);
	}

	override function registerCalculator():Void
	{
		calculator.resetBPM(100.0);
		calculator.addBPMEvent(40800.0, 174.0);
		calculator.addBPMEvent(209075.86, 100.0);
	}

	override function registerRenderer():Void
	{
		super.registerRenderer();

		renderer.addSongSpeedEvent(44000.0, 2.4);

		var min:Float = 123558.62, max:Float = min + 2550.0;
		var t:Float = min, step:Float = 25.5;
		while (t < max)
		{
			t = Math.min(t + step, max);
			renderer.addSongSpeedEvent(t, FlxMath.remapToRange(t, min, max, 2.4, 1.4));
		}
		renderer.addSongSpeedEvent(157955.17, 1.2);

		var min:Float = 158903.44, max:Float = 165455.55;
		var t:Float = min, step:Float = (max - min) * 0.01;
		while (t < max)
		{
			t = Math.min(t + step, max);
			renderer.addSongSpeedEvent(t, FlxMath.remapToRange(t, min, max, 1.2, 2.4));
		}

		var min:Float = 204937.93, max:Float = min + 2550.0;
		var t:Float = min, step:Float = 25.5;
		while (t < max)
		{
			t = Math.min(t + step, max);
			renderer.addSongSpeedEvent(t, FlxMath.remapToRange(t, min, max, 2.4, 1.4));
		}
	}

	override function registerChart():Void
	{
		var data:{notes:Array<Array<Dynamic>>} = Json.parse(Paths.json('subterfuge/subterfuge'));
		for (note in data.notes)
		{
			var strumTime:Float = note[0];
			var strumIndex:Int = note[1];
			var sustainLength:Float = note[2];
			renderer.addNote(strumTime, strumIndex, sustainLength);
		}
	}

	override function updateTick():Void
	{
		super.updateTick();

		updateState();
		updateFlash();
		updateDrunk();
		updateMirror();
		updateTimedBeatZoom();
		updateDefaultCameraZoom();
	}

	public function updateState():Void
	{
		if (songPosition < 46317.24)
		{
			changeState(0);
		}
		if (songPosition >= 46317.24 && songPosition < 68386.2)
		{
			changeState(1);
		}
		else if (songPosition >= 68386.2 && songPosition < 123558.62)
		{
			changeState(2);
		}
		else if (songPosition >= 123558.62 && songPosition < 132010.0)
		{
			changeState(0);
		}
		else if (songPosition >= 132010.0 && songPosition < 160800.0)
		{
			changeState(1);
		}
		else if (songPosition >= 160800.0 && songPosition < 182877.7)
		{
			changeState(3);
		}
		else if (songPosition >= 182877.7 && songPosition < 208390.0)
		{
			changeState(2);
		}
		else if (songPosition >= 208390.0)
		{
			changeState(0);
		}
	}

	public function updateFlash():Void // w/Board Alpha
	{
		if (songPosition >= 68386.2 && songPosition < 68731.03)
		{
			board.alpha = 1.0 - MathUtil.clamp01((songPosition - 68386.2) / 344.83);
			board.color = FlxColor.WHITE;
		}
		else if (songPosition >= 123558.62 && songPosition < 123817.24)
		{
			board.alpha = 1.0 - MathUtil.clamp01((songPosition - 123558.62) / 258.62);
			board.color = FlxColor.WHITE;
		}
		else if (songPosition >= 160800.0 && songPosition < 160972.41)
		{
			board.alpha = 1.0 - MathUtil.clamp01((songPosition - 160800.0) / 172.41);
			board.color = FlxColor.WHITE;
		}
		else if (songPosition >= 182877.7 && songPosition < 182877.7 + 150)
		{
			board.alpha = 1.0 - MathUtil.clamp01((songPosition - 182877.7) / 150);
			board.color = FlxColor.WHITE;
		}
		else if (songPosition < 204940.0 || songPosition >= 209080.0)
		{
			board.alpha = 0.0;
		}
	}

	public function updateDrunk():Void
	{
		drunk.time = songPosition / 1000.0;

		if (songPosition >= 132010.0 && songPosition < 133210.0)
		{
			defaultCameraZoomValue = 1.35;
			drunk.intensity = MathUtil.clamp01((songPosition - 132000.0) / 1200.0) * 0.06;
		}
		else if (songPosition >= 133210.0 && songPosition < 156666.66)
		{
			defaultCameraZoomValue = 1.35;
			drunk.intensity = 0.06;
		}
		else if (songPosition >= 156666.66 && songPosition < 158733.33)
		{
			defaultCameraZoomValue = 1.15;
			drunk.intensity = MathUtil.clamp01(1.0 - ((songPosition - 156666.66) / 1200.0)) * 0.06;
		}
		else
		{
			drunk.intensity = 0.0;
		}
	}

	public function updateMirror():Void
	{
		if (songPosition < 223475.86)
		{
			mirror.alpha = 0.0;
		}
		else if (songPosition >= 223475.86 && songPosition < 224150.86)
		{
			var ratio:Float = (songPosition - 223475.86) / 675.0;
			var alpha:Float = FlxEase.bounceInOut(ratio) * 0.6;
			mirror.alpha = alpha;
		}
		else if (songPosition >= 224150.86 && songPosition < 224375.86)
		{
			var ratio:Float = (songPosition - 224150.86) / 225.0;
			var alpha:Float = (1.0 - FlxEase.quartOut(ratio)) * 0.6;
			mirror.alpha = alpha;
		}
		else if (songPosition >= 225875.86 && songPosition < 226175.86)
		{
			var ratio:Float = (songPosition - 225875.86) / 300.0;
			var alpha:Float = FlxEase.bounceInOut(ratio) * 0.4;
			mirror.alpha = alpha;
		}
		else if (songPosition >= 226175.86 && songPosition < 226325.86)
		{
			var ratio:Float = (songPosition - 226175.86) / 150.0;
			var alpha:Float = 0.2 + (1.0 - ratio) * 0.2;
			mirror.alpha = alpha;
		}
		else if (songPosition >= 226325.86 && songPosition < 226625.86)
		{
			mirror.alpha = 0.2;
		}
		else if (songPosition >= 226625.86 && songPosition < 227075.86)
		{
			var ratio:Float = (songPosition - 226625.86) / 450.0;
			var alpha:Float = 0.2 + FlxEase.elasticInOut(ratio) * 0.6;
			mirror.alpha = alpha;
		}
		else if (songPosition >= 227075.86 && songPosition < 227675.86)
		{
			mirror.alpha = 0.8;
		}
		else if (songPosition >= 227675.86 && songPosition < 228275.86)
		{
			var ratio:Float = (songPosition - 227675.86) / 600.0;
			var alpha:Float = 0.2 + (1.0 - FlxEase.bounceIn(ratio)) * 0.6;
			mirror.alpha = alpha;
		}
		else if (songPosition >= 228275.86 && songPosition < 228575.86)
		{
			var ratio:Float = (songPosition - 228275.86) / 300.0;
			var alpha:Float = 0.2 + ratio * 0.8;
			mirror.alpha = alpha;
		}
		else if (songPosition >= 228575.86)
		{
			mirror.alpha = 1.0;
		}
		renderer.opponentStrums.alpha = 1.0 - mirror.alpha;

		if (songPosition >= 209080.0 && player.animation.curAnim != null)
		{
			var animName:String = player.animation.curAnim.name;
			if (animName == 'left')
				animName = 'right';
			else if (animName == 'right')
				animName = 'left';
			if (opponent.animation.curAnim == null || opponent.animation.curAnim.name != animName)
				opponent.playAnim(animName, true);
			opponent.animation.curAnim.curFrame = player.animation.curAnim.curFrame;
		}
		mirror.animation.frameIndex = player.animation.frameIndex;
	}

	public function updateTimedBeatZoom():Void
	{
		for (i in beat...beatPosition.length)
		{
			if (songPosition >= beatPosition[i].strumTime)
			{
				beatZoomValue = beatPosition[i].eventValue;
				beat++;
			}
		}
	}

	public function updateDefaultCameraZoom():Void
	{
		if (songPosition < 46317.24)
		{
			defaultCameraZoomValue = 1.15;
		}
		if (songPosition >= 46317.24 && songPosition < 57351.72)
		{
			defaultCameraZoomValue = 1.45;
		}
		else if (songPosition >= 57351.72 && songPosition < 68386.2)
		{
			defaultCameraZoomValue = 1.15;
		}
		else if (songPosition >= 68386.2 && songPosition < 95972.41)
		{
			defaultCameraZoomValue = 0.8;
		}
		else if (songPosition >= 95972.41 && songPosition < 101489.66)
		{
			defaultCameraZoomValue = 1.15;
		}
		else if (songPosition >= 101489.86 && songPosition < 109765.52)
		{
			defaultCameraZoomValue = 0.8;
		}
		else if (songPosition >= 109765.52 && songPosition < 110455.17)
		{
			defaultCameraZoomValue = 0.95;
		}
		else if (songPosition >= 110455.17 && songPosition < 112524.14)
		{
			defaultCameraZoomValue = 1.1;
		}
		else if (songPosition >= 112524.14 && songPosition < 123558.62)
		{
			defaultCameraZoomValue = 0.8;
		}
		else if (songPosition >= 123558.62 && songPosition < 132010.0)
		{
			defaultCameraZoomValue = 1.15;
		}
		else if (songPosition >= 132010.0 && songPosition < 160800.0)
		{
			defaultCameraZoomValue = 1.15;
		}
		else if (songPosition >= 160800.0 && songPosition < 182877.7)
		{
			defaultCameraZoomValue = 0.8;
		}
		else if (songPosition >= 182877.7 && songPosition < 191144.82)
		{
			defaultCameraZoomValue = 0.8;
		}
		else if (songPosition >= 191144.82 && songPosition < 191834.48)
		{
			defaultCameraZoomValue = 0.95;
		}
		else if (songPosition >= 191834.48 && songPosition < 192524.14)
		{
			defaultCameraZoomValue = 1.1;
		}
		else if (songPosition >= 192524.14 && songPosition < 193386.2)
		{
			defaultCameraZoomValue = 0.8;
		}
		else if (songPosition >= 193386.2 && songPosition < 193903.45)
		{
			defaultCameraZoomValue = 0.95;
		}
		else if (songPosition >= 193903.45 && songPosition < 208390.0)
		{
			defaultCameraZoomValue = 0.8;
		}
		else if (songPosition >= 208390.0)
		{
			defaultCameraZoomValue = 1.15;
		}
	}

	override function updateCameraFollow(elapsed:Float):Void
	{
		if (songPosition < 68386.2)
		{
			changeCamFollow(STAGE1, true);
		}
		else if (songPosition >= 68386.2 && songPosition < 79420.67)
		{
			changeCamFollow(STAGE2_DEFAULT, true);
		}
		else if (songPosition >= 79420.67 && songPosition < 84937.93)
		{
			changeCamFollow(STAGE2_OPPONENT);
		}
		else if (songPosition >= 84937.93 && songPosition < 90455.17)
		{
			changeCamFollow(STAGE2_PLAYER);
		}
		else if (songPosition >= 90455.17 && songPosition < 101489.66)
		{
			changeCamFollow(STAGE2_DEFAULT);
		}
		else if (songPosition >= 101489.66 && songPosition < 105627.58)
		{
			changeCamFollow(STAGE2_OPPONENT);
		}
		else if (songPosition >= 105627.58 && songPosition < 112524.18)
		{
			changeCamFollow(STAGE2_PLAYER);
		}
		else if (songPosition >= 112524.18 && songPosition < 118041.38)
		{
			changeCamFollow(STAGE2_DEFAULT);
		}
		else if (songPosition >= 118041.38 && songPosition < 118731.03)
		{
			changeCamFollow(STAGE2_OPPONENT);
		}
		else if (songPosition >= 118731.03 && songPosition < 119420.67)
		{
			changeCamFollow(STAGE2_PLAYER);
		}
		else if (songPosition >= 119420.67 && songPosition < 120110.34)
		{
			changeCamFollow(STAGE2_OPPONENT);
		}
		else if (songPosition >= 120110.34 && songPosition < 120800.0)
		{
			changeCamFollow(STAGE2_PLAYER);
		}
		else if (songPosition >= 120800.0 && songPosition < 123558.62)
		{
			changeCamFollow(STAGE2_DEFAULT);
		}
		else if (songPosition >= 123558.62 && songPosition < 160800.0)
		{
			changeCamFollow(STAGE1, true);
		}
		else if (songPosition >= 160800.0 && songPosition < 162179.31)
		{
			changeCamFollow(STAGE2_OPPONENT, true);
		}
		else if (songPosition >= 162179.31 && songPosition < 163874.71)
		{
			changeCamFollow(STAGE2_DEFAULT);
		}
		else if (songPosition >= 163874.71 && songPosition < 164937.93)
		{
			changeCamFollow(STAGE2_PLAYER);
		}
		else if (songPosition >= 164937.93 && songPosition < 166317.24)
		{
			changeCamFollow(STAGE2_DEFAULT);
		}
		else if (songPosition >= 166317.24 && songPosition < 167696.55)
		{
			changeCamFollow(STAGE2_PLAYER);
		}
		else if (songPosition >= 167696.55 && songPosition < 169391.95)
		{
			changeCamFollow(STAGE2_DEFAULT);
		}
		else if (songPosition >= 169391.95 && songPosition < 170455.17)
		{
			changeCamFollow(STAGE2_OPPONENT);
		}
		else if (songPosition >= 170455.17 && songPosition < 171834.48)
		{
			changeCamFollow(STAGE2_DEFAULT);
		}
		else if (songPosition >= 171834.48 && songPosition < 178343.1)
		{
			changeCamFollow(STAGE2_OPPONENT);
		}
		else if (songPosition >= 178343.1 && songPosition < 182868.97)
		{
			changeCamFollow(STAGE2_PLAYER);
		}
		else if (songPosition >= 182868.97 && songPosition < 184248.28)
		{
			changeCamFollow(STAGE2_DEFAULT);
		}
		else if (songPosition >= 184248.28 && songPosition < 187006.9)
		{
			changeCamFollow(STAGE2_OPPONENT);
		}
		else if (songPosition >= 187006.9 && songPosition < 188386.2)
		{
			changeCamFollow(STAGE2_PLAYER);
		}
		else if (songPosition >= 188386.2 && songPosition < 191144.83)
		{
			changeCamFollow(STAGE2_DEFAULT);
		}
		else if (songPosition >= 191144.83 && songPosition < 193903.45)
		{
			changeCamFollow(STAGE2_PLAYER);
		}
		else if (songPosition >= 193903.45 && songPosition < 199420.67)
		{
			changeCamFollow(STAGE2_DEFAULT);
		}
		else if (songPosition >= 199420.67 && songPosition < 200110.34)
		{
			changeCamFollow(STAGE2_OPPONENT);
		}
		else if (songPosition >= 200110.34 && songPosition < 200800.0)
		{
			changeCamFollow(STAGE2_PLAYER);
		}
		else if (songPosition >= 200800.0 && songPosition < 201489.66)
		{
			changeCamFollow(STAGE2_OPPONENT);
		}
		else if (songPosition >= 201489.66 && songPosition < 202179.31)
		{
			changeCamFollow(STAGE2_PLAYER);
		}
		else if (songPosition >= 202179.31 && songPosition < 208390.0)
		{
			changeCamFollow(STAGE2_DEFAULT);
		}
		else if (songPosition >= 208390.0)
		{
			changeCamFollow(STAGE1);
		}

		var lerpVal:Float = 1.0 - MathUtil.clamp01(elapsed * (bpm / 60) * cameraFollowLerpScale);
		var camFollowX:Float = camFollowPos.x;
		var camFollowY:Float = camFollowPos.y;

		if (player.animation.curAnim != null && curState > 1)
		{
			var distanceX:Float = Math.abs(1340 - camFollow.x);
			var distanceY:Float = Math.abs(500 - camFollow.y);
			var offsetX:Float = 0.0;
			var offsetY:Float = 0.0;
			switch (player.animation.curAnim.name)
			{
				case 'left':
					offsetX = -50;
				case 'down':
					offsetY = 50;
				case 'up':
					offsetY = -50;
				case 'right':
					offsetX = 50;
			}
			offsetX *= (1.0 - distanceX / 830) / camGame.zoom;
			offsetY *= (1.0 - distanceY / 100) / camGame.zoom;
			camFollowX += offsetX;
			camFollowY += offsetY;
		}

		camFollow.x = FlxMath.lerp(camFollowX, camFollow.x, lerpVal);
		camFollow.y = FlxMath.lerp(camFollowY, camFollow.y, lerpVal);
	}

	public function distanceCamera():Float
	{
		var dx:Float = (player.x + player.width * 0.5) - camFollow.x;
		var dy:Float = (player.y + player.height * 0.5) - camFollow.y;
		return FlxMath.vectorLength(dx, dy);
	}

	public function changeCamFollow(target:CameraFollow, fix:Bool = false):Void
	{
		switch (target)
		{
			case STAGE1:
				setCamFollow(960, 540, fix);
			case STAGE2_DEFAULT:
				setCamFollow(860, 500, fix);
			case STAGE2_OPPONENT:
				setCamFollow(510, 400, fix);
			case STAGE2_PLAYER:
				setCamFollow(1340, 500, fix);
		}
	}

	override function updateCameraZoom(elapsed:Float):Void
	{
		super.updateCameraZoom(elapsed);
		updateCameraFx();
	}

	public function updateCameraFx():Void
	{
		if (songPosition >= 204940.0 && songPosition < 206320.0)
		{
			var position:Float = (songPosition - 204940.0);
			var ratio:Float = MathUtil.clamp01(position / 1680.0);
			camGame.zoom = 0.8 + FlxEase.backIn(ratio) * 0.6;
			camHUD.zoom = 1.0 + FlxEase.backIn(ratio) * 0.3;

			var alpha:Float = FlxEase.quintIn(MathUtil.clamp01(position / 1380.0));
			board.alpha = alpha;
			board.color = FlxColor.BLACK;
		}
		else if (songPosition >= 206320.0 && songPosition < 208390.0)
		{
			board.alpha = 1.0;
			board.color = FlxColor.BLACK;
		}
		else if (songPosition >= 208390.0 && songPosition < 209080.0)
		{
			if (songPosition < 208590.0 && absolutePressed[2] > -1)
			{
				keyUp(2);
			}

			var ratio:Float = (songPosition - 208390.0) / 690.0;
			var alpha:Float = 1.0 - ratio;
			board.alpha = alpha;
			board.color = FlxColor.BLACK;
		}
	}

	override function stepHit():Void
	{
		super.stepHit();
		updateBeatZoom();
		updateCameraZoomLerpScale();
	}

	public function updateBeatZoom():Void
	{
		if (curStep >= 16 && curStep < 272)
		{
			if (curStep % 16 == 0 || curStep % 16 == 6)
			{
				beatZoomValue = 0.05;
			}
			if (curStep > 144 && curStep % 16 == 8)
			{
				beatZoomValue = 0.07;
			}
		}
		else if (curStep == 272)
		{
			beatZoomValue = 0.08;
		}
		else if (curStep >= 306 && curStep <= 336)
		{
			var addZoom:Float = switch (curStep)
			{
				case 306 | 308 | 310 | 311 | 312 | 313 | 314 | 316 | 317 | 318 | 319 /* | 320 */ | 322 | 324 | 326 | 327 | 328 | 329 | 330:
					0.005 + 0.05 * ((curStep - 306) / 30.0);
				case 320:
					0.0295;
				case 332 | 333 | 334 | 335:
					0.095;
				case 336:
					0.125;
				default:
					beatZoomValue;
			}
			beatZoomValue = addZoom;
		}
		else if (curStep > 336 && curStep < 384)
		{
			var addZoom:Float = switch (curStep % 16)
			{
				case 0 | 10 | 12 | 14:
					0.06;
				default:
					beatZoomValue;
			}
			beatZoomValue = addZoom;
		}
		else if (curStep >= 384 && curStep < 400)
		{
			var addZoom:Float = switch (curStep % 16)
			{
				case 0 | 4 | 6 | 10 | 12 | 14:
					0.06;
				default:
					beatZoomValue;
			}
			beatZoomValue = addZoom;
		}
		else if (curStep >= 400 && curStep < 448)
		{
			var addZoom:Float = switch (curStep % 16)
			{
				case 0 | 10 | 12 | 14:
					0.06;
				default:
					beatZoomValue;
			}
			beatZoomValue = addZoom;
		}
		else if (curStep >= 448 && curStep < 464)
		{
			var addZoom:Float = switch (curStep % 16)
			{
				case 0 | 4 | 6 | 8 | 12 | 14: // 12.5
					0.06;
				default:
					beatZoomValue;
			}
			beatZoomValue = addZoom;
		}
		else if (curStep >= 464 && curStep < 560 && curStep % 4 == 0)
		{
			beatZoomValue = 0.06;
		}
		else if (curStep >= 560 && curStep < 576 && curStep % 2 == 0)
		{
			beatZoomValue = 0.075;
		}
		else if (curStep >= 576 && curStep < 585)
		{
			var addZoom:Float = switch (curStep)
			{
				case 576 | 580: 0.075;
				case 577 | 581: 0.09;
				case 578 | 582: 0.105;
				case 584: 0.125;
				default: beatZoomValue;
			}
			beatZoomValue = addZoom;
		}
		else if (curStep >= 592 && curStep < 720)
		{
			var addZoom:Float = beatZoomValue;
			if (curStep % 4 == 0 && curStep != 616 && curStep != 648)
			{
				addZoom = 0.06;
			}
			switch (curStep)
			{
				case 614 | 618 | 622 | 646 | 650 | 652 | 654 | 710 | 714 | 715 | 718: // 652.5
					addZoom = 0.06;
			}
			beatZoomValue = addZoom;
		}
		else if (curStep >= 724 && curStep <= 846)
		{
			var addZoom:Float = beatZoomValue;
			if (curStep % 4 == 0 && curStep != 744 && curStep != 776 && curStep != 808)
			{
				addZoom = 0.06;
			}
			switch (curStep)
			{
				case 724:
					addZoom = 0.075;
				case 742 | 746 | 750 | 774 | 778 | 782 | 806 | 810 | 814 | 838 | 842 | 843 | 846: // 780.5
					addZoom = 0.06;
			}
			beatZoomValue = addZoom;
		}
		else if (curStep >= 848 && curStep < 912 && curStep % 4 == 0)
		{
			beatZoomValue = 0.06;
		}
		else if (curStep >= 916 && curStep < 967)
		{
			var addZoom:Float = beatZoomValue;
			if (curStep % 4 == 0 && curStep != 936)
			{
				addZoom = 0.045;
			}
			switch (curStep)
			{
				case 916:
					addZoom = 0.06;
				case 934 | 938 | 942 | 966:
					addZoom = 0.045;
			}
			beatZoomValue = addZoom;
		}
		else if (curStep >= 976 && curStep < 1108)
		{
			var addZoom:Float = beatZoomValue;
			switch (curStep)
			{
				case 976 | 984 | 992 | 996 | 1000 | 1008 | 1016 | 1032 | 1040 | 1048 | 1064 | 1072 | 1080:
					addZoom = 0.075;
				case 980 | 982 | 988 | 990 | 1002 | 1004 | 1006 | 1012 | 1014 | 1020 | 1022 | 1024 | 1028 | 1036 | 1038 | 1044 | 1046 | 1050 | 1052 | 1054 |
					1056 | 1060 | 1066 | 1068 | 1070 | 1076 | 1078 | 1082 | 1084 | 1086 | 1088 | 1092 | 1094 | 1096 | 1098 | 1100 | 1102:
					addZoom = 0.06;
			}
			beatZoomValue = addZoom;
		}
		else if (curStep >= 1108 && curStep <= 1200)
		{
			var addZoom:Float = beatZoomValue;
			if (curStep % 4 == 0 && curStep != 1128 && curStep != 1160 && curStep != 1192)
			{
				addZoom = 0.06;
			}
			switch (curStep)
			{
				case 1126 | 1130 | 1134 | 1158 | 1162 | 1166 | 1190 | 1194 | 1198:
					addZoom = 0.06;
			}
			beatZoomValue = addZoom;
		}
		else if (curStep >= 1204 && curStep <= 1220)
		{
			var addZoom:Float = beatZoomValue;
			if (curStep % 4 == 0)
			{
				addZoom = 0.095;
			}
			else if (curStep <= 1214 && curStep % 2 == 0)
			{
				addZoom = 0.075;
			}
			beatZoomValue = addZoom;
		}
		else if (curStep >= 1224 && curStep <= 1228)
		{
			var addZoom:Float = beatZoomValue;
			switch (curStep)
			{
				case 1224 | 1226:
					addZoom = 0.06;
				case 1227:
					addZoom = 0.075;
				case 1228:
					addZoom = 0.09;
			}
			beatZoomValue = addZoom;
		}
		else if (curStep == 1232)
		{
			beatZoomValue = 0.115;
		}
		else if (curStep >= 1264 && curStep <= 1328 && curStep != 1312 && curStep % 16 == 0)
		{
			beatZoomValue = 0.02;
		}
		else if (curStep == 1344)
		{
			beatZoomValue = 0.03;
		}
		else if (curStep >= 1640 && curStep <= 1664)
		{
			var addZoom:Float = switch (curStep)
			{
				case 1640 | 1641 | 1642 | 1644 | 1645 | 1646 | 1650 | 1654 | 1655 | 1656 | 1658:
					0.005 + 0.05 * ((curStep - 1640) / 24.0);
				case 1648 | 1652:
					0.005 + 0.1 * ((curStep - 1640) / 24.0);
				case 1660 | 1661 | 1662 | 1663:
					0.105;
				case 1664:
					0.125;
				default:
					beatZoomValue;
			}
			beatZoomValue = addZoom;
		}
		else if (curStep > 1664 && curStep <= 1776)
		{
			var addZoom:Float = beatZoomValue;
			if (curStep % 16 == 0 || curStep % 16 == 14 || curStep == 1724)
			{
				addZoom = 0.075;
			}
			beatZoomValue = addZoom;
		}
		else if (curStep >= 1784 && curStep <= 1790)
		{
			var addZoom:Float = switch (curStep)
			{
				case 1784 | 1788 | 1790:
					0.075;
				default:
					beatZoomValue;
			}
			beatZoomValue = addZoom;
		}
		else if (curStep >= 1792 && curStep < 1888 && curStep % 4 == 0)
		{
			beatZoomValue = 0.06;
		}
		else if (curStep >= 1888 && curStep < 1904 && curStep % 2 == 0)
		{
			beatZoomValue = 0.075;
		}
		else if (curStep >= 1904 && curStep <= 1912)
		{
			var addZoom:Float = switch (curStep)
			{
				case 1904 | 1908: 0.075;
				case 1905 | 1909: 0.09;
				case 1906 | 1910: 0.105;
				case 1912: 0.125;
				default: beatZoomValue;
			}
			beatZoomValue = addZoom;
		}
		else if (curStep >= 1920 && curStep < 2144)
		{
			var addZoom:Float = beatZoomValue;
			if (curStep % 4 == 0 && curStep != 1944 && curStep != 2008 && curStep != 2048 && curStep != 2072 && curStep != 2104 && curStep != 2136)
			{
				addZoom = 0.06;
			}
			switch (curStep)
			{
				case 1942 | 1946 | 1950 | 1974 | 1978 | 1982 | 2006 | 2010 | 2014 | 2038 | 2042 | 2043 | 2046 | 2070 | 2074 | 2078 | 2102 | 2106 | 2110 |
					2134 | 2138 | 2142:
					addZoom = 0.06;
			}
			beatZoomValue = addZoom;
		}
		else if (curStep >= 2148 && curStep < 2170)
		{
			var addZoom:Float = beatZoomValue;
			if (curStep % 4 == 0)
			{
				addZoom = 0.095;
			}
			else if (curStep <= 2170 && curStep % 2 == 0)
			{
				addZoom = 0.075;
			}
			beatZoomValue = addZoom;
		}
		else if (curStep >= 2170 && curStep <= 2172)
		{
			var addZoom:Float = beatZoomValue;
			switch (curStep)
			{
				case 2170:
					addZoom = 0.06;
				case 2171:
					addZoom = 0.075;
				case 2172:
					addZoom = 0.09;
			}
			beatZoomValue = addZoom;
		}
		else if (curStep >= 2230 && curStep <= 2278)
		{
			if (curStep % 16 == 0 || curStep % 16 == 6)
			{
				beatZoomValue = 0.04;
			}
		}
	}

	public function updateCameraZoomLerpScale():Void
	{
		if (curStep >= 1204 && curStep <= 1216)
		{
			cameraZoomLerpScale = 4.0;
		}
		if ((curStep >= 332 && curStep < 1232) || (curStep >= 1640 && curStep <= 1664) || (curStep >= 1792 && curStep < 2176))
		{
			cameraZoomLerpScale = 2.0;
		}
		else
		{
			cameraZoomLerpScale = 1.0;
		}
	}

	public function changeState(i:Int):Void
	{
		if (curState != i)
		{
			curState = i;

			switch (i)
			{
				case 0:
					opponent.setPosition(484, 353);
					opponent.changeCharacter('lookALike1');
					player.changeCharacter('boyfriendLittle');
				case 1:
					opponent.setPosition(484, 353);
					opponent.changeCharacter('lookALike2');
					player.changeCharacter('boyfriendLittle');
				case 2 | 3:
					opponent.setPosition(-252, -84);
					opponent.changeCharacter('lookALikeReal');
					player.changeCharacter('boyfriend');
			}

			var realPhase:Bool = (curState > 1);

			bg.visible = !realPhase;
			bg2.visible = !realPhase;
			bg3.visible = (curState != 2);
			bg4.visible = realPhase;
		}
	}

	override function getStartOpponentCharacter():String
	{
		return 'lookALike1';
	}

	override function getStartPlayerCharacter():String
	{
		return 'boyfriendLittle';
	}
}

enum CameraFollow
{
	STAGE1;
	STAGE2_DEFAULT;
	STAGE2_OPPONENT;
	STAGE2_PLAYER;
}
