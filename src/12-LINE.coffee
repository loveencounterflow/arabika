



############################################################################################################
TRM                       = require 'coffeenode-trm'
rpr                       = TRM.rpr.bind TRM
badge                     = '﴾12-line﴿'
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
BNP                       = require 'coffeenode-bitsnpieces'


#===========================================================================================================
# OPTIONS
#-----------------------------------------------------------------------------------------------------------
@options =
  'line-parsers': [
    ( require './11-loop' ).break_statement
    ( require './11-loop' ).loop_keyword
    ( require './10-assignment' ).assignment
    ( require './6-route' ).route
    ]
  # INDENTATION:            require './7-indentation'


#===========================================================================================================
# CONSTRUCTOR
#-----------------------------------------------------------------------------------------------------------
@constructor = ( G, $ ) ->

  #=========================================================================================================
  # RULES
  #---------------------------------------------------------------------------------------------------------
  G.line = ->
    ### TAINT we've built quite a contraption with these triple-nested `ƒ.or`s... ###
    # whisper ( value? for value in $[ 'line-parsers'] )
    # whisper $[ 'line-parsers' ].length
    return ƒ.or -> ƒ.or ( ( ƒ.or -> parser ) for parser in $[ 'line-parsers' ] )...
    # .onMatch ( match, state ) -> match
    .describe 'line'

  #---------------------------------------------------------------------------------------------------------
  # G.break.as =
  #   coffee: ( node ) ->
  #     { lhs, mark, rhs } = node
  #     lhs_result  = ƒ.as.coffee lhs
  #     rhs_result  = ƒ.as.coffee rhs
  #     # whisper lhs_result
  #     # whisper rhs_result
  #     target      = """#{lhs_result[ 'target' ]} = #{rhs_result[ 'target' ]}"""
  #     taints      = ƒ.as._collect_taints lhs_result, rhs_result
  #     # whisper taints
  #     return target: target, taints: taints


  #=========================================================================================================
  # NODES
  #---------------------------------------------------------------------------------------------------------
  # G.nodes.break = ( state, match ) ->
  #   return ƒ.new._XXX_YYY_node G.break.as, state, 'break',
  #     'keyword':   $[ 'break-keyword' ]


  #=========================================================================================================
  # TESTS
  #---------------------------------------------------------------------------------------------------------
  G.tests[ 'line: break' ] = ( test ) ->
    keyword = 'break'
    probes_and_matchers  = [
      [ "#{keyword}", {"type":"break-statement","keyword":"break"}, ]
      ]
    #.......................................................................................................
    for [ probe, matcher, ] in probes_and_matchers
      debug
      result = ƒ.new._delete_grammar_references G.line.run probe
      debug JSON.stringify result
      test.eq result, matcher

  #---------------------------------------------------------------------------------------------------------
  G.tests[ 'line: loop' ] = ( test ) ->
    keyword = 'loop'
    probes_and_matchers  = [
      [ "#{keyword}", "#{keyword}", ]
      ]
    #.......................................................................................................
    for [ probe, matcher, ] in probes_and_matchers
      debug
      result = ƒ.new._delete_grammar_references G.line.run probe
      # debug JSON.stringify result
      test.eq result, matcher

  #---------------------------------------------------------------------------------------------------------
  G.tests[ 'line: assignment' ] = ( test ) ->
    keyword = 'loop'
    probes_and_matchers  = [
      [ "x: 42", {"type":"assignment","lhs":{"type":"relative-route","raw":"x","value":[{"type":"Identifier","x-subtype":"identifier-without-sigil","name":"x"}]},"mark":":","rhs":{"type":"NUMBER/integer","raw":"42","value":42}}, ]
      ]
    #.......................................................................................................
    for [ probe, matcher, ] in probes_and_matchers
      result = ƒ.new._delete_grammar_references G.line.run probe
      # debug JSON.stringify result
      test.eq result, matcher

  #---------------------------------------------------------------------------------------------------------
  G.tests[ 'line: route' ] = ( test ) ->
    keyword = 'loop'
    probes_and_matchers  = [
      [ "x/foo/bar", {"type":"relative-route","raw":"x/foo/bar","value":[{"type":"Identifier","x-subtype":"identifier-without-sigil","name":"x"},{"type":"Identifier","x-subtype":"identifier-without-sigil","name":"foo"},{"type":"Identifier","x-subtype":"identifier-without-sigil","name":"bar"}]}, ]
      ]
    #.......................................................................................................
    for [ probe, matcher, ] in probes_and_matchers
      result = ƒ.new._delete_grammar_references G.line.run probe
      # debug JSON.stringify result
      test.eq result, matcher



############################################################################################################
ƒ.new.consolidate @

# debug '©321', ( name for name of @ )

# (require './6-name').route.run 'foo/bar'
# @assignment.run 'd: 3'
# @assignment.run 'def/ghi'
# @assignment.run '10'
# @assignment.run '"10"'
# @assignment.run ' '

