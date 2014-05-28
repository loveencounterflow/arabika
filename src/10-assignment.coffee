



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
        null
      #   switch subtype = node[ 'x-subtype' ]
      #     #.................................................................................................
      #     # solution 3
      #     when 'relative-route', 'absolute-route'
      #       ### TAINT how to identify the current scope? ###
      #       root_name = if subtype is 'relative-route' then 'scope' else 'global'
      #       crumbs  = node[ 'value' ]
      #       names   = []
      #       for crumb, idx in crumbs
      #         crumb_type    = crumb[ 'type' ]
      #         crumb_subtype = crumb[ 'x-subtype' ]
      #         unless crumb_type is 'Identifier'
      #           throw new Error "unknown crumb type #{rpr crumb_type}"
      #         names.push crumb[ 'name' ]
      #       names = ( "[ #{rpr name} ]" for name in names ).join ''
      #       source = """$FM[ #{rpr root_name} ]#{names}"""
      #       return source
      #     else
      #       throw new Error "unknown node subtype #{rpr subtype}"
      #.......................................................................................................
      else
        throw new Error "unknown node type #{rpr type}"

  #-----------------------------------------------------------------------------------------------------------
  RR.js = ( node ) ->
    COFFEE        = require 'coffee-script'
    source_coffee = G.as.coffee node
    return COFFEE.compile source_coffee, bare: yes

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
      debug JSON.stringify result
      test.eq result, matcher

  #---------------------------------------------------------------------------------------------------------
  '$assignment: accepts assignment with name': ( test ) ->
    G       = @
    $       = G.$
    joiner  = $[ 'crumb/joiner' ]
    probes_and_matchers  = [
      [ "yet/another/route: 42", {"type":"Literal","x-subtype":"assignment","x-mark":":","lhs":{"type":"Literal","x-subtype":"relative-route","raw":"abc","value":[{"type":"Identifier","x-subtype":"identifier-without-sigil","name":"abc"}]},"rhs":{"type":"Literal","x-subtype":"integer","raw":"42","value":42}}, ]
      [ "/chinese/𠀁: '42'", {"type":"Literal","x-subtype":"assignment","lhs":{"type":"Literal","x-subtype":"relative-route","raw":"𠀁","value":[{"type":"Identifier","x-subtype":"identifier-without-sigil","name":"𠀁"}]},"x-mark":":","rhs":{"type":"Literal","x-subtype":"text","raw":"'42'","value":"42"}}, ]
      ]
    #.......................................................................................................
    for [ probe, matcher, ] in probes_and_matchers
      result = ƒ.new._delete_grammar_references G.assignment.run probe
      debug JSON.stringify result
      # test.eq result, matcher

