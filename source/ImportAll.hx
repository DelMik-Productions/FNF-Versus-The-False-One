package;

#if debug
import ImportAll;
import Main;
import engine.effects.BlurEffect;
import engine.effects.ColorInvertEffect;
import engine.effects.ColorMaskEffect;
import engine.effects.ColorTransformEffect;
import engine.effects.DrunkEffect;
import engine.effects.GradientEffect;
import engine.effects.ShaderEffect;
import engine.objects.Character;
import engine.objects.Note;
import engine.objects.NoteSplash;
import engine.objects.Receptor;
import engine.objects.StrumNote;
import engine.songs.NoteRenderer;
import engine.states.MusicBeatState;
import engine.states.PlayState;
import engine.states.TransitionState;
import engine.substates.MusicBeatSubState;
import engine.substates.PauseSubState;
import engine.substates.transition.FadeTransition;
import engine.substates.transition.Transition;
import engine.timeline.BezierEasing;
import engine.timeline.FieldTimeline;
import engine.timeline.FloatTimeline;
import engine.timeline.Keyframe;
import engine.timeline.StringTimeline;
import engine.timeline.Timeline;
import engine.timeline.WrapMode;
import engine.ui.Dragger;
import engine.ui.Slider;
import engine.utils.ClientPrefs;
import engine.utils.Controls;
import engine.utils.CoolUtil;
import engine.utils.MathUtil;
import engine.utils.Paths;
import versus.states.CreditState;
import versus.states.MainMenuState;
import versus.states.PlayState;
import versus.states.TitleState;
import versus.substates.OptionSubState;

class ImportAll
{
	public function new()
	{
		// load('source');
	}

	// public static macro function load(source:String):haxe.macro.Expr
	// {
	// 	var files:Array<String> = extractFolder(source);
	// 	haxe.macro.Context.error([
	// 		for (file in files)
	// 			'import ' + StringTools.replace(file.substr(7, file.length - 10), '/', '.') + ';'
	// 	].join('\n'), haxe.macro.Context.currentPos());
	// 	return macro $v{files};
	// }

	public static function extractFolder(path:String):Array<String>
	{
		var res:Array<String> = [];
		var dir:Array<String> = sys.FileSystem.readDirectory(path);
		for (sub in dir)
		{
			if (sys.FileSystem.isDirectory(path + '/' + sub))
				res = res.concat(extractFolder(path + '/' + sub));
			else
				res.push(path + '/' + sub);
		}
		return res;
	}
}
#else
class ImportAll
{
}
#end
