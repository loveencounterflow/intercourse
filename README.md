

# InterCourse

InterCourse (IC) is YeSQL-like utlity to treat files as archives of hunks of functionality descriptions, IOW, it
is a tool that lets you collect named snippets of arbitrary code—e.g. SQL queries and statements—in text
files. These snippets can then be retrieved and, for example, turned into functions that execute
queries against a database.

The format is whitespace-sensitive and super-simple: Each line that does not start with whitespace and is
not a top-level comment is considered an IC directive (or a syntax error in case it fails to parse). A
directive consists of a type annotation (that can be freely chosen), a name (that may not contain whitespace
or round brackets), an optional signature, and a source text. For example:

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


```coffee
import_table_texnames:
  type:   'procedure'
  arity:
    null:
      text:         'drop table if exists texnames;\ncreate virtual table texnames using csv( filename='texnames.csv' );\n'
      location:     { line_nr: 4, }

create_snippet_table: {
  type:   'procedure'
  arity:
    '0':
      text:         'drop table if exists snippets;\ncreate table snippets (\n    id      integer primary key,\n    snippet text not null );\n'
      location:     { line_nr: 10, }
      signature:    []

populate_snippets:
  type:   'procedure'
  arity:
    '0':
      text:         'insert into snippets ( snippet ) values\n  ( 'iota' ),\n  ( 'Iota' ),\n  ( 'alpha' ),\n  ( 'Alpha' ),\n  ( 'beta' ),\n  ( 'Beta' );\n'
      location:     { line_nr: 17, }
      signature:    []

match_snippet:
  type:   'query'
  arity:
    '1':
      text:         'select id, snippet from snippets where snippet like $probe\n'
      location:     { line_nr: 28, }
      signature:    [ 'probe', ]

fetch_texnames:
  type:   'query'
  arity:
    '0':
      text:         'select * from texnames;\n'
      location:     { line_nr: 33, }
      signature:    []
    '1':
      text:         'select * from texnames limit $limit;\n'
      location:     { line_nr: 34, }
      signature:    [ '$limit', ]
```

Observe the following syntactical constraints:

* When giving multiple definitions with the same name, each definition must have another arity (number of
  formal arguments).

* When giving multiple definitions with the same name, no definition may be given with no round brackets
  (symbolized as arity `'null'`).

* Each line in a block must start with the same whitespace characters (or else be blank); this indentation
  will be subtracted from each line.
