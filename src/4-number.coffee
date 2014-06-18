
############################################################################################################
# njs_util                  = require 'util'
# njs_path                  = require 'path'
# njs_fs                    = require 'fs'
#...........................................................................................................
TRM                       = require 'coffeenode-trm'
rpr                       = TRM.rpr.bind TRM
badge                     = '﴾4-number﴿'
log                       = TRM.get_logger 'plain',     badge
info                      = TRM.get_logger 'info',      badge
whisper                   = TRM.get_logger 'whisper',   badge
alert                     = TRM.get_logger 'alert',     badge
debug                     = TRM.get_logger 'debug',     badge
warn                      = TRM.get_logger 'warn',      badge
help                      = TRM.get_logger 'help',      badge
echo                      = TRM.echo.bind TRM
#...........................................................................................................
ƒ                         = require 'flowmatic'


#===========================================================================================================
# OPTIONS
#-----------------------------------------------------------------------------------------------------------
@options =
  'digits':             /[0-9]+/


#===========================================================================================================
# CONSTRUCTOR
#-----------------------------------------------------------------------------------------------------------
@constructor = ( G, $ ) ->

  #=========================================================================================================
  # RULES
  #---------------------------------------------------------------------------------------------------------
  G.digits = ->
    return ( ƒ.or -> ƒ.regex $[ 'digits' ] )
    .onMatch ( match ) -> match[ 0 ]

  #---------------------------------------------------------------------------------------------------------
  G.integer = ->
    return ( ƒ.or -> G.digits )
    .onMatch ( match, state ) -> G.nodes.integer state, match, parseInt match, 10
    .describe 'NUMBER/integer'

  #---------------------------------------------------------------------------------------------------------
  G.integer.as =
    coffee: ( node ) ->
      { value }   = node
      return target: rpr node[ 'value' ]

  #---------------------------------------------------------------------------------------------------------
  G.literal = ->
    return ƒ.or ( -> G.integer )


  #=========================================================================================================
  # NODES
  #---------------------------------------------------------------------------------------------------------
  G.nodes.integer = ( state, raw, value ) ->
    return ƒ.new._XXX_YYY_node G.integer.as, state, 'NUMBER/integer',
      'raw':    raw
      'value':  value


  #=========================================================================================================
  # TESTS
  #---------------------------------------------------------------------------------------------------------
  G.tests[ 'digits: parses sequences of ASCII digits' ] = ( test ) ->
    for probe in """0 12 7 1928374 080""".split /\s+/
      test.eq ( G.digits.run probe ), probe

  #---------------------------------------------------------------------------------------------------------
  G.tests[ 'digits: does not parse sequences with non-digits (1)' ] = ( test ) ->
    for probe in """0x 1q2 7# 192+8374 08.0""".split /\s+/
      test.throws ( => G.digits.run probe ), /Expected end/

  #---------------------------------------------------------------------------------------------------------
  G.tests[ 'digits: does not parse sequences with non-digits (2)' ] = ( test ) ->
    for probe in """q192 +3 -42""".split /\s+/
      test.throws ( => G.digits.run probe ), /Expected \/\[0-9\]\+\//

  #---------------------------------------------------------------------------------------------------------
  G.tests[ 'integer: parses sequences of ASCII digits' ] = ( test ) ->
    for probe in """0 12 7 1928374 080""".split /\s+/
      test.eq ( G.integer.run probe ), ( G.nodes.integer null, probe, parseInt probe, 10 )

  #---------------------------------------------------------------------------------------------------------
  G.tests[ 'number: recognizes integers' ] = ( test ) ->
    for probe in """0 12 7 1928374 080""".split /\s+/
      test.eq ( G.literal.run probe ), ( G.nodes.integer null, probe, parseInt probe, 10 )

  #---------------------------------------------------------------------------------------------------------
  G.tests[ 'number: compiles integers to JS' ] = ( test ) ->
    probes_and_matchers = [
      ['0',                           '0' ]
      ['000',                         '0' ]
      ['123',                         '123' ]
      ['00000123',                    '123' ]
      ['123456789123456789123456789', '1.2345678912345679e+26' ]
      ]
    for [ probe, matcher, ] in probes_and_matchers
      node        = G.literal.run probe
      # debug JSON.stringify ƒ.new._delete_grammar_references G.literal.run probe
      translation = G.integer.as.coffee node
      result      = ƒ.as.coffee.target translation
      # debug JSON.stringify result
      # debug '\n' + result
      test.eq result, matcher

      # test.eq ( test.as_js G.literal.run probe ), result


############################################################################################################
ƒ.new.consolidate @
# debug '©421', ( name for name of @tests )
# debug '©421', @


