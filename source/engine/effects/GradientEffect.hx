package engine.effects;

import engine.utils.CoolUtil;
import flixel.system.FlxAssets.FlxShader;
import flixel.util.FlxColor;

class GradientEffect extends ShaderEffect<GradientShader>
{
	public var color(get, set):FlxColor;

	public var offset(get, set):Float;
	public var height(get, set):Float;
	public var top(get, set):Float;
	public var bottom(get, set):Float;

	public function new(Color:FlxColor = FlxColor.BLACK, Height:Float = 0, Top:Float = 0, ?Bottom:Float)
	{
		super(new GradientShader(Color, Height, Top, Bottom));
	}

	private function get_color():FlxColor
	{
		return CoolUtil.colorFromArray(shader.uColor.value);
	}

	private function set_color(value:FlxColor):FlxColor
	{
		shader.uColor.value = CoolUtil.arrayFromColor(value);
		return value;
	}

	private function get_offset():Float
	{
		return shader.uOffset.value[0];
	}

	private function set_offset(value:Float):Float
	{
		return shader.uOffset.value[0] = value;
	}

	private function get_height():Float
	{
		return shader.uHeight.value[0];
	}

	private function set_height(value:Float):Float
	{
		return shader.uHeight.value[0] = value;
	}

	private function get_top():Float
	{
		return shader.uTop.value[0];
	}

	private function set_top(value:Float):Float
	{
		return shader.uTop.value[0] = value;
	}

	private function get_bottom():Float
	{
		return shader.uBottom.value[0];
	}

	private function set_bottom(value:Float):Float
	{
		return shader.uBottom.value[0] = value;
	}
}

@:noCompletion
class GradientShader extends FlxShader
{
	@:glFragmentSource('
    #pragma header

    uniform vec4 uColor;

    uniform float uOffset;
    uniform float uHeight;
    uniform float uTop;
    uniform float uBottom;

    void main()
    {
        float y = openfl_TextureCoordv.y * openfl_TextureSize.y - uOffset;
        vec4 color = flixel_texture2D(bitmap, openfl_TextureCoordv);
        float alpha = 0.0;

        if (y >= 0.0 && y <= uTop)
            alpha = y / uTop;
        y -= uTop;

        if (y > 0.0 && y < uHeight)
            alpha = 1.0;
        y -= uHeight;

        if (y >= 0.0 && y <= uBottom)
            alpha = 1.0 - (y / uBottom);

        gl_FragColor = mix(color, uColor, alpha);
    }
    ')
	public function new(Color:FlxColor = FlxColor.BLACK, Height:Float = 0, Top:Float = 0, ?Bottom:Float)
	{
		super();
		uColor.value = CoolUtil.arrayFromColor(Color);
		uOffset.value = [0];
		uHeight.value = [Height];
		uTop.value = [Top];
		uBottom.value = [Bottom ?? Top];
	}
}
