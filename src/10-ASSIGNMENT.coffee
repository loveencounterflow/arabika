



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
  'mark':                 ':'
  'needs-lws-before':     no
  'needs-lws-after':      yes
  TEXT:                   require './2-text'
  CHR:                    require './3-chr'
  NUMBER:                 require './4-number'
  ROUTE:                  require './6-route'


#===========================================================================================================
# CONSTRUCTOR
#-----------------------------------------------------------------------------------------------------------
@constructor = ( G, $ ) ->


  #=========================================================================================================
  # RULES
  #---------------------------------------------------------------------------------------------------------
  G._TEMPORARY_expression = ->
    ### TAINT placeholder method for a more complete version of what contitutes an expression ###
    return ƒ.or ( -> $.NUMBER.integer ), ( -> $.TEXT.literal ), ( -> $.ROUTE.route )

  #---------------------------------------------------------------------------------------------------------
  G.assignment = ->
    lws_before = if $[ 'needs-lws-before' ] then ( -> $.CHR.ilws ) else ƒ.drop ''
    lws_after  = if $[ 'needs-lws-after'  ] then ( -> $.CHR.ilws ) else ƒ.drop ''
    return ƒ.seq ( -> $.ROUTE.route ), lws_before, $[ 'mark' ], lws_after, ( -> G._TEMPORARY_expression )
    .onMatch ( match, state ) -> G.nodes.assignment state, match...
    .describe 'assignment'

  #---------------------------------------------------------------------------------------------------------
  G.assignment.as =
    coffee: ( node ) ->
      { lhs, mark, rhs } = node
      lhs_result  = ƒ.as.coffee lhs
      rhs_result  = ƒ.as.coffee rhs
      # whisper lhs_result
      # whisper rhs_result
      target      = """#{lhs_result[ 'target' ]} = #{rhs_result[ 'target' ]}"""
      taints      = ƒ.as._collect_taints lhs_result, rhs_result
      # whisper taints
      return target: target, taints: taints


  #=========================================================================================================
  # NODES
  #---------------------------------------------------------------------------------------------------------
  G.nodes.assignment = ( state, lhs, mark, rhs ) ->
    return ƒ.new._XXX_YYY_node G.assignment.as, state, 'assignment',
      'lhs':    lhs
      'mark':   mark
      'rhs':    rhs


  #=========================================================================================================
  # TESTS
  #---------------------------------------------------------------------------------------------------------
  G.tests[ 'assignment: accepts assignment with name' ] = ( test ) ->
    joiner  = $.ROUTE.$[ 'crumb/joiner' ]
    mark    = $[ 'mark' ]
    probes_and_matchers  = [
      [ "abc#{mark} 42", {"type":"assignment","lhs":{"type":"relative-route","raw":"abc","value":[{"type":"Identifier","x-subtype":"identifier-without-sigil","name":"abc"}]},"mark":":","rhs":{"type":"NUMBER/integer","raw":"42","value":42}}, ]
      [ "𠀁#{mark} '42'", {"type":"assignment","lhs":{"type":"relative-route","raw":"𠀁","value":[{"type":"Identifier","x-subtype":"identifier-without-sigil","name":"𠀁"}]},"mark":":","rhs":{"type":"TEXT/literal","value":"42"}}, ]
      ]
    #.......................................................................................................
    for [ probe, matcher, ] in probes_and_matchers
      # try
      #   G.assignment.run probe
      # catch error
      #   debug error[ 'stack' ]
      result = ƒ.new._delete_grammar_references G.assignment.run probe
      # debug JSON.stringify result
      test.eq result, matcher


  #---------------------------------------------------------------------------------------------------------
  G.tests[ 'assignment: accepts assignment with route' ] = ( test ) ->
    joiner  = $.ROUTE.$[ 'crumb/joiner' ]
    mark    = $[ 'mark' ]
    probes_and_matchers  = [
      [ "yet#{joiner}another#{joiner}route#{mark} 42", {"type":"assignment","lhs":{"type":"relative-route","raw":"yet/another/route","value":[{"type":"Identifier","x-subtype":"identifier-without-sigil","name":"yet"},{"type":"Identifier","x-subtype":"identifier-without-sigil","name":"another"},{"type":"Identifier","x-subtype":"identifier-without-sigil","name":"route"}]},"mark":":","rhs":{"type":"NUMBER/integer","raw":"42","value":42}}, ]
      [ "#{joiner}chinese#{joiner}𠀁#{mark} '42'", {"type":"assignment","lhs":{"type":"absolute-route","raw":"/chinese/𠀁","value":[{"type":"Identifier","x-subtype":"identifier-without-sigil","name":"chinese"},{"type":"Identifier","x-subtype":"identifier-without-sigil","name":"𠀁"}]},"mark":":","rhs":{"type":"TEXT/literal","value":"42"}}, ]
      ]
    #.......................................................................................................
    for [ probe, matcher, ] in probes_and_matchers
      # debug '©392', probe
      result = ƒ.new._delete_grammar_references G.assignment.run probe
      # debug JSON.stringify result
      test.eq result, matcher

  #---------------------------------------------------------------------------------------------------------
  G.tests[ 'as.coffee: render assignment as CoffeeScript' ] = ( test ) ->
    joiner  = $.ROUTE.$[ 'crumb/joiner' ]
    mark    = $[ 'mark' ]
    # debug ( rpr joiner ), ( rpr mark )
    probes_and_matchers  = [
      [ "yet#{joiner}another#{joiner}route#{mark} 42", "$FM[ 'scope' ][ 'yet' ][ 'another' ][ 'route' ] = 42", ]
      [ "#{joiner}chinese#{joiner}𠀁#{mark} 'some text'", "$FM[ 'global' ][ 'chinese' ][ '𠀁' ] = 'some text'", ]
      ]
    #.......................................................................................................
    for [ probe, matcher, ] in probes_and_matchers
      node        = G.assignment.run probe
      # debug JSON.stringify ƒ.new._delete_grammar_references G.assignment.run probe
      translation = G.assignment.as.coffee node
      result      = ƒ.as.coffee.target translation
      # debug JSON.stringify result
      # debug JSON.stringify result
      # debug '\n' + result
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

