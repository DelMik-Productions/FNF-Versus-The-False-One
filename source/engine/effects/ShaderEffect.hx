package engine.effects;

import flixel.FlxBasic;
import flixel.system.FlxAssets.FlxShader;

@:generic
class ShaderEffect<T:FlxShader> extends BaseShaderEffect
{
	public final shader:T;

	public function new(Shader:T)
	{
		super(Shader);
		shader = Shader;
	}
}

class BaseShaderEffect extends FlxBasic
{
	private final _shader:FlxShader;
	private final _class:Class<FlxShader>;

	public function new(Shader:FlxShader)
	{
		super();
		_shader = Shader;
		_class = Type.getClass(Shader);
	}
}
