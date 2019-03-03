


# InterCourse

InterCourse (IC) is YeSQL-like utlity to treat files as archives of hunks of functionality descriptions,
IOW, it is a tool that lets you collect named snippets of arbitrary code—e.g. SQL queries and statements—in
text files. These snippets can then be retrieved and, for example, turned into functions that execute
queries against a database. InterCourse itself does a single job: it takes the path to an existing file and
returns a data structure that describes the definitions it found. It's up to users of InterCourse (the
'consumer') to bring those definitions to life (e.g. parse them to turn them into JS fiunctions, or wrap
them in JS functions and send the hunks to a database for execution, as does
[`icql`](https://github.com/loveencounterflow/icql)).

The format is whitespace-sensitive and super-simple:

* **Each line that does not start with whitespace and is not a top-level comment is considered an IC
  directive** (or a syntax error in case it fails to parse).

* A directive consists of a **type annotation** (that can be freely chosen), a **name** (that may not contain
  whitespace or round brackets), an **optional signature**, and a **source text** (the 'hunk').

* A definition is either a **one-liner** as in

  ```
  mytype myname(): myhunk
  ```

  or else a **multi-liner** as in

  ```
  mytype myname():
    first line
    second line
    ...
  ```

  Observe that **blank lines within hunks are kept, but blank lines between definitions are discarded**.
  Relative ordering of definitions has no effect whatsover on processing (except for the wording of
  potential error messages).

* **Each line in the hunk of a multi-liner must start with the same whitespace characters** (or else be
  blank); this indentation is called the 'plinth' and will be subtracted from each line. Currently, each
  block may have its own plinth, but that may change in the future (and it's probably a good idea never to
  mix tabs and spaces in a single file anyway).

* **IC itself puts no limit on definition types** and does not do anything with it except that it stores the
  (names of the types) in the returned description. It's up to InterCourse consumers to make sense of
  definition types, spot unknown ones, error out in the case of types and so on. In the case of
  [`icql`](https://github.com/loveencounterflow/icql), the allowed types are `query` for SQL statements that
  do return results (i.e. `SELECT`), and `procedure` for (series of) statements that do not return results
  (i.e. `CREATE`, `DROP`, `INSERT`).

* The elements of the signature (i.e. the parameters) are not further validated; instead, we just look for
  intermittent commas and remove surrounding whitespace. These details may change in the future so it's best
  to restrict oneself to anything that would be a valid JavaScript function signature without type
  annotations and without default values (e.g. you could write `def f( x = 42 )` but you'd probably best
  not).

* When giving multiple definitions for the same name, **each definition must have a unique set of named
  parameters**. Order of appearance is discarded. More precisely, the parameter names of the signature are
  sorted (using JS `Array.prototype.sort()`), joined with commas and wrapped with round brackets to obtain a
  unique key (which is called the 'kenning' of the definition); it is this key that must turn out be unique.

  So when you have already a definition `def foo( bar ): ...` you can add a definition `def foo( baz )`
  (other name) and a definition `def foo( bar, baz )` (other number of parameters), but `def foo( baz, bar
  )` would be considered as equivalent to `def foo( bar, baz )` and will throw an error.

* Signatures of **definition without round brackets** (as in `def myname: ...`) are known as 'null
  signatures' and may be interpreted as a catch-all definitions that won't get signature-checked. Signatures
  of **definitions with round brackets but no parameters inside** are called 'empty signatures' and will be
  taken to symbolize to allow for function calls with no arguments. The signatures of all other definitions
  (i.e. those with parameters) are called 'full signatures'.

  **One can only either give a single null-signature definition or else any number of empty- and
  full-signature definitions under the same name**. Thus use of `def f: ...` on the hand and `def f(): ...`
  and / or `def f( x ): ...` etc is mutually exclusive.

* As it stands, **all definitions with the same name must be of the same nominal type**. This restriction
  may be lifted or made optional in the future.

* The above three rules serve to ensure that the definitions as returned by InterCourse lend themselves to
  implement conflict-free **function overloading**. When you turn IC hunks into JS functions *that take, as
  their sole argument, a JS object*, then you will always be able to tell which definition will be used from
  the names that appear in the call. For example, when, in your app, you call `myfunc( { a: 42, b: true, }
  )`, the above rules ensure there must either be a definition like `... myfunc( a, b ):
  ...` (exactly as in the call) or `... myfunc( b, a ): ...` (same names but different order) or `...
  myfunc: ...` (a catch-all that precludes any other definitions with explicit signatures).

Here's an example:

```sql

-- ---------------------------------------------------------------------------------------------------------
-- A block defined without brackets will result in a description without a `signature` member:
procedure import_table_texnames:
  drop table if exists texnames;
  create virtual table texnames using csv( filename='texnames.csv' );

-- ---------------------------------------------------------------------------------------------------------
-- A block defined with empty brackets will result in `{ signature: [], }`:
procedure create_snippet_table():
  drop table if exists snippets;
  create table snippets (
      id      integer primary key,
      snippet text not null );

-- ---------------------------------------------------------------------------------------------------------
procedure populate_snippets():
  insert into snippets ( snippet ) values
    ( 'iota' ),
    ( 'Iota' ),
    ( 'alpha' ),
    ( 'Alpha' ),
    ( 'beta' ),
    ( 'Beta' );

-- ---------------------------------------------------------------------------------------------------------
-- Here we define a `query` that needs exactly one parameter:
query match_snippet( probe ):
  select id, snippet from snippets where snippet like $probe

-- ---------------------------------------------------------------------------------------------------------
-- one-liners and overloading are possible, too:
query fetch_texnames():                   select * from texnames;
query fetch_texnames( limit ):            select * from texnames limit $limit;
query fetch_texnames( pattern ):          select * from texnames where texname like pattern;
query fetch_texnames( pattern, limit ):   select * from texnames where texname like pattern limit $limit;

-- ---------------------------------------------------------------------------------------------------------
-- everything under an `ignore` heading will be ignored (duh):
ignore:
  This text will be ignored
```

The above will be turned into a JS object (here shown using YAML / CoffeeScript notation):

```yaml
import_table_texnames:
  type:   'procedure'
  'null':
    text:         'drop table if exists texnames;\ncreate virtual table texnames using csv( filename='texnames.csv' );\n'
    kenning:      'null'
    type:         'procedure'
    location:     { line_nr: 4, }

create_snippet_table: {
  type:   'procedure'
  '()':
    text:         'drop table if exists snippets;\ncreate table snippets (\n    id      integer primary key,\n    snippet text not null );\n'
    kenning:      '()'
    type:         'procedure'
    location:     { line_nr: 10, }
    signature:    []

populate_snippets:
  type:   'procedure'
  '()':
    text:         'insert into snippets ( snippet ) values\n  ( 'iota' ),\n  ( 'Iota' ),\n  ( 'alpha' ),\n  ( 'Alpha' ),\n  ( 'beta' ),\n  ( 'Beta' );\n'
    kenning:      '()'
    type:         'procedure'
    location:     { line_nr: 17, }
    signature:    []

match_snippet:
  type:   'query'
  '(probe)':
    kenning:      '(probe)'
    text:         'select id, snippet from snippets where snippet like $probe\n'
    type:         'query'
    location:     { line_nr: 28, }
    signature:    [ 'probe', ]

fetch_texnames:
  type:   'query'
  '()':
    kenning:      '()'
    text:         'select * from texnames;\n'
    type:         'query'
    location:     { line_nr: 33, }
    signature:    []
  '(limit)':
    kenning:      '(limit)'
    text:         'select * from texnames limit $limit;\n'
    type:         'query'
    location:     { line_nr: 34, }
    signature:    [ 'limit', ]
  '(pattern)':
    kenning:      '(pattern)'
    text:         'select * from texnames where texname like pattern;\n'
    type:         'query'
    location:     { line_nr: 34, }
    signature:    [ 'pattern', ]
  '(limit,pattern)':
    kenning:      '(limit,pattern)'
    text:         'select * from texnames where texname like pattern limit $limit;\n'
    type:         'query'
    location:     { line_nr: 34, }
    signature:    [ 'limit', 'pattern', ]
```


In the above, observe how `description.fetch_texnames[ '(limit,pattern)' ]` has been normalized from the
original definition, `query fetch_texnames( pattern, limit ):`. Null signatures are indexed under `'null'`
and lack a `signature` entry, while empty signatures are indexed under `()` and have an empty list as
`signature`. The source texts are either empty strings (in the case no hunk has been given) or else end in a
single newline.


