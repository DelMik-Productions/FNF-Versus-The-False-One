package macros;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.ExprTools;

class RuntimeSharedFieldsBuilder
{
	private static var t:ComplexType;
	private static var c:Expr;
	private static var e:Expr;
	private static var o:Expr;

	public static macro function build():Array<Field>
	{
		var fields:Array<Field> = [];
		var local:Array<Field> = Context.getBuildFields();

		var localClass = Context.getLocalClass().get();
		var name:String = localClass.name;
		var path:String = (localClass.pack.length > 0) ? localClass.pack.join('/') : '';

		var pos = Context.currentPos();

		fields.push({
			name: '_conn',
			doc: 'Hidden Connector for Sharable Fields.',
			access: [APrivate, AStatic],
			kind: FVar(macro :flixel.util.FlxSave),
			pos: pos,
			meta: [
				{
					name: ':noCompletion',
					pos: pos,
				}
			],
		});
		c = macro _conn;
		e = macro _conn.data;

		for (field in local)
		{
			var meta = field.meta;
			if (meta == null || meta.length < 1)
			{
				fields.push(field);
				continue;
			}

			var isField:Bool = meta.filter(m -> m.name == 'field' || m.name == ':field').length > 0 && !field.access.contains(AStatic);

			if (isField)
			{
				switch (field.kind)
				{
					case FVar(_t, _e):
						t = _t;
						o = _e;
					default:
						throw new Error('Field Variable must be just var: ${field.name}', field.pos);
				}

				fields.push(toPropertyField(field));
				fields.push(getGetterFunc(field));
				fields.push(getSetterFunc(field));
			}
			else
			{
				fields.push(field);
			}
		}

		return fields;
	}

	public static function toPropertyField(f:Field):Field
	{
		f.access.push(AStatic);
		f.kind = FProp('get', 'set', t);
		if (f.doc != null && f.doc.length > 0)
		{
			f.doc = 'original document: ${f.doc}\n\n\ninitialzed value: ${ExprTools.toString(o)}';
		}
		else
		{
			f.doc = 'initialzed value: ${ExprTools.toString(o)}';
		}
		return f;
	}

	public static function getGetterFunc(f:Field):Field
	{
		var name:String = f.name;
		var field:Field = {
			name: 'get_' + f.name,
			doc: '',
			access: safeConcat(f.access.filter(a -> a != APublic), [APrivate, AStatic]),
			kind: FFun({
				args: [],
				ret: t,
				expr: macro
				{
					if ($e.$name == null)
					{
						$e.$name = $o;
						$c.flush();
					}
					return $e.$name;
				},
				params: null,
			}),
			pos: f.pos,
			meta: [{name: ':noCompletion', pos: f.pos,}],
		};

		return field;
	}

	public static function getSetterFunc(f:Field):Field
	{
		var name:String = f.name;
		var field:Field = {
			name: 'set_' + f.name,
			doc: '',
			access: safeConcat(f.access.filter(a -> a != APublic), [APrivate, AStatic]),
			kind: FFun({
				args: [
					{
						name: 'v',
						opt: false,
						type: t,
						value: null,
						meta: null,
					}
				],
				ret: t,
				expr: macro
				{
					$e.$name = v;
					$c.flush();
					return $e.$name;
				},
				params: null,
			}),
			pos: f.pos,
			meta: [{name: ':noCompletion', pos: f.pos,}],
		};

		return field;
	}

	@:generic
	private static function safeConcat<T>(arr:Array<T>, i:Array<T>):Array<T>
	{
		var a = arr.copy();
		var u:Int = 0;
		while (u < i.length)
		{
			if (!a.contains(i[u]))
			{
				a.push(i[u]);
			}
			u++;
		}
		return a;
	}
}
