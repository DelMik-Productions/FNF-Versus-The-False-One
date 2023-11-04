package engine.effects;

import flixel.system.FlxAssets.FlxShader;

class AlphaEffect extends ShaderEffect<AlphaShader>
{
	public var alpha(get, set):Float;

	public function new()
	{
		super(new AlphaShader());
	}

	private function get_alpha():Float
	{
		return shader.uAlpha.value[0];
	}

	private function set_alpha(value:Float):Float
	{
		return shader.uAlpha.value[0] = value;
	}
}

@:noCompletion
class AlphaShader extends FlxShader
{
	@:glFragmentSource('
    #pragma header

    uniform float uAlpha;

    void main(void)
    {
        vec4 color = flixel_texture2D(bitmap, openfl_TextureCoordv);
        gl_FragColor = color * uAlpha;
    }
    ')
	public function new()
	{
		super();
		uAlpha.value = [1.0];
	}
}
