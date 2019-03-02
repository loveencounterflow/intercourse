



# InterCourse

InterCourse (IC) is YeSQL-like utlity to treat files as archives of hunks of functionality descriptions, IOW, it
is a tool that lets you collect named snippets of arbitrary code—e.g. SQL queries and statements—in text
files. These snippets can then be retrieved and, for example, turned into functions that execute
queries against a database.

The format is whiutespace-sensitive and super-simple: Each line that does not start with whitespace and is
not a top-level comment is considered an IC directive (or a syntax error in case it fails to parse). A
directive consists of a type annotation (that can be freely chosen), a name (that may not contain whitespace
or round brackets), an optional signature, and a source text. For example:

```sql

-- ---------------------------------------------------------------------------------------------------------
procedure import_table_texnames:
  drop table if exists texnames;
  create virtual table texnames using csv( filename='texnames.csv' );

-- ---------------------------------------------------------------------------------------------------------
procedure create_snippet_table:
  drop table if exists snippets;
  create table snippets (
      id      integer primary key,
      snippet text not null );

-- ---------------------------------------------------------------------------------------------------------
procedure populate_snippets:
  insert into snippets ( snippet ) values
    ( 'iota' ),
    ( 'Iota' ),
    ( 'alpha' ),
    ( 'Alpha' ),
    ( 'beta' ),
    ( 'Beta' );

-- ---------------------------------------------------------------------------------------------------------
-- one-liners and overloading is possible, too:
query fetch_texnames(): 				select * from texnames;
query fetch_texnames( $limit ): select * from texnames limit $limit;

ignore:
	This text will be ignored
```

