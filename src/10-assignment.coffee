



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
TEXT                      = require './2-text'
CHR                       = require './3-chr'
NUMBER                    = require './4-number'
# XRE                       = require './9-xre'
NAME                      = require './6-name'



#===========================================================================================================
#
#-----------------------------------------------------------------------------------------------------------
@new_grammar = ( G, $ ) ->
  RR =
    nodes: {}
    tests: {}
    #.......................................................................................................
    options:
      'mark':                 ':'
      'needs-ilws-before':    no
      'needs-ilws-after':     yes


  #=========================================================================================================
  # RULES
  #---------------------------------------------------------------------------------------------------------
  RR.expression = ->
    ### TAINT placeholder method for a more complete version of what contitutes an expression ###
    R = ƒ.or NUMBER.integer, TEXT.literal, NAME.route

  #---------------------------------------------------------------------------------------------------------
  RR.assignment = ->
    if $[ 'needs-ilws-before' ]
      R = ƒ.seq NAME.route, CHR.ilws, $[ 'mark' ], CHR.ilws, ( -> G.expression )
    else
      R = ƒ.seq NAME.route,           $[ 'mark' ], CHR.ilws, ( -> G.expression )
    R = R.onMatch ( match ) -> G.nodes.assignment match...
    R = R.describe 'assignment'
    return R

  #.........................................................................................................
  return RR

  #=========================================================================================================
  # NODES
  #---------------------------------------------------------------------------------------------------------
  RR.nodes.assignment = ( lhs, mark, rhs ) ->
      R                 = ƒ.new._XXX_node G, 'Literal', 'assignment'
      R[ 'lhs'        ] = lhs
      R[ 'mark'       ] = mark
      R[ 'rhs'        ] = rhs
      return R

  #---------------------------------------------------------------------------------------------------------
  RR.nodes.assignment.as =
    coffee: ( node ) ->
      { lhs, 'x-mark': mark, rhs } = node
      lhs_result  = ƒ.as.coffee lhs
      rhs_result  = ƒ.as.coffee rhs
      # whisper lhs_result
      # whisper rhs_result
      target      = """#{lhs_result[ 'target' ]} = #{rhs_result[ 'target' ]}"""
      taints      = ƒ.as._collect_taints lhs_result, rhs_result
      whisper taints
      return target: target, taints: taints

  #.........................................................................................................
  return RR


  #=========================================================================================================
  # TESTS
  #---------------------------------------------------------------------------------------------------------
  RR.tests[ '$assignment: accepts assignment with name' ] = ( test ) ->
    G       = @
    $       = G.$
    joiner  = $[ 'crumb/joiner' ]
    probes_and_matchers  = [
      [ "abc: 42", {"type":"Literal","x-subtype":"assignment","x-mark":":","lhs":{"type":"Literal","x-subtype":"relative-route","raw":"abc","value":[{"type":"Identifier","x-subtype":"identifier-without-sigil","name":"abc"}]},"rhs":{"type":"Literal","x-subtype":"integer","raw":"42","value":42}}, ]
      [ "𠀁: '42'", {"type":"Literal","x-subtype":"assignment","lhs":{"type":"Literal","x-subtype":"relative-route","raw":"𠀁","value":[{"type":"Identifier","x-subtype":"identifier-without-sigil","name":"𠀁"}]},"x-mark":":","rhs":{"type":"Literal","x-subtype":"text","raw":"'42'","value":"42"}}, ]
      ]
    #.......................................................................................................
    for [ probe, matcher, ] in probes_and_matchers
      result = ƒ.new._delete_grammar_references G.assignment.run probe
      # debug JSON.stringify result
      test.eq result, matcher

  #---------------------------------------------------------------------------------------------------------
  RR.tests[ '$assignment: accepts assignment with route' ] = ( test ) ->
    G       = @
    $       = G.$
    joiner  = $[ 'crumb/joiner' ]
    probes_and_matchers  = [
      [ "yet#{joiner}another#{joiner}route: 42", {"type":"Literal","x-subtype":"assignment","x-mark":":","lhs":{"type":"Literal","x-subtype":"relative-route","raw":"abc","value":[{"type":"Identifier","x-subtype":"identifier-without-sigil","name":"abc"}]},"rhs":{"type":"Literal","x-subtype":"integer","raw":"42","value":42}}, ]
      [ "#{joiner}chinese#{joiner}𠀁: '42'", {"type":"Literal","x-subtype":"assignment","lhs":{"type":"Literal","x-subtype":"relative-route","raw":"𠀁","value":[{"type":"Identifier","x-subtype":"identifier-without-sigil","name":"𠀁"}]},"x-mark":":","rhs":{"type":"Literal","x-subtype":"text","raw":"'42'","value":"42"}}, ]
      ]
    #.......................................................................................................
    for [ probe, matcher, ] in probes_and_matchers
      result = ƒ.new._delete_grammar_references G.assignment.run probe
      # debug JSON.stringify result#, null, '  '
      # test.eq result, matcher

  #---------------------------------------------------------------------------------------------------------
  RR.tests[ 'as.coffee: render assignment as CoffeeScript' ] = ( test ) ->
    G       = @
    $       = G.$
    joiner  = $[ 'crumb/joiner' ]
    probes_and_matchers  = [
      [ "yet/another/route: 42", {"type":"Literal","x-subtype":"assignment","x-mark":":","lhs":{"type":"Literal","x-subtype":"relative-route","raw":"abc","value":[{"type":"Identifier","x-subtype":"identifier-without-sigil","name":"abc"}]},"rhs":{"type":"Literal","x-subtype":"integer","raw":"42","value":42}}, ]
      [ "/chinese/𠀁: 'some text'", {"type":"Literal","x-subtype":"assignment","lhs":{"type":"Literal","x-subtype":"relative-route","raw":"𠀁","value":[{"type":"Identifier","x-subtype":"identifier-without-sigil","name":"𠀁"}]},"x-mark":":","rhs":{"type":"Literal","x-subtype":"text","raw":"'42'","value":"42"}}, ]
      ]
    #.......................................................................................................
    for [ probe, matcher, ] in probes_and_matchers
      node        = G.assignment.run probe
      translation = G.as.coffee node
      result      = ƒ.as.coffee.target translation
      # debug JSON.stringify result
      debug '\n' + result
    #   # test.eq result, matcher


############################################################################################################
ƒ._XXX_new_grammar @





