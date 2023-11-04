package engine.effects;

import flixel.system.FlxAssets.FlxShader;

class DrunkEffect extends ShaderEffect<DrunkShader>
{
	public var time(get, set):Float;
	public var intensity(get, set):Float;

	public function new()
	{
		super(new DrunkShader());
	}

	private function get_time():Float
	{
		return shader.uTime.value[0];
	}

	private function set_time(value:Float):Float
	{
		return shader.uTime.value[0] = value;
	}

	private function get_intensity():Float
	{
		return shader.uIntensity.value[0];
	}

	private function set_intensity(value:Float):Float
	{
		return shader.uIntensity.value[0] = value;
	}
}

/**
 * @see https://www.shadertoy.com/view/7ltBWl
 */
@:noCompletion
class DrunkShader extends FlxShader
{
	@:glFragmentSource('
    #pragma header

    uniform float uTime;
    uniform float uIntensity;

    void main(void)
    {
        float intensity = sin(uTime * uIntensity * 0.2) * 0.05 + uIntensity;
    	float vigintensity = 8.0 - 6.4 * intensity;

        vec2 uv = openfl_TextureCoordv;
        float x = uv.x * 6.0 + uTime;
        float y = uv.y * 6.0 + uTime;

        uv.x += cos(x + y) * intensity * 0.03 * cos(y);
        uv.y += sin(x + y) * intensity * 0.03 * sin(y);

    	vec4 colorBase = flixel_texture2D(bitmap, vec2(uv.x + sin(uTime * 1.2 + 1.575) * intensity * 0.02, uv.y + sin(uTime * 0.8 + 1.575) * intensity * 0.01));
    	vec4 color1 = flixel_texture2D(bitmap, vec2(uv.x + sin(uTime * 1.2) * intensity * 0.2, uv.y + sin(uTime * 0.8) * intensity * 0.1));
    	vec4 color2 = flixel_texture2D(bitmap, vec2(uv.x + sin(uTime * 1.2 + 3.15) * intensity * 0.2, uv.y + sin(uTime * 0.8 + 3.15) * intensity * 0.1));
    	vec4 color3 = flixel_texture2D(bitmap, vec2(uv.x + sin(uTime * 1.5) * intensity * 0.2, uv.y + sin(uTime * 1.1) * intensity * 0.1));
    	vec4 color4 = flixel_texture2D(bitmap, vec2(uv.x + sin(uTime * 1.5 + 3.15) * intensity * 0.2, uv.y + sin(uTime * 1.1 + 3.15) * intensity * 0.1));
    	vec4 color5 = flixel_texture2D(bitmap, vec2(uv.x + sin(uTime * 1.5 + 1.575) * intensity * 0.02, uv.y + sin(uTime * 1.1 + 1.575) * intensity * 0.01));

        vec4 colorMix1 = mix(colorBase, color1, 0.5);
        vec4 colorMix2 = mix(colorMix1, color2, 1.0 / 3.0);
        vec4 colorMix3 = mix(colorMix2, color3, 0.25);
        vec4 colorMix4 = mix(colorMix3, color4, 1.0 / 5.0);
        vec4 colorMix5 = mix(colorMix4, color5, 1.0 / 6.0);

        float vigdistance  = distance(vec2(0.5, 0.5), uv) * 1.414213;
    	float vignette = clamp((vigintensity - vigdistance) / (vigintensity + intensity * 1.0), 0.0, 1.0);
    	colorMix5 *= vignette;

        gl_FragColor = colorMix5;
    }
    ')
	public function new()
	{
		super();
		uTime.value = [0.0];
		uIntensity.value = [0.06];
	}
}
