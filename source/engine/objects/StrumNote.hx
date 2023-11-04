package engine.objects;

class StrumNote extends Note
{
	public function new(index:Int)
	{
		super(index);

		setGraphicSize(Note.swagWidth, Note.swagHeight);
		updateHitbox();
		centerOffsets();
	}

	override function syncAnimations():Void
	{
		addAnim('arrow');
		addAnim('confirm');
		addAnim('pressed');
	}

	override function syncIndexAnimation():Void
	{
		playAnim('arrow', true);
	}

	override function playAnim(name:String, force:Bool = false):Void
	{
		super.playAnim(name, force);
		if (name == 'arrow')
		{
			effect.redChannel = 0xffff0000;
			effect.greenChannel = 0xff00ff00;
			effect.blueChannel = 0xff0000ff;
		}
		else
		{
			syncIndexColor();
		}
	}
}
