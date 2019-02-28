

'use strict'

############################################################################################################
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'INTERCOURSE/MAIN'
debug                     = CND.get_logger 'debug',     badge
warn                      = CND.get_logger 'warn',      badge
info                      = CND.get_logger 'info',      badge
urge                      = CND.get_logger 'urge',      badge
help                      = CND.get_logger 'help',      badge
whisper                   = CND.get_logger 'whisper',   badge
echo                      = CND.echo.bind CND
#...........................................................................................................
PATH                      = require 'path'
PD                        = require 'pipedreams'
{ $
  $async
  select }                = PD
{ assign
  jr }                    = CND

#-----------------------------------------------------------------------------------------------------------
collapse_text = ( list_of_texts ) ->
  R = list_of_texts
  R = R.join '\n'
  R = R.replace /^\s*/, ''
  R = R.replace /\s*$/, ''
  R = R + '\n'
  return R

#-----------------------------------------------------------------------------------------------------------
@$as_line_datoms = ( S ) ->
  line_nr = 0
  return $ ( line, send ) ->
    line_nr += +1
    d           = PD.new_event '^line', line, $: { line_nr, }
    d.is_blank  = true if ( d.value.match /^\s*$/ )?
    send d
    return null

#-----------------------------------------------------------------------------------------------------------
@$skip_comments = ( S ) -> PD.$filter ( d ) -> not ( d.value.match S.comments )?

#-----------------------------------------------------------------------------------------------------------
@$add_headers = ( S ) ->
  header_pattern = /// ^ (?<ictype> \S+ ) \s+ (?<icname> \S+ ) \s* : \s*  $ ///
  ignore_pattern = /// ^ ignore \s* : \s*  $ ///
  return $ ( d, send ) ->
    return send d if d.is_blank
    return send d if ( d.value.match /^\s/ )?
    #.......................................................................................................
    if ( match = d.value.match ignore_pattern )?
      return send PD.new_event '^ignore', match.groups, $: d
    #.......................................................................................................
    if ( match = d.value.match header_pattern )?
      return send PD.new_event '^definition', match.groups, $: d
    #.......................................................................................................
    throw new Error "µ83473 illegal line #{rpr d}"
    return null

#-----------------------------------------------------------------------------------------------------------
@$add_regions = ( S ) ->
  within_region = false
  prv_name      = null
  last          = Symbol 'last'
  #.........................................................................................................
  return $ ( d, send ) ->
    #.......................................................................................................
    if d is last
      if prv_name?
        send PD.new_event '>' + prv_name
        prv_name = null
      return
    #.......................................................................................................
    if select d, '^line'
      return send d if within_region
      return if d.is_blank
      throw new Error "µ85818 found line outside of any region: #{rpr d}"
    #.......................................................................................................
    if prv_name?
      send PD.new_event '>' + prv_name
      within_region = false
      prv_name      = null
    #.......................................................................................................
    unless within_region
      ### TAINT use PipeDreams API for this ###
      d             = CND.deep_copy d
      prv_name      = d.key[ 1 .. ]
      d.key         = '<' + prv_name
      within_region = true
      send d
    #.......................................................................................................
    return null

#-----------------------------------------------------------------------------------------------------------
@$skip_ignored = ( S ) ->
  within_ignore = false
  return $ ( d, send ) ->
    if select d, '<ignore'
      within_ignore = true
    else if select d, '>ignore'
      within_ignore = false
    else unless within_ignore
      send d
    #.......................................................................................................
    return null

#-----------------------------------------------------------------------------------------------------------
@$collect_definitions = ( S ) ->
  this_definition   = null
  this_indentation  = null
  #.........................................................................................................
  return $ ( d, send ) ->
    #.......................................................................................................
    if select d, '<definition'
      name                = d.value.icname
      type                = d.value.ictype
      location            = d.$
      this_definition     = { name, type, text: [], location, }
    #.......................................................................................................
    else if select d, '>definition'
      this_definition.text  = collapse_text this_definition.text
      send this_definition
      this_definition       = null
      this_indentation      = null
    #.......................................................................................................
    else if select d, '^line'
      return this_definition.text.push '' if d.is_blank
      text = d.value
      #.....................................................................................................
      unless this_indentation?
        unless ( match = text.match /^\s+/ )?
          throw new Error "µ88163 unexpected indentation: #{rpr d}"
        this_indentation = match[ 0 ]
      #.....................................................................................................
      else
        unless text.startsWith this_indentation
          throw new Error "µ90508 unexpected indentation: #{rpr d}"
      #.....................................................................................................
      text = text[ this_indentation.length .. ]
      this_definition.text.push text
    #.......................................................................................................
    else
      throw new Error "µ92853 unexpected datom: #{rpr d}"
    #.......................................................................................................
    return null

#-----------------------------------------------------------------------------------------------------------
@read_file = ( path ) ->
  S         = { comments: /^--/, }
  source    = PD.read_from_file path
  pipeline  = []
  pipeline.push source
  pipeline.push PD.$split()
  pipeline.push @$as_line_datoms        S
  pipeline.push @$skip_comments         S
  pipeline.push @$add_headers           S
  pipeline.push @$add_regions           S
  pipeline.push @$skip_ignored          S
  pipeline.push @$collect_definitions   S
  pipeline.push PD.$show()
  pipeline.push PD.$drain()
  PD.pull pipeline...

@read_file PATH.resolve PATH.join __dirname, '../demos/sqlite-demo.icsql'

# sql = ( require 'yesql' ) PATH.resolve PATH.join __dirname, '../db'
# debug ( key for key of sql )
# info rpr sql.add_query
# info rpr sql.create_table_queries



# # db_path   = PATH.resolve PATH.join __dirname, '../../db/data.db'
# Database      = require 'better-sqlite3'
# sqlitemk_path = PATH.resolve PATH.join __dirname, '../db'
# db_path       = PATH.join sqlitemk_path, 'demo.db'
# db            = new Database db_path
# # db            = new Database db_path, { verbose: urge }

# ( db.prepare sql.drop_table_queries   ).run()
# ( db.prepare sql.create_table_queries ).run()

# add_query = db.prepare sql.add_query
# add_query.run { query: 'Zeta' }
# add_query.run { query: 'Eta' }
# add_query.run { query: 'epsilon' }
# add_query.run { query: 'iota' }

# debug '33398'
# for row from ( db.prepare sql.get_queries ).iterate()
#   info row


# process.exit 1

# source    = PD.new_push_source()
# pipeline  = []
# pipeline.push source
# pipeline.push PD.$show()
# pipeline.push PD.$drain()
# PD.pull pipeline...

# as_int = ( x ) -> if x then 1 else 0

# #-----------------------------------------------------------------------------------------------------------
# db.function 'matches', { deterministic: true, }, ( text, pattern ) ->
#   return as_int ( text.match new RegExp pattern )?

# #-----------------------------------------------------------------------------------------------------------
# db.function 'regexp_replace', { deterministic: true, }, ( text, pattern, replacement ) ->
#   return text.replace ( new RegExp pattern, 'g' ), replacement

# #-----------------------------------------------------------------------------------------------------------
# db.function 'cleanup_texname', { deterministic: true, }, ( text ) ->
#   R = text
#   R = R.replace /\\/g,    ''
#   R = R.replace /[{}]/g,  '-'
#   R = R.replace /-+/g,    '-'
#   R = R.replace /^-/g,    ''
#   R = R.replace /-$/g,    ''
#   R = R.replace /'/g,     'acute'
#   return R

# r = ( strings ) -> return [ 'run',   ( strings.join '' ), ]
# q = ( strings ) -> return [ 'query', ( strings.join '' ), ]


# sqls = [
#   # q""".tables"""
#   r"""drop view if exists xxx;"""
#   q"""select * from amatch_vtable
#   where true
#     and ( distance <= 100 )
#     -- and ( word match 'abc' )
#     -- and ( word match 'xxxx' )
#     -- and ( word match 'cat' )
#     -- and ( word match 'dog' )
#     -- and ( word match 'television' )
#     -- and ( word match 'treetop' )
#     -- and ( word match 'bath' )
#     -- and ( word match 'kat' )
#     and ( word match 'laern' )
#     -- and ( word match 'wheather' )
#     -- and ( word match 'waether' )
#     ;"""
#   # r"""create view xxx as select
#   #     "UNICODE DESCRIPTION"     as uname,
#   #     latex                     as latex,
#   #     cleanup_texname( latex )  as texname
#   #   from unicode_entities
#   #   where true
#   #     and ( not matches( latex, '^\\s*$' ) );"""
#   # q"""select * from xxx limit 2500;"""
#   q"""select sqlite_version();"""
#   ]

# for [ mode, sql, ] in sqls
#   urge sql
#   try
#     statement = db.prepare sql
#   catch error
#     whisper '-'.repeat 108
#     warn "when trying to prepare statement"
#     info sql
#     warn "an error occurred:"
#     info error.message
#     whisper '-'.repeat 108
#     throw error
#   switch mode
#     when 'run'
#       debug statement.run()
#     when 'query'
#       source.send row for row from statement.iterate()
#     else
#       throw new Error "µ95198 unknown mode #{rpr mode}"


