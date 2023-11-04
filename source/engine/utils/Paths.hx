package engine.utils;

import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.system.FlxAssets;
import flixel.util.FlxStringUtil.isNullOrEmpty;
import openfl.media.Sound;
import openfl.system.System;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;

using StringTools;

@:build(macros.StaticaFieldsBuilder.build())
class Paths
{
	public inline var soundExt:String = '.ogg';

	public var defaultFont:String = 'Arial';
	public var currentLevel:String = '';

	@:noCompletion
	public var _image:ImageCache = new ImageCache();

	@:noCompletion
	public var _sound:SoundCache = new SoundCache();

	@:noCompletion
	public var _atlas:AtlasCache = new AtlasCache();

	var defaultLibrary:Array<String> = ['preload'];

	public function addDefaultLibrary(Library:String):Void
	{
		defaultLibrary.push(Library);
	}

	public function removeDefaultLibrary(Library:String):Void
	{
		defaultLibrary.remove(Library);
	}

	public function setCurrentLevel(?Level:String = ''):Void
	{
		currentLevel = Level;
	}

	public function cleanTheMemory():Void
	{
		_image.clear();
		_sound.clear();
		_atlas.clear();
		System.gc();
	}

	public function font(FileName:String, ?Library:String = ''):String
	{
		var iter:Array<String> = getIter(FileName, 'assets', 'fonts', Library);
		for (it in iter)
		{
			if (OpenFlAssets.exists(it + '.ttf', FONT))
				return it + '.ttf';
			if (OpenFlAssets.exists(it + '.otf', FONT))
				return it + '.otf';
		}
		return FlxAssets.FONT_DEFAULT;
	}

	public function sparrow(Path:String, ?Library:String = ''):FlxAtlasFrames
	{
		return CoolUtil.multiProcess(_atlas.cache, getIter(Path + '.xml', 'assets', 'images', Library));
	}

	public function packer(Path:String, ?Library:String = ''):FlxAtlasFrames
	{
		return CoolUtil.multiProcess(_atlas.cache, getIter(Path + '.txt', 'assets', 'images', Library));
	}

	public function txt(Path:String, ?Prefix:String = 'assets', ?Suffix:String = '', ?Library:String = ''):String
	{
		return getText(Path, '.txt', Prefix, Suffix, Library);
	}

	public function json(Path:String, ?Prefix:String = 'assets', ?Suffix:String = '', ?Library:String = ''):String
	{
		return getText(Path, '.json', Prefix, Suffix, Library);
	}

	public function xml(Path:String, ?Prefix:String = 'assets', ?Suffix:String = '', ?Library:String = ''):String
	{
		return getText(Path, '.xml', Prefix, Suffix, Library);
	}

	public function data(Path:String, ?Prefix:String = 'assets', ?Suffix:String = '', ?Library:String = ''):String
	{
		return getText(Path, '.data', Prefix, Suffix, Library);
	}

	public function getText(Path:String, Ext:String, ?Prefix:String = 'assets', ?Suffix:String = '', ?Library:String = ''):String
	{
		var iter:Array<String> = getIter(Path + Ext, Prefix, Suffix, Library);
		for (id in iter)
		{
			if (OpenFlAssets.exists(id, TEXT))
				return OpenFlAssets.getText(id);
		}
		return null;
	}

	public function video(FileName:String):String
	{
		return 'assets/videos/$FileName.mp4';
	}

	public function image(Path:String, ?Library:String = ''):FlxGraphic
	{
		return CoolUtil.multiProcess(_image.cache, getIter(Path + '.png', 'assets', 'images', Library));
	}

	public function sound(Path:String, ?Library:String = ''):Sound
	{
		return getSound(Path, 'assets', 'sounds', Library);
	}

	public function music(Path:String, ?Library:String = ''):Sound
	{
		return getSound(Path, 'assets', 'music', Library);
	}

	public function inst(SongName:String):Sound
	{
		return getSound('Inst', 'assets', SongName, 'songs');
	}

	public function voice(SongName:String, Character:String):Sound
	{
		return getSound('Voice-$Character', 'assets', SongName, 'songs');
	}

	public function getSound(Path:String, ?Prefix:String = 'assets', ?Suffix:String = '', ?Library:String = ''):Sound
	{
		return CoolUtil.multiProcess(_sound.cache, getIter(Path + soundExt, Prefix, Suffix, Library));
	}

	public function getIter(Path:String, ?Prefix:String = 'assets', ?Suffix:String = '', ?Library:String = ''):Array<String>
	{
		var arr:Array<String> = [];

		if (hasLibrary() && currentLevel != Library)
			arr.push(getPath(Path, Prefix, Suffix, currentLevel));

		if (!isNullOrEmpty(Library) && defaultLibrary.indexOf(Library) < 0)
			arr.push(getPath(Path, Prefix, Suffix, Library));

		for (library in defaultLibrary)
			arr.push(getPath(Path, Prefix, Suffix, library));

		return arr;
	}

	public function hasLibrary():Bool
	{
		return !isNullOrEmpty(currentLevel) && defaultLibrary.indexOf(currentLevel) < 0;
	}

	public function getPath(Path:String, Prefix:String = 'assets', Suffix:String = '', ?Library:String = ''):String
	{
		Prefix = corrent(Prefix, 'assets');
		Suffix = corrent(Suffix, '');
		Library = corrent(Library, 'preload', '');
		return '$Library:' + Prefix + '$Library/' + Suffix + Path;
	}

	private function corrent(v:String, k:String = '', add:String = '/'):String
	{
		if (v == null)
			v = k;
		else if (v.length > 0 && add.length > 0 && !v.endsWith(add))
			v = v + add;
		return v;
	}
}

@:generic
private interface Cache<T>
{
	public function cache(AssetPath:String):T;
	public function exists(AssetKey:String):Bool;
	public function dump(AssetKey:String):Bool;
	public function release(AssetKey:String):Void;
	public function clear():Void;
}

@:access(utils.Paths)
@:noCompletion
@:final
class ImageCache implements Cache<FlxGraphic>
{
	var cached:Map<String, FlxGraphic> = [];
	var dumped:Array<String> = [];

	public function new()
	{
	}

	@:access(flixel.graphics.FlxGraphic)
	public function cache(AssetPath:String):FlxGraphic
	{
		if (!cached.exists(AssetPath) && OpenFlAssets.exists(AssetPath, IMAGE))
		{
			var graphic:FlxGraphic = FlxG.bitmap.add(AssetPath, true, AssetPath);
			graphic.persist = true;
			graphic.destroyOnNoUse = false;

			cached.set(AssetPath, graphic);
		}

		return cached[AssetPath];
	}

	public function canCache(AssetPath:String):String
	{
		if (cached.exists(AssetPath))
			return AssetPath;

		var graphic:FlxGraphic = FlxG.bitmap.add(AssetPath);

		if (graphic == null)
			return null;

		graphic.persist = true;
		graphic.destroyOnNoUse = false;

		cached.set(AssetPath, graphic);

		return AssetPath;
	}

	public function exists(AssetKey:String):Bool
	{
		return cached.exists(AssetKey);
	}

	public function dump(AssetKey:String):Bool
	{
		if (cached.exists(AssetKey))
		{
			dumped.push(AssetKey);
			return true;
		}
		return false;
	}

	public function release(AssetKey:String):Void
	{
		if (!cached.exists(AssetKey))
			return;

		var graphic:FlxGraphic = cached[AssetKey];
		graphic.destroy();

		cached.remove(AssetKey);
	}

	public function clear():Void
	{
		for (key => value in cached)
		{
			if (dumped.indexOf(key) < 0)
			{
				release(key);
			}
		}
	}
}

@:access(utils.Paths)
@:noCompletion
@:final
class AtlasCache implements Cache<FlxAtlasFrames>
{
	var cached:Map<String, FlxAtlasFrames> = [];
	var dumped:Array<String> = [];

	public function new()
	{
	}

	public function cache(AssetPath:String):FlxAtlasFrames
	{
		if (!cached.exists(AssetPath))
		{
			var atlas:FlxAtlasFrames = null;
			var graphic:FlxGraphic = Paths._image.cache(AssetPath.substr(0, AssetPath.length - 4) + '.png');
			if (graphic == null)
				return null;

			if (AssetPath.endsWith('.xml'))
			{
				atlas = FlxAtlasFrames.fromSparrow(graphic, OpenFlAssets.getText(AssetPath));
			}
			else if (AssetPath.endsWith('.txt'))
			{
				atlas = FlxAtlasFrames.fromSpriteSheetPacker(graphic, OpenFlAssets.getText(AssetPath));
			}

			if (atlas != null)
			{
				cached.set(AssetPath, atlas);
			}
		}

		return cached[AssetPath];
	}

	public function exists(AssetKey:String):Bool
	{
		return cached.exists(AssetKey);
	}

	public function dump(AssetKey:String):Bool
	{
		if (cached.exists(AssetKey))
		{
			dumped.push(AssetKey);
			return true;
		}
		return false;
	}

	public function release(AssetKey:String):Void
	{
		if (!cached.exists(AssetKey))
			return;

		var atlas:FlxAtlasFrames = cached[AssetKey];
		atlas.destroy();

		cached.remove(AssetKey);
	}

	public function clear():Void
	{
		for (key => value in cached)
		{
			if (dumped.indexOf(key) < 0)
			{
				release(key);
			}
		}
	}
}

@:access(utils.Paths)
@:noCompletion
@:final
class SoundCache implements Cache<Sound>
{
	var cached:Map<String, Sound> = [];
	var dumped:Array<String> = [];

	public function new()
	{
	}

	public function cache(AssetPath:String):Sound
	{
		if (!cached.exists(AssetPath) && openFlExists(AssetPath))
		{
			var _sound:Sound = OpenFlAssets.getSound(AssetPath);
			if (_sound == null)
				return null;

			cached.set(AssetPath, _sound);
		}

		return cached[AssetPath];
	}

	public function exists(AssetKey:String):Bool
	{
		return cached.exists(AssetKey);
	}

	private function openFlExists(id:String):Bool
	{
		return OpenFlAssets.exists(id, AssetType.SOUND) || OpenFlAssets.exists(id, AssetType.MUSIC);
	}

	public function dump(AssetKey:String):Bool
	{
		if (cached.exists(AssetKey))
		{
			dumped.push(AssetKey);
			return true;
		}
		return false;
	}

	public function release(AssetKey:String):Void
	{
		if (!cached.exists(AssetKey))
			return;

		var sound:Sound = cached[AssetKey];
		sound.close();

		cached.remove(AssetKey);
	}

	public function clear():Void
	{
		for (key => value in cached)
		{
			if (dumped.indexOf(key) < 0)
			{
				release(key);
			}
		}
	}
}
