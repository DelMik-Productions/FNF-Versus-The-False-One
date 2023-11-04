package macros;

import haxe.macro.Context;
import haxe.macro.Expr;

class ControlPropsGenerator
{
	public static macro function generate(action:Expr):Array<Field>
	{
		var fields:Array<Field> = Context.getBuildFields();
		var pos:Position = Context.currentPos();

		var name:String = getName(action);
		var type = Context.getType(name);

		switch (type)
		{
			case TEnum(_.get() => en, _):
				for (construct in en.constructs)
				{
					var name = construct.name;
					var meta = construct.meta.get().map(m -> m.name);
					switch (meta[0].toLowerCase())
					{
						case ':justreleased' | 'justreleased':
							addField(fields, name, pos, -1); // JUST_RELEASED

						case ':released' | 'released':
							addField(fields, name, pos, 0); // RELEASED

						case ':pressed' | 'pressed':
							addField(fields, name, pos, 1); // PRESSED

						case ':justpressed' | 'justpressed':
							addField(fields, name, pos, 2); // JUST_PRESSED

						// case 'all':
						default:
							addField(fields, name, pos, 1); // PRESSED
							addField(fields, name + '_P', pos, 2); // JUST_PRESSED
							addField(fields, name + '_R', pos, -1); // JUST_RELEASED
					}
				}

			default:
		}

		return fields;
	}

	private static function addField(Fields:Array<Field>, Name:String, Pos:Position, State:Int):Void
	{
		var fieldName:String = '_${Name.toLowerCase()}';
		var e:Expr = {
			expr: EConst(CIdent(fieldName)),
			pos: Pos,
		};

		var s:Expr = {
			expr: EConst(CInt(Std.string(State))),
			pos: Pos,
		};

		Fields.push({
			name: fieldName,
			access: [APrivate],
			kind: FVar(macro :Action, macro new Action($s)),
			pos: Pos,
		});

		Fields.push({
			name: Name,
			access: [APublic],
			kind: FProp('get', 'never', macro :Bool, null),
			pos: Pos,
		});

		Fields.push({
			name: 'get_' + Name,
			access: [APrivate, AInline],
			kind: FFun({
				args: [],
				ret: macro :Bool,
				expr: macro
				{
					return $e.check();
				},
			}),
			pos: Pos
		});
	}

	private static function getName(expr:Expr):String
	{
		var str:String = null;

		switch (expr.expr)
		{
			case EConst(c):
				switch (c)
				{
					case CIdent(s):
						str = s;
					case CString(s, kind):
						str = s;
					default:
				}
			default:
		}

		return str ?? '';
	}
}
