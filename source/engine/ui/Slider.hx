package engine.ui;

import engine.utils.CoolUtil;
import engine.utils.MathUtil;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.tile.FlxDrawTrianglesItem.DrawData;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets.FlxShader;
import flixel.util.FlxColor;
import openfl.geom.ColorTransform;

class Slider extends FlxSprite
{
	public var parentRef:Dynamic;
	public var field:String;

	public var min:Float;
	public var max:Float;
	public var leftToRight:Bool = true;

	public var borderSize:Float = 2;
	public var borderColor:FlxColor = FlxColor.WHITE;

	public var sideColor:FlxColor = FlxColor.WHITE;

	private var vertices:DrawData<Float> = new DrawData();
	private var indices:DrawData<Int> = new DrawData();
	private var uvtData:DrawData<Float> = new DrawData();
	private var colors:DrawData<Int> = new DrawData();

	public function new(width:Float, height:Float, parentRef:Dynamic, field:String, min:Float = 0.0, max:Float = 1.0)
	{
		super();

		this.width = width;
		this.height = height;

		this.parentRef = parentRef;
		this.field = field;

		this.min = min;
		this.max = max;

		colorTransform = new ColorTransform();
		shader = new FlxShader();
	}

	override function draw():Void
	{
		for (camera in cameras)
		{
			if (!camera.visible || !camera.exists)
				continue;

			drawSlider(camera);
		}
	}

	private function drawSlider(camera:FlxCamera):Void
	{
		getScreenPosition(_point, camera).subtractPoint(offset);
		drawRectangle(camera, 0, 0, width, height, borderColor);

		var barWidth:Float = (width - borderSize * 2.0);
		var barHeight:Float = (height - borderSize * 2.0);
		var ratio:Float = getRatio();
		if (!leftToRight)
			ratio = 1.0 - ratio;

		drawRectangle(camera, borderSize, borderSize, barWidth * ratio, barHeight, color);
		drawRectangle(camera, borderSize + barWidth * ratio, borderSize, barWidth * (1.0 - ratio), barHeight, sideColor);
	}

	private function drawRectangle(camera:FlxCamera, x:Float, y:Float, width:Float, height:Float, color:FlxColor):Void
	{
		vertices[0] = x;
		vertices[1] = y;
		vertices[2] = x + width;
		vertices[3] = y;
		vertices[4] = x + width;
		vertices[5] = y + height;
		vertices[6] = x;
		vertices[7] = y + height;

		uvtData[0] = 0.0;
		uvtData[1] = 0.0;
		uvtData[2] = 1.0;
		uvtData[3] = 0.0;
		uvtData[4] = 1.0;
		uvtData[5] = 1.0;
		uvtData[6] = 0.0;
		uvtData[7] = 1.0;

		indices[0] = 0;
		indices[1] = 1;
		indices[2] = 2;
		indices[3] = 2;
		indices[4] = 3;
		indices[5] = 0;

		colorTransform.color = color;
		camera.drawTriangles(CoolUtil.makeGraphic(), vertices, indices, uvtData, colors, _point, blend, false, antialiasing, colorTransform, shader);
	}

	public function getRatio():Float
	{
		return MathUtil.inverseLerp(min, max, MathUtil.clamp(Reflect.getProperty(parentRef, field), min, max));
	}

	override function overlapsPoint(point:FlxPoint, inScreenSpace = false, ?camera:FlxCamera):Bool
	{
		if (!inScreenSpace)
		{
			return (point.x >= x) && (point.x < x + width) && (point.y >= y) && (point.y < y + height);
		}

		if (camera == null)
		{
			camera = FlxG.camera;
		}
		var xPos:Float = point.x - camera.scroll.x;
		var yPos:Float = point.y - camera.scroll.y;
		getScreenPosition(_point, camera);
		point.putWeak();
		return (xPos >= _point.x) && (xPos < _point.x + width) && (yPos >= _point.y) && (yPos < _point.y + height);
	}
}
