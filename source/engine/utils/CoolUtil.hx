package engine.utils;

import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.util.FlxColor;
import lime.system.System;
import openfl.Vector;
import openfl.media.Sound;
import sys.FileSystem;

@:cppFileCode('
#include <iostream>
#include <chrono>
')
@:build(macros.StaticaFieldsBuilder.build())
class CoolUtil
{
	var graphic:FlxGraphic;

	public inline function browserLoad(URL:String):Void
	{
		System.openURL(URL);
	}

	public function getSystemMilliseconds():Float
	{
		return getSystemSeconds() * 1000.0;
	}

	@:functionCode('
    auto now = std::chrono::high_resolution_clock::now();
    auto duration = std::chrono::duration<double>(now.time_since_epoch());
    return duration.count();
    ')
	public function getSystemSeconds():Float
	{
		return 0.0;
	}

	/**
		* Find normal value (not null) of multi contract values or variables.]
		```haxe
		var value:String = multiProcess(str -> str, [null, null, 'This is String.']);
		trace(value) // This is String.
		```
	 */
	@:generic
	public function multiProcess<T, V>(T1:T->V, T2:Array<T>):V
	{
		var v:V = null;

		for (t in T2)
		{
			v = T1(t);
			if (v != null)
			{
				return v;
			}
		}

		return null;
	}

	/**
	 * The simplied Reflecting the call function.
	 * @param o 
	 * @param func 
	 * @param ...args 
	 * @return Dynamic
	 */
	public inline function callMethod(o:Dynamic, func:String, ...args:Dynamic):Dynamic
	{
		if (args == null)
			args = [];
		return Reflect.callMethod(o, Reflect.field(o, func), args);
	}

	public inline function makeGraphic():FlxGraphic
	{
		if (graphic == null)
		{
			graphic = FlxGraphic.fromRectangle(1, 1, -1, true, 'temporary_graphic');
			graphic.destroyOnNoUse = false;
			graphic.persist = true;
		}
		return graphic;
	}

	public function extractFolder(path:String):Array<String>
	{
		var res:Array<String> = [];
		var dir:Array<String> = FileSystem.readDirectory(path);
		for (path in dir)
		{
			if (FileSystem.isDirectory(dir + '/' + path))
				res = res.concat(extractFolder(dir + '/' + path));
			else
				res.push(dir + '/' + path);
		}
		return res;
	}

	/**
	 * Return the float color array to FlxColor.
	 */
	public inline function colorFromArray(arr:Array<Float>):FlxColor
	{
		return FlxColor.fromRGBFloat(arr[0], arr[1], arr[2], arr[3] ?? 1.0);
	}

	/**
	 * Return the FlxColor to float color array (include alphaFloat).
	 */
	public inline function arrayFromColor(Color:FlxColor):Array<Float>
	{
		return [Color.redFloat, Color.greenFloat, Color.blueFloat, Color.alphaFloat];
	}

	public static function soundRandom(Path:String, Min:Int, Max:Int, ?Library:String):Sound
	{
		return Paths.sound(Path + Std.string(FlxG.random.int(Min, Max)), Library);
	}

	@:generic
	public function clearArray<T>(array:Array<T>):Array<T>
	{
		if (array != null)
		{
			array.splice(0, array.length);
		}
		return null;
	}
}
