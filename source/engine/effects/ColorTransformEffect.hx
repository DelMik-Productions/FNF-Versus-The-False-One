package engine.effects;

import flixel.system.FlxAssets.FlxShader;

class ColorTransformEffect extends ShaderEffect<ColorTransformShader>
{
	public var hue(get, set):Float;
	public var saturation(get, set):Float;
	public var brightness(get, set):Float;

	public function new(Hue:Float = 0, Saturation:Float = 0, Brightness:Float = 0)
	{
		super(new ColorTransformShader(Hue, Saturation, Brightness));
	}

	private function get_hue():Float
	{
		return shader.uColorTransform.value[0];
	}

	private function set_hue(value:Float):Float
	{
		return shader.uColorTransform.value[0] = hue;
	}

	private function get_saturation():Float
	{
		return shader.uColorTransform.value[1];
	}

	private function set_saturation(value:Float):Float
	{
		return shader.uColorTransform.value[1] = value;
	}

	private function get_brightness():Float
	{
		return shader.uColorTransform.value[2];
	}

	private function set_brightness(value:Float):Float
	{
		return shader.uColorTransform.value[2] = value;
	}
}

@:noCompletion
class ColorTransformShader extends FlxShader
{
	@:glFragmentSource('
    #pragma header

	uniform vec3 uColorTransform;

	vec3 rgb2hsv(vec3 c)
	{
		vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
		vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
		vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

		float d = q.x - min(q.w, q.y);
		float e = 1.0e - 10;
		return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
	}

	vec3 hsv2rgb(vec3 c)
	{
		vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
		vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
		return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
	}

	void main(void)
	{
		vec4 color = flixel_texture2D(bitmap, openfl_TextureCoordv);
		vec4 tf = vec4(rgb2hsv(vec3(color[0], color[1], color[2])), color[3]);

		tf[0] = tf[0] + colorTransform[0];
		tf[1] = tf[1] + colorTransform[1];
		tf[2] = tf[2] * (1.0 + colorTransform[2]);

		color = vec4(hsv2rgb(vec3(tf[0], tf[1], tf[2])), tf[3]);

		gl_FragColor = color;
	}')
	public function new(Hue:Float = 0, Saturation:Float = 0, Brightness:Float = 0)
	{
		super();
		uColorTransform.value = [Hue, Saturation, Brightness];
	}
}
