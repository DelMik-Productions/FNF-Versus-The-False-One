package engine.effects;

import engine.utils.CoolUtil;
import flixel.system.FlxAssets.FlxShader;
import flixel.util.FlxColor;

class ColorMaskEffect extends ShaderEffect<ColorMaskShader>
{
	public var redChannel(get, set):FlxColor;
	public var greenChannel(get, set):FlxColor;
	public var blueChannel(get, set):FlxColor;

	public function new(RedMask:FlxColor = FlxColor.RED, GreenMask:FlxColor = FlxColor.GREEN, BlueMask:FlxColor = FlxColor.BLUE)
	{
		super(new ColorMaskShader(RedMask, GreenMask, BlueMask));
	}

	private function get_redChannel():FlxColor
	{
		return CoolUtil.colorFromArray(shader.uRedChannel.value);
	}

	private function set_redChannel(value:FlxColor):FlxColor
	{
		shader.uRedChannel.value = CoolUtil.arrayFromColor(value);
		return value;
	}

	private function get_greenChannel():FlxColor
	{
		return CoolUtil.colorFromArray(shader.uGreenChannel.value);
	}

	private function set_greenChannel(value:FlxColor):FlxColor
	{
		shader.uGreenChannel.value = CoolUtil.arrayFromColor(value);
		return value;
	}

	private function get_blueChannel():FlxColor
	{
		return CoolUtil.colorFromArray(shader.uBlueChannel.value);
	}

	private function set_blueChannel(value:FlxColor):FlxColor
	{
		shader.uBlueChannel.value = CoolUtil.arrayFromColor(value);
		return value;
	}
}

@:noCompletion
class ColorMaskShader extends FlxShader
{
	@:glFragmentSource('
    #pragma header

    uniform vec3 uRedChannel;
    uniform vec3 uGreenChannel;
    uniform vec3 uBlueChannel;

    void main(void)
    {
		vec4 color = flixel_texture2D(bitmap, openfl_TextureCoordv);

        vec3 redMask = color.r * uRedChannel;
        vec3 greenMask = color.g * uGreenChannel;
        vec3 blueMask = color.b * uBlueChannel;
        vec3 maskedColor = redMask + greenMask + blueMask;

		color.rgb = min(maskedColor, vec3(1.0));
        gl_FragColor = color;
    }
    ')
	public function new(RedMask:FlxColor = FlxColor.RED, GreenMask:FlxColor = FlxColor.GREEN, BlueMask:FlxColor = FlxColor.BLUE)
	{
		super();
		uRedChannel.value = CoolUtil.arrayFromColor(RedMask);
		uGreenChannel.value = CoolUtil.arrayFromColor(GreenMask);
		uBlueChannel.value = CoolUtil.arrayFromColor(BlueMask);
	}
}
