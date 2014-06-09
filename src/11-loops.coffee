



############################################################################################################
TRM                       = require 'coffeenode-trm'
rpr                       = TRM.rpr.bind TRM
badge                     = '﴾10-assignment﴿'
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
  'loop-keyword':         'loop'
  'break-keyword':        'break'
  # TEXT:                   require './2-text'
  # CHR:                    require './3-chr'
  # NUMBER:                 require './4-number'
  # ROUTE:                  require './6-route'
  INDENTATION:            require './7-indentation'


#===========================================================================================================
# CONSTRUCTOR
#-----------------------------------------------------------------------------------------------------------
@constructor = ( G, $ ) ->
  # debug '©421', ( name for name of G )
  # debug '©421', ( name for name of $ )


  #=========================================================================================================
  # RULES
  #---------------------------------------------------------------------------------------------------------
  G.break = ->
    return ƒ.or -> $[ 'break-keyword' ]
    .onMatch ( match, state ) -> G.nodes.break state
    .describe 'break'

  #---------------------------------------------------------------------------------------------------------
  G.loop_keyword = ->
    return ƒ.or -> $[ 'loop-keyword' ]
    .onMatch ( match, state ) -> G.nodes.loop state

  #---------------------------------------------------------------------------------------------------------
  G.loop_statement = ->
    # return ƒ.seq ( -> $[ 'loop-keyword' ] ), ( -> $.INDENTATION.$stage )
    return ƒ.seq ( -> $[ 'loop-keyword' ] ),
      -> $.INDENTATION.$[ 'opener' ]
      -> G.lines
      -> $.INDENTATION.$[ 'closer' ]
    .onMatch ( match, state ) -> whisper match; match #G.nodes.loop state, match
    .describe 'loop'

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
  G.nodes.break = ( state ) ->
    return ƒ.new._XXX_YYY_node G.break.as, state, 'break',
      'keyword':   $[ 'break-keyword' ]

  #---------------------------------------------------------------------------------------------------------
  G.nodes.loop = ( state ) ->
    return ƒ.new._XXX_YYY_node G.loop.as, state, 'loop',
      'keyword':   $[ 'loop-keyword' ]


  #=========================================================================================================
  # TESTS
  #---------------------------------------------------------------------------------------------------------
  G.tests[ 'break: break keyword' ] = ( test ) ->
    keyword = $[ 'break-keyword' ]
    probes_and_matchers  = [
      [ "#{keyword}", {"type":"break","keyword":"break"}, ]
      ]
    #.......................................................................................................
    for [ probe, matcher, ] in probes_and_matchers
      result = ƒ.new._delete_grammar_references G.break.run probe
      # debug JSON.stringify result
      test.eq result, matcher

  #---------------------------------------------------------------------------------------------------------
  G.tests[ 'loop: keyword and stage' ] = ( test ) ->
    keyword = $[ 'loop-keyword' ]
    probes_and_matchers  = [
      [ """
        #{keyword}
          foo
          bar
          baz
        """, {}, ]
      ]
    #.......................................................................................................
    for [ probe, matcher, ] in probes_and_matchers
      probe   = $.INDENTATION.$_as_bracketed probe
      whisper probe
      result  = ƒ.new._delete_grammar_references G.loop_statement.run probe
      debug JSON.stringify result
      # test.eq result, matcher

  #---------------------------------------------------------------------------------------------------------
  G.tests[ 'loop: refuses to parse dedent' ] = ( test ) ->
    keyword = $[ 'loop-keyword' ]
    probes_and_matchers  = [
      [ """
        #{keyword}
          foo
          bar
          baz
        bling
        """, {}, ]
      ]
    #.......................................................................................................
    for [ probe, matcher, ] in probes_and_matchers
      result = ƒ.new._delete_grammar_references G.loop_statement.run probe
      debug JSON.stringify result
      # test.throws result, /xxxxxx/




############################################################################################################
ƒ.new.consolidate @

# debug '©321', ( name for name of @ )

# (require './6-name').route.run 'foo/bar'
# @assignment.run 'd: 3'
# @assignment.run 'def/ghi'
# @assignment.run '10'
# @assignment.run '"10"'
# @assignment.run ' '

