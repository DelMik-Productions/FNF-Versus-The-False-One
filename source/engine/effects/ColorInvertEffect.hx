package engine.effects;

import flixel.system.FlxAssets.FlxShader;

class ColorInvertEffect extends ShaderEffect<ColorInvertShader>
{
	public var ratio(get, set):Float;

	public function new()
	{
		super(new ColorInvertShader());
	}

	private function get_ratio():Float
	{
		return shader.uRatio.value[0];
	}

	private function set_ratio(value:Float):Float
	{
		return shader.uRatio.value[0] = value;
	}
}

@:noCompletion
class ColorInvertShader extends FlxShader
{
	@:glFragmentSource('
    #pragma header

    uniform float uRatio;

    void main(void)
    {
        vec4 color = flixel_texture2D(bitmap, openfl_TextureCoordv);
        color.rgb = mix(color.rgb, 1.0 - color.rgb, uRatio) * color.a;
        gl_FragColor = color;
    }
    ')
	public function new()
	{
		super();
		uRatio.value = [0.0];
	}
}
