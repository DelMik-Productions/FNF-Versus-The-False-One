package engine.effects;

import flixel.system.FlxAssets.FlxShader;

class BlurEffect extends ShaderEffect<BlurShader>
{
	public var blurSize(get, set):Float;

	public function new()
	{
		super(new BlurShader());
	}

	private function get_blurSize():Float
	{
		return shader.uSize.value[0];
	}

	private function set_blurSize(value:Float):Float
	{
		return shader.uSize.value[0] = value;
	}
}

@:noCompletion
class BlurShader extends FlxShader
{
	@:glFragmentSource('
    #pragma header

    uniform float uDirections;
    uniform float uQuality;
    uniform float uSize;

    void main()
    {
        float Pi = 6.28318530718;
        vec2 Radius = uSize / openfl_TextureSize;

        vec2 uv = openfl_TextureCoordv;
        vec4 Color = flixel_texture2D(bitmap, uv);

        for (float d = 0.0; d < Pi; d += Pi / uDirections)
        {
            for (float i = 1.0 / uQuality; i <= 1.0; i += 1.0 / uQuality)
            {
                Color += flixel_texture2D(bitmap, uv + vec2(cos(d), sin(d)) * Radius * i);		
            }
        }

        Color /= uQuality * uDirections - 15.0;
        gl_FragColor = Color;
    }
    ')
	public function new()
	{
		super();
		uDirections.value = [16];
		uQuality.value = [4];
		uSize.value = [0];
	}
}
