



############################################################################################################
TRM                       = require 'coffeenode-trm'
rpr                       = TRM.rpr.bind TRM
badge                     = '﴾3-chr﴿'
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
@$new                     = ƒ.new.new @
BNP                       = require 'coffeenode-bitsnpieces'
TEXT                      = require './2-text'
CHR                       = require './3-chr'
NUMBER                    = require './4-number'
# XRE                       = require './9-xre'
NAME                      = require './6-name'

#-----------------------------------------------------------------------------------------------------------
@$ =
  'mark':                 ':'
  'needs-ilws-before':    no
  'needs-ilws-after':     yes


#===========================================================================================================
#
#-----------------------------------------------------------------------------------------------------------
@$new.expression = ( G, $ ) ->
  ### TAINT placeholder method for a more complete version of what contitutes an expression ###
  R = ƒ.or NUMBER.integer, TEXT.literal, NAME.route

#-----------------------------------------------------------------------------------------------------------
@$new.assignment = ( G, $ ) ->
  if $[ 'needs-ilws-before' ]
    R = ƒ.seq NAME.route, CHR.ilws, $[ 'mark' ], CHR.ilws, ( -> G.expression )
  else
    R = ƒ.seq NAME.route,           $[ 'mark' ], CHR.ilws, ( -> G.expression )
  R = R.onMatch ( match ) -> G.new_node.assignment match...
  R = R.describe 'assignment'
  return R

#-----------------------------------------------------------------------------------------------------------
@$new.assignment.as = ( G, $ ) ->
  return coffee: ( node ) ->

#===========================================================================================================
# NODES
#-----------------------------------------------------------------------------------------------------------
@$new.new_node = ( G, $ ) ->
  RR = {}

  #---------------------------------------------------------------------------------------------------------
  RR.assignment = ( lhs, mark, rhs ) ->
      R                 = ƒ.new._XXX_node G, 'Literal', 'assignment'
      R[ 'lhs'        ] = lhs
      R[ 'x-mark'     ] = mark
      R[ 'rhs'        ] = rhs
      return R

  #.........................................................................................................
  return RR

#===========================================================================================================
# TRANSLATORS
#-----------------------------------------------------------------------------------------------------------
@$new.as = ( G, $ ) ->
  RR = {}

  #-----------------------------------------------------------------------------------------------------------
  RR.coffee = ( node ) ->
    #.........................................................................................................
    switch type = node[ 'type' ]
      #.......................................................................................................
      when 'Literal'
        switch subtype = node[ 'x-subtype' ]
          #.................................................................................................
          when 'assignment'
            { lhs, 'x-mark': mark, rhs } = node
            lhs_result  = ƒ.as.coffee lhs
            rhs_result  = ƒ.as.coffee rhs
            # whisper lhs_result
            # whisper rhs_result
            target      = """#{lhs_result[ 'target' ]} = #{rhs_result[ 'target' ]}"""
            taints      = ƒ.as._collect_taints lhs_result, rhs_result
            whisper taints
            return target: target, taints: taints
          else
            throw new Error "unknown node subtype #{rpr subtype}"
      #.......................................................................................................
      else
        throw new Error "unknown node type #{rpr type}"

  # #-----------------------------------------------------------------------------------------------------------
  # RR.js = ( node ) ->
  #   COFFEE        = require 'coffee-script'
  #   source_coffee = G.as.coffee node
  #   return COFFEE.compile source_coffee, bare: yes

  #-----------------------------------------------------------------------------------------------------------
  ### TAINT `standard` is not a good name for this method ###
  RR.standard = ( node ) ->
    ESPRIMA   = require 'esprima'
    source_js = G.as.js node
    return ESPRIMA.parse source_js
  #.........................................................................................................
  return RR


#===========================================================================================================
# APPLY NEW TO MODULE
#-----------------------------------------------------------------------------------------------------------
### Run `@$new` to make `@` (`this`) an instance of this grammar with default options: ###
@$new @, null


#===========================================================================================================
@$TESTS =
#-----------------------------------------------------------------------------------------------------------

  #=========================================================================================================
  # NAMES
  #---------------------------------------------------------------------------------------------------------
  '$assignment: accepts assignment with name': ( test ) ->
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
  '$assignment: accepts assignment with route': ( test ) ->
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
  'as.coffee: render assignment as CoffeeScript': ( test ) ->
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

