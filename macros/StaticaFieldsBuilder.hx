package macros;

import haxe.macro.Context;
import haxe.macro.Expr;

class StaticaFieldsBuilder
{
	public static macro function build():Array<Field>
	{
		var fields:Array<Field> = Context.getBuildFields();

		for (field in fields)
		{
			if (!isDynamica(field) && field.name != 'new' && field.access.indexOf(AStatic) < 0)
			{
				field.access.push(AStatic);
			}
		}

		return fields;
	}

	private static function isDynamica(field:Field):Bool
	{
		if (field == null || field.meta == null)
			return false;

		var meta:Metadata = field.meta;
		for (m in meta)
		{
			if (m.name == ':dynamic' || m.name == 'dynamic')
				return true;
		}

		return false;
	}
}
