

'use strict'


############################################################################################################
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'INTERCOURSE/TESTS/MAIN'
debug                     = CND.get_logger 'debug',     badge
warn                      = CND.get_logger 'warn',      badge
info                      = CND.get_logger 'info',      badge
urge                      = CND.get_logger 'urge',      badge
help                      = CND.get_logger 'help',      badge
whisper                   = CND.get_logger 'whisper',   badge
echo                      = CND.echo.bind CND
#...........................................................................................................
test                      = require 'guy-test'
jr                        = JSON.stringify
IC                        = require '../..'
{ inspect, }              = require 'util'
xrpr                      = ( x ) -> inspect x, { colors: yes, breakLength: Infinity, maxArrayLength: Infinity, depth: Infinity, }
xrpr2                     = ( x ) -> inspect x, { colors: yes, breakLength: 20, maxArrayLength: Infinity, depth: Infinity, }

#-----------------------------------------------------------------------------------------------------------
@[ "basic 1" ] = ( T, done ) ->
  probes_and_matchers = [
    ["procedure x:\n  foo bar",{"x":{"type":"procedure","null":{"text":"foo bar\n","location":{"line_nr":1},"kenning":"null","type":"procedure"}}},null]
    ["procedure x:\n  foo bar\n",{"x":{"type":"procedure","null":{"text":"foo bar\n","location":{"line_nr":1},"kenning":"null","type":"procedure"}}},null]
    ["procedure x:\n  foo bar\n\n",{"x":{"type":"procedure","null":{"text":"foo bar\n","location":{"line_nr":1},"kenning":"null","type":"procedure"}}},null]
    ["procedure x:\n  foo bar\n\nprocedure y:\n  foo bar\n\n",{"x":{"type":"procedure","null":{"text":"foo bar\n","location":{"line_nr":1},"kenning":"null","type":"procedure"}},"y":{"type":"procedure","null":{"text":"foo bar\n","location":{"line_nr":4},"kenning":"null","type":"procedure"}}},null]
    ]
  #.........................................................................................................
  for [ probe, matcher, error, ] in probes_and_matchers
    await T.perform probe, matcher, error, -> return new Promise ( resolve, reject ) ->
      # try
      result = await IC.read_definitions_from_text probe
      # catch error
      #   return resolve error.message
      # debug '29929', xrpr2 result
      resolve result
  done()
  return null

#-----------------------------------------------------------------------------------------------------------
@[ "signatures" ] = ( T, done ) ->
  probes_and_matchers = [
    ["procedure foobar:\n  some text",{"foobar":{"type":"procedure","null":{"text":"some text\n","location":{"line_nr":1},"kenning":"null","type":"procedure"}}},null]
    ["procedure foobar():\n  some text",{"foobar":{"type":"procedure","()":{"text":"some text\n","location":{"line_nr":1},"kenning":"()","type":"procedure","signature":[]}}},null]
    ["procedure foobar( first ):\n  some text",{"foobar":{"type":"procedure","(first)":{"text":"some text\n","location":{"line_nr":1},"kenning":"(first)","type":"procedure","signature":["first"]}}},null]
    ["procedure foobar(first):\n  some text",{"foobar":{"type":"procedure","(first)":{"text":"some text\n","location":{"line_nr":1},"kenning":"(first)","type":"procedure","signature":["first"]}}},null]
    ["procedure foobar( first, ):\n  some text",{"foobar":{"type":"procedure","(first)":{"text":"some text\n","location":{"line_nr":1},"kenning":"(first)","type":"procedure","signature":["first"]}}},null]
    ["procedure foobar(first,):\n  some text",{"foobar":{"type":"procedure","(first)":{"text":"some text\n","location":{"line_nr":1},"kenning":"(first)","type":"procedure","signature":["first"]}}},null]
    ["procedure foobar( first, second ):\n  some text",{"foobar":{"type":"procedure","(first,second)":{"text":"some text\n","location":{"line_nr":1},"kenning":"(first,second)","type":"procedure","signature":["first","second"]}}},null]
    ["procedure foobar( first, second, ):\n  some text",{"foobar":{"type":"procedure","(first,second)":{"text":"some text\n","location":{"line_nr":1},"kenning":"(first,second)","type":"procedure","signature":["first","second"]}}},null]
    ["procedure foobar( first, second, ): some text\nprocedure foobar( first ): other text\nprocedure foobar(): blah\n",{"foobar":{"type":"procedure","(first,second)":{"text":"some text\n","location":{"line_nr":1},"kenning":"(first,second)","type":"procedure","signature":["first","second"]},"(first)":{"text":"other text\n","location":{"line_nr":2},"kenning":"(first)","type":"procedure","signature":["first"]},"()":{"text":"blah\n","location":{"line_nr":3},"kenning":"()","type":"procedure","signature":[]}}},null]
    ]
  #.........................................................................................................
  for [ probe, matcher, error, ] in probes_and_matchers
    await T.perform probe, matcher, error, -> return new Promise ( resolve, reject ) ->
      # try
      result = await IC.read_definitions_from_text probe
      # catch error
      #   return resolve error.message
      # debug '29929', xrpr2 result
      resolve result
  done()
  return null

#-----------------------------------------------------------------------------------------------------------
@[ "oneliners" ] = ( T, done ) ->
  probes_and_matchers = [
    # ["procedure foobar:  some text\n  illegal line",null,'illegal follow-up after one-liner']
    ["procedure foobar: some text",{"foobar":{"type":"procedure","null":{"text":"some text\n","location":{"line_nr":1},"kenning":"null","type":"procedure"}}},null]
    ["procedure foobar(): some text",{"foobar":{"type":"procedure","()":{"text":"some text\n","location":{"line_nr":1},"kenning":"()","type":"procedure","signature":[]}}},null]
    ["procedure foobar( first ): some text",{"foobar":{"type":"procedure","(first)":{"text":"some text\n","location":{"line_nr":1},"kenning":"(first)","type":"procedure","signature":["first"]}}},null]
    ["procedure foobar(first): some text",{"foobar":{"type":"procedure","(first)":{"text":"some text\n","location":{"line_nr":1},"kenning":"(first)","type":"procedure","signature":["first"]}}},null]
    ["procedure foobar( first, ): some text",{"foobar":{"type":"procedure","(first)":{"text":"some text\n","location":{"line_nr":1},"kenning":"(first)","type":"procedure","signature":["first"]}}},null]
    ["procedure foobar(first,): some text",{"foobar":{"type":"procedure","(first)":{"text":"some text\n","location":{"line_nr":1},"kenning":"(first)","type":"procedure","signature":["first"]}}},null]
    ["procedure foobar( first, second ): some text",{"foobar":{"type":"procedure","(first,second)":{"text":"some text\n","location":{"line_nr":1},"kenning":"(first,second)","type":"procedure","signature":["first","second"]}}},null]
    ["procedure foobar( first, second, ): some text",{"foobar":{"type":"procedure","(first,second)":{"text":"some text\n","location":{"line_nr":1},"kenning":"(first,second)","type":"procedure","signature":["first","second"]}}},null]
    ]
  #.........................................................................................................
  for [ probe, matcher, error, ] in probes_and_matchers
    await T.perform probe, matcher, error, -> return new Promise ( resolve, reject ) ->
      # try
      result = await IC.read_definitions_from_text probe
      # catch error
      #   return resolve error
      # debug '29929', xrpr2 result
      resolve result
  done()
  return null

#-----------------------------------------------------------------------------------------------------------
@[ "_parse demo" ] = ( T, done ) ->
  PATH      = require 'path'
  path      = PATH.join __dirname, '../../demos/sqlite-demo.icql'
  debug xrpr2 await IC.read_definitions path
  done()
  return null





############################################################################################################
unless module.parent?
  test @
  # test @[ "basic 1" ]
  # test @[ "signatures" ]
  # test @[ "oneliners" ]
  # test @[ "_parse demo" ]


