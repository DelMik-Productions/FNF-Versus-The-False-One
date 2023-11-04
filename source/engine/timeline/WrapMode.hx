package engine.timeline;

enum WrapMode
{
	CONSTANT;
	LOOPING;
	PINGPONG;
	LOOPED(from:Float, to:Float);
}
