


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

* Each line that does not start with whitespace and is not a top-level comment is considered an IC directive
  (or a syntax error in case it fails to parse).

* A directive consists of a type annotation (that can be freely chosen), a name (that may not contain
  whitespace or round brackets), an optional signature, and a source text (the 'hunk').

* IC puts no limit on the definition type and does not do anything with it except store it in the returned
  description. It's up to InterCourse consumers to make sense of definition types. In the case of
  [`icql`](https://github.com/loveencounterflow/icql), the allowed types are `query` for SQL statements that
  do return results (i.e. `SELECT`), and `procedure` for (series of) statements that do not return results
  (i.e. `CREATE`, `DROP`, `INSERT`).

* The elements of the signature (i.e. the parameters) are not further validated; instead, we just look for
  intermittent commas and remove surrounding whitespace. This may change in the future.

* When giving multiple definitions for the same name, *each definition must choose a unique set of
  parameters*, be it by using a different number of parameters or different names in the case of the same
  number of parameters. Order of appearance is discarded. So when you have already a definition `def foo( bar
  ): ...` you can add a definition `def foo( baz )` (other name) and a definition `def foo( bar, baz )` (other
  number of parameters), but `def foo( baz, bar )` would be considered as equivalent to `def foo( bar, baz )`
  and will throw an error.

* When giving a definition without round brackets (as in `def myname: ...`), this is known as a 'null
  signature' and will be interpreted as a catch-all definition that won't get signature-checked.
  Consequently, it is an error to use such a signature-less definition in conjunction with namesake
  definitions that have a signature, including the empty one.

* A definition with round brackets but no parameters inside is called an 'empty signature' and will be taken
  to symbolize a function call with no arguments.

* Each line in a block must start with the same whitespace characters (or else be blank); this indentation
  is called the 'plinth' and will be subtracted from each line. Currently, each block may have its own
  plinth, but that may change in the future (and it's probably a good idea never to mix tabs and spaces in a
  single file anyway).

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
query fetch_texnames():         select * from texnames;
query fetch_texnames( $limit ): select * from texnames limit $limit;

-- ---------------------------------------------------------------------------------------------------------
-- everything under an `ignore` heading will be ignored (duh):
ignore:
  This text will be ignored
```

The above will be turned into a JS object (here shown using YAML / CoffeeScript notation):


```yaml
import_table_texnames:
  type:   'procedure'
  arity:
    'null':
      text:         'drop table if exists texnames;\ncreate virtual table texnames using csv( filename='texnames.csv' );\n'
      location:     { line_nr: 4, }

create_snippet_table: {
  type:   'procedure'
  arity:
    '()':
      text:         'drop table if exists snippets;\ncreate table snippets (\n    id      integer primary key,\n    snippet text not null );\n'
      location:     { line_nr: 10, }
      signature:    []

populate_snippets:
  type:   'procedure'
  arity:
    '()':
      text:         'insert into snippets ( snippet ) values\n  ( 'iota' ),\n  ( 'Iota' ),\n  ( 'alpha' ),\n  ( 'Alpha' ),\n  ( 'beta' ),\n  ( 'Beta' );\n'
      location:     { line_nr: 17, }
      signature:    []

match_snippet:
  type:   'query'
  arity:
    '(probe)':
      text:         'select id, snippet from snippets where snippet like $probe\n'
      location:     { line_nr: 28, }
      signature:    [ 'probe', ]

fetch_texnames:
  type:   'query'
  arity:
    '()':
      text:         'select * from texnames;\n'
      location:     { line_nr: 33, }
      signature:    []
    '(limit)':
      text:         'select * from texnames limit $limit;\n'
      location:     { line_nr: 34, }
      signature:    [ '$limit', ]
```




