



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
  # debug '©421', ( name for name of G )
  # debug '©421', ( name for name of $ )


  #=========================================================================================================
  # RULES
  #---------------------------------------------------------------------------------------------------------
  G.line = ->
    return ƒ.or -> ƒ.or $[ 'line-parsers' ]...
    # .onMatch ( match, state ) -> match
    .describe 'line'

  # #---------------------------------------------------------------------------------------------------------
  # G.loop_keyword = ->
  #   return ƒ.or -> $[ 'loop-keyword' ]
  #   .onMatch ( match, state ) -> G.nodes.loop state

  # #---------------------------------------------------------------------------------------------------------
  # G.loop_statement = ->
  #   # return ƒ.seq ( -> $[ 'loop-keyword' ] ), ( -> $.INDENTATION.$stage )
  #   return ƒ.seq ( -> $.INDENTATION.$step ), ( $.INDENTATION.$chunk )
  #   .onMatch ( match, state ) -> G.nodes.loop state, match[ 0 ], match[ 1 ]
  #   .describe 'loop'

  # #---------------------------------------------------------------------------------------------------------
  # G.loop = ->
  #   lws_before = if $[ 'needs-lws-before' ] then ( -> $.CHR.ilws ) else ƒ.drop ''
  #   lws_after  = if $[ 'needs-lws-after'  ] then ( -> $.CHR.ilws ) else ƒ.drop ''
  #   return ƒ.seq ( -> $.ROUTE.route ), lws_before, $[ 'mark' ], lws_after, ( -> G._TEMPORARY_expression )
  #   .onMatch ( match, state ) -> G.nodes.assignment state, match...
  #   .describe 'assignment'

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
  # G.tests[ 'break: break keyword' ] = ( test ) ->
  #   keyword = $[ 'break-keyword' ]
  #   probes_and_matchers  = [
  #     [ "#{keyword}", {"type":"break","keyword":"break"}, ]
  #     ]
  #   #.......................................................................................................
  #   for [ probe, matcher, ] in probes_and_matchers
  #     result = ƒ.new._delete_grammar_references G.break.run probe
  #     # debug JSON.stringify result
  #     test.eq result, matcher



############################################################################################################
ƒ.new.consolidate @

# debug '©321', ( name for name of @ )

# (require './6-name').route.run 'foo/bar'
# @assignment.run 'd: 3'
# @assignment.run 'def/ghi'
# @assignment.run '10'
# @assignment.run '"10"'
# @assignment.run ' '

