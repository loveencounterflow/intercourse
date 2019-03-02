

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

#-----------------------------------------------------------------------------------------------------------
@[ "basic 1" ] = ( T, done ) ->
  probes_and_matchers = [
    ["procedure x:\n  foo bar",{"x":{"name":"x","type":"procedure","text":"foo bar\n","location":{"line_nr":1}}},null]
    ["procedure x:\n  foo bar\n",{"x":{"name":"x","type":"procedure","text":"foo bar\n","location":{"line_nr":1}}},null]
    ["procedure x:\n  foo bar\n\n",{"x":{"name":"x","type":"procedure","text":"foo bar\n","location":{"line_nr":1}}},null]
    ["procedure x:\n  foo bar\n\nprocedure y:\n  foo bar\n\n",{"x":{"name":"x","type":"procedure","text":"foo bar\n","location":{"line_nr":1}},"y":{"name":"y","type":"procedure","text":"foo bar\n","location":{"line_nr":4}}},null]
    ]
  #.........................................................................................................
  for [ probe, matcher, error, ] in probes_and_matchers
    await T.perform probe, matcher, error, -> return new Promise ( resolve, reject ) ->
      # try
      result = await IC.read_definitions_from_text probe
      # catch error
      #   return resolve error.message
      # debug '29929', result
      resolve result
  done()
  return null

#-----------------------------------------------------------------------------------------------------------
@[ "signatures" ] = ( T, done ) ->
  probes_and_matchers = [
    ["procedure foobar:\n  some text",{"foobar":{"name":"foobar","type":"procedure","text":"some text\n","location":{"line_nr":1}}},null]
    ["procedure foobar():\n  some text",{"foobar":{"name":"foobar","type":"procedure","text":"some text\n","location":{"line_nr":1},"signature":[]}},null]
    ["procedure foobar( first ):\n  some text",{"foobar":{"name":"foobar","type":"procedure","text":"some text\n","location":{"line_nr":1},"signature":["first"]}},null]
    ["procedure foobar(first):\n  some text",{"foobar":{"name":"foobar","type":"procedure","text":"some text\n","location":{"line_nr":1},"signature":["first"]}},null]
    ["procedure foobar( first, ):\n  some text",{"foobar":{"name":"foobar","type":"procedure","text":"some text\n","location":{"line_nr":1},"signature":["first"]}},null]
    ["procedure foobar(first,):\n  some text",{"foobar":{"name":"foobar","type":"procedure","text":"some text\n","location":{"line_nr":1},"signature":["first"]}},null]
    ["procedure foobar( first, second ):\n  some text",{"foobar":{"name":"foobar","type":"procedure","text":"some text\n","location":{"line_nr":1},"signature":["first","second"]}},null]
    ["procedure foobar( first, second, ):\n  some text",{"foobar":{"name":"foobar","type":"procedure","text":"some text\n","location":{"line_nr":1},"signature":["first","second"]}},null]
    ]
  #.........................................................................................................
  for [ probe, matcher, error, ] in probes_and_matchers
    await T.perform probe, matcher, error, -> return new Promise ( resolve, reject ) ->
      # try
      result = await IC.read_definitions_from_text probe
      # catch error
      #   return resolve error.message
      debug '29929', result
      resolve result
  done()
  return null

#-----------------------------------------------------------------------------------------------------------
@[ "oneliners" ] = ( T, done ) ->
  probes_and_matchers = [
    # ["procedure foobar:  some text\n  illegal line",null,'illegal follow-up after one-liner']
    ["procedure foobar:  some text",{"foobar":{"name":"foobar","type":"procedure","text":"some text\n","location":{"line_nr":1}}},null]
    ["procedure foobar():  some text",{"foobar":{"name":"foobar","type":"procedure","text":"some text\n","location":{"line_nr":1},"signature":[]}},null]
    ["procedure foobar( first ):  some text",{"foobar":{"name":"foobar","type":"procedure","text":"some text\n","location":{"line_nr":1},"signature":["first"]}},null]
    ["procedure foobar(first):  some text",{"foobar":{"name":"foobar","type":"procedure","text":"some text\n","location":{"line_nr":1},"signature":["first"]}},null]
    ["procedure foobar( first, ):  some text",{"foobar":{"name":"foobar","type":"procedure","text":"some text\n","location":{"line_nr":1},"signature":["first"]}},null]
    ["procedure foobar(first,):  some text",{"foobar":{"name":"foobar","type":"procedure","text":"some text\n","location":{"line_nr":1},"signature":["first"]}},null]
    ["procedure foobar( first, second ):  some text",{"foobar":{"name":"foobar","type":"procedure","text":"some text\n","location":{"line_nr":1},"signature":["first","second"]}},null]
    ["procedure foobar( first, second, ):  some text",{"foobar":{"name":"foobar","type":"procedure","text":"some text\n","location":{"line_nr":1},"signature":["first","second"]}},null]
    ]
  #.........................................................................................................
  for [ probe, matcher, error, ] in probes_and_matchers
    await T.perform probe, matcher, error, -> return new Promise ( resolve, reject ) ->
      # try
      result = await IC.read_definitions_from_text probe
      # catch error
      #   return resolve error
      # debug '29929', result
      resolve result
  done()
  return null





############################################################################################################
unless module.parent?
  test @
  # test @[ "signatures" ]
  # test @[ "oneliners" ]


