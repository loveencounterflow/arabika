




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
CHR                       = require './3-chr'
XRE                       = require './9-xre'

# show_matches = yes
# show_matches = no
# #-----------------------------------------------------------------------------------------------------------
# ### TAINT this or similar helper to be part of FlowMatic ###
# show = ( name, state ) ->
#   if show_matches
#     whisper "matching: #{name}", rpr state[ 'internal' ][ 'text' ][ state.pos() ... state.endpos() ]
#   return null

#-----------------------------------------------------------------------------------------------------------
@$ =

  #---------------------------------------------------------------------------------------------------------
  ### Names: ###

  #.........................................................................................................
  ### Leading and trailing characters in names (excluding sigils): ###
  'identifier/first-chr':     XRE '\\p{L}'
  'identifier/trailing-chrs': XRE '(?:-|\\p{L}|\\d)*'

  #---------------------------------------------------------------------------------------------------------
  ### Character used to form URL-like routes out of crumbs: ###
  'crumb/joiner':           '/'
  'crumb/this-scope':       '.'
  'crumb/parent-scope':     '..'


  #---------------------------------------------------------------------------------------------------------
  ### Sigils: ###

  #.........................................................................................................
  ### Sigils may start and classify simple names: ###
  'sigils':
    # '$':        'special' # used for interpolation!
    # '°':        ''
    # '^':        ''
    # '@':        'attribute' # ??? used for `this`
    '~':        'system'
    '.':        'hidden'
    '_':        'private'
    '%':        'cached'
    '!':        'attention'


  #.........................................................................................................
  ### Marks are like sigils, but with slightly different semantics. ###
  'symbol/mark':  ':'


#===========================================================================================================
# NAMES
#-----------------------------------------------------------------------------------------------------------
@$new.$identifier_first_chr = ( G, $ ) ->
  R = ƒ.regex $[ 'identifier/first-chr' ]
  R = R.onMatch ( match ) -> match[ 0 ]
  R = R.describe 'first character of name'
  return R

#-----------------------------------------------------------------------------------------------------------
@$new.$identifier_trailing_chrs = ( G, $ ) ->
  R = ƒ.regex $[ 'identifier/trailing-chrs' ]
  R = R.onMatch ( match ) -> match[ 0 ]
  R = R.describe 'trailing characters of name'
  return R

#-----------------------------------------------------------------------------------------------------------
@$new.$sigil = ( G, $ ) ->
  sigils = ( XRE.$esc key for key of $[ 'sigils'] ).join ''
  R = ƒ.regex XRE "[#{sigils}]"
  R = R.onMatch ( match, state ) -> match[ 0 ]
  R = R.describe 'sigil'
  return R

#-----------------------------------------------------------------------------------------------------------
@$new.identifier_with_sigil = ( G, $ ) ->
  R = ƒ.seq ( G.$sigil ), ( -> G.$identifier_first_chr ), ( -> G.$identifier_trailing_chrs )
  R = R.onMatch ( match, state ) ->
    # show 'name', state
    G.new_node.identifier_with_sigil match[ 0 ], match[ 1 ] + match[ 2 ]
  R = R.describe 'identifier-with-sigil'
  return R

#-----------------------------------------------------------------------------------------------------------
@$new.identifier_without_sigil = ( G, $ ) ->
  R = ƒ.seq ( -> G.$identifier_first_chr ), ( -> G.$identifier_trailing_chrs )
  R = R.onMatch ( match, state ) ->
    # show '$name', state
    G.new_node.identifier_without_sigil match[ 0 ] + match[ 1 ]
  R = R.describe 'name-without-sigil'
  return R

#-----------------------------------------------------------------------------------------------------------
@$new.identifier = ( G, $ ) ->
  R = ƒ.or ( -> G.identifier_with_sigil ), ( -> G.identifier_without_sigil )
  R = R.describe 'identifier'
  return R

#-----------------------------------------------------------------------------------------------------------
# @$new.$crumb = ( G, $ ) ->
  # R = ƒ.seq ( ƒ.optional -> G.$sigil ), ( -> G.$identifier_first_chr ), ( -> G.$identifier_trailing_chrs )
  # R = R.onMatch ( match ) -> match.join ''
  # R = R.describe 'name'
  # return R


#===========================================================================================================
# ROUTES
#-----------------------------------------------------------------------------------------------------------
@$new.relative_route = ( G, $ ) ->
  R = ƒ.repeatSeparated ( -> G.identifier ), $[ 'crumb/joiner' ]
  R = R.onMatch ( match ) ->
    raw = ( identifier[ 'name' ] for identifier in match ).join $[ 'crumb/joiner' ]
    G.new_node.relative_route raw, match
  R = R.describe 'relative-route'
  return R

#-----------------------------------------------------------------------------------------------------------
@$new.absolute_route = ( G, $ ) ->
  R = ƒ.seq $[ 'crumb/joiner' ], ( -> G.relative_route )
  R = R.onMatch ( match ) ->
    [ slash, route, ]     = match
    route[ 'raw' ]        = $[ 'crumb/joiner' ] + route[ 'raw' ]
    route[ 'x-subtype' ]  = 'absolute-route'
    return route
  R = R.describe 'absolute-route'
  return R

#-----------------------------------------------------------------------------------------------------------
@$new.route = ( G, $ ) ->
  R = ƒ.or ( -> G.absolute_route ), ( -> G.relative_route )
  R = R.describe 'route'
  return R


#===========================================================================================================
# SYMBOLS
#-----------------------------------------------------------------------------------------------------------
@$new.symbol = ( G, $ ) ->
  R = ƒ.seq $[ 'symbol/mark' ], ( -> G.identifier )
  R = R.onMatch ( match ) ->
    mark        = match[ 0 ]
    identifier  = match[ 1 ][ 'name' ]
    return G.new_node.symbol mark, mark + identifier, identifier
  return R


#===========================================================================================================
# NODES
#-----------------------------------------------------------------------------------------------------------
@$new.new_node = ( G, $ ) ->
  RR = {}

  #---------------------------------------------------------------------------------------------------------
  RR.symbol = ( mark, raw, value ) ->
      R                 = ƒ.new._XXX_node G, 'Literal', 'symbol'
      R[ 'x-mark'     ] = mark
      R[ 'raw'        ] = raw
      R[ 'value'      ] = value
      return R

  #---------------------------------------------------------------------------------------------------------
  RR.relative_route = ( raw, value ) ->
      R                 = ƒ.new._XXX_node G, 'Literal', 'relative-route'
      R[ 'raw'        ] = raw
      R[ 'value'      ] = value
      return R

  #---------------------------------------------------------------------------------------------------------
  RR.identifier_with_sigil = ( sigil, name ) ->
      R                 = ƒ.new._XXX_node G, 'Identifier', 'identifier-with-sigil'
      R[ 'x-sigil'    ] = sigil
      R[ 'name'       ] = sigil + name
      return R

  #---------------------------------------------------------------------------------------------------------
  RR.identifier_without_sigil = ( name ) ->
      R                 = ƒ.new._XXX_node G, 'Identifier', 'identifier-without-sigil'
      R[ 'name'       ] = name
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
          # solution 3
          when 'relative-route', 'absolute-route'
            ### TAINT how to identify the current scope? ###
            root_name = if subtype is 'relative-route' then 'scope' else 'global'
            crumbs  = node[ 'value' ]
            names   = []
            for crumb, idx in crumbs
              crumb_type    = crumb[ 'type' ]
              crumb_subtype = crumb[ 'x-subtype' ]
              unless crumb_type is 'Identifier'
                throw new Error "unknown crumb type #{rpr crumb_type}"
              names.push crumb[ 'name' ]
            names   = ( "[ #{rpr name} ]" for name in names ).join ''
            target  = """$FM[ #{rpr root_name} ]#{names}"""
            return target: target
          else
            throw new Error "unknown node subtype #{rpr subtype}"
      #.......................................................................................................
      else
        throw new Error "unknown node type #{rpr type}"
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
  '$identifier_first_chr: matches first character of names': ( test ) ->
    G = @
    $ = G.$
    probes = [ 'a', 'A', '𠀁',  ]
    for probe in probes
      result = G.$identifier_first_chr.run probe
      test.eq result, probe

  #---------------------------------------------------------------------------------------------------------
  '$identifier_trailing_chrs: matches trailing characters of names': ( test ) ->
    G = @
    $ = G.$
    probes = [ 'abc', 'abc-def', 'abc-def-45',  ]
    for probe in probes
      result = G.$identifier_trailing_chrs.run probe
      # whisper probe
      test.eq result, probe

  #---------------------------------------------------------------------------------------------------------
  'identifier: matches identifiers': ( test ) ->
    G = @
    $ = G.$
    probes_and_matchers = [
      [ 'n', {"type":"Identifier","x-subtype":"identifier-without-sigil","name":"n"} ]
      [ 'n0', {"type":"Identifier","x-subtype":"identifier-without-sigil","name":"n0"} ]
      [ 'readable-names', {"type":"Identifier","x-subtype":"identifier-without-sigil","name":"readable-names"} ]
      [ 'foo-32', {"type":"Identifier","x-subtype":"identifier-without-sigil","name":"foo-32"} ]
      ]
    for [ probe, matcher, ] in probes_and_matchers
      result = ƒ.new._delete_grammar_references G.identifier.run probe
      # debug probe, JSON.stringify G.identifier.run probe
      test.eq result, matcher

  #---------------------------------------------------------------------------------------------------------
  'identifier: matches identifiers with sigils': ( test ) ->
    G = @
    $ = G.$
    probes_and_matchers = [
      [ '~n', {"type":"Identifier","x-subtype":"identifier-with-sigil","x-sigil":"~","name":"~n"} ]
      [ '.n0', {"type":"Identifier","x-subtype":"identifier-with-sigil","x-sigil":".","name":".n0"} ]
      [ '_readable-names', {"type":"Identifier","x-subtype":"identifier-with-sigil","x-sigil":"_","name":"_readable-names"} ]
      [ '%foo-32', {"type":"Identifier","x-subtype":"identifier-with-sigil","x-sigil":"%","name":"%foo-32"} ]
      [ '!foo-32', {"type":"Identifier","x-subtype":"identifier-with-sigil","x-sigil":"!","name":"!foo-32"} ]
      ]
    for [ probe, matcher, ] in probes_and_matchers
      result = ƒ.new._delete_grammar_references G.identifier.run probe
      # debug probe, JSON.stringify G.identifier.run probe
      test.eq result, matcher

  #---------------------------------------------------------------------------------------------------------
  'identifier: rejects non-identifiers': ( test ) ->
    G = @
    $ = G.$
    probes = [ '034', '-/-', '()', '؟?', ]
    for probe in probes
      # whisper probe
      test.throws ( => G.identifier.run probe ), /Expected/


  #=========================================================================================================
  # SYMBOLS
  #---------------------------------------------------------------------------------------------------------
  '$[ "symbol/mark" ]: is a single character': ( test ) ->
    ### TAINT test will fail for Unicode 32bit code points ###
    G = @
    $ = G.$
    TYPES = require 'coffeenode-types'
    test.ok TYPES.isa_text $[ 'symbol/mark' ]
    test.ok $[ 'symbol/mark' ].length is 1

  #---------------------------------------------------------------------------------------------------------
  'symbol: accepts sequences of symbol/mark, name chrs': ( test ) ->
    G       = @
    $       = G.$
    mark    = @$[ 'symbol/mark' ]
    probes_and_matchers = [
      [ "#{mark}x", {"type":"Literal","x-subtype":"symbol","x-mark":":","raw":":x","value":"x"}, ]
      [ "#{mark}foo", {"type":"Literal","x-subtype":"symbol","x-mark":":","raw":":foo","value":"foo"}, ]
      [ "#{mark}Supercalifragilisticexpialidocious", {"type":"Literal","x-subtype":"symbol","x-mark":":","raw":":Supercalifragilisticexpialidocious","value":"Supercalifragilisticexpialidocious"}, ]
    ]
    #.......................................................................................................
    for [ probe, matcher, ] in probes_and_matchers
      result = ƒ.new._delete_grammar_references G.symbol.run probe
      # debug JSON.stringify G.symbol.run probe
      test.eq result, matcher

  #---------------------------------------------------------------------------------------------------------
  'symbol: rejects names with whitespace': ( test ) ->
    G       = @
    $       = G.$
    mark    = @$[ 'symbol/mark' ]
    probes  = [
      "#{mark}xxx xxx"
      "#{mark}foo\tbar"
      "#{mark}Super/cali/fragilistic/expialidocious" ]
    #.......................................................................................................
    for probe in probes
      test.throws ( -> G.symbol.run probe ), /Expected/


  #=========================================================================================================
  # ROUTES
  #---------------------------------------------------------------------------------------------------------
  'route: accepts single name': ( test ) ->
    ### TAINT test will fail for Unicode 32bit code points ###
    G = @
    $ = G.$
    probes_and_matchers  = [
      [ "abc",      {"type":"Literal","x-subtype":"relative-route","raw":"abc","value":[{"type":"Identifier","x-subtype":"identifier-without-sigil","name":"abc"}]} ]
      [ "!國畫很美",     {"type":"Literal","x-subtype":"relative-route","raw":"!國畫很美","value":[{"type":"Identifier","x-subtype":"identifier-with-sigil","x-sigil":"!","name":"!國畫很美"}]} ]
      ]
    #.......................................................................................................
    for [ probe, matcher, ] in probes_and_matchers
      result = ƒ.new._delete_grammar_references G.route.run probe
      # debug JSON.stringify G.route.run probe
      test.eq result, matcher

  #---------------------------------------------------------------------------------------------------------
  'route: accepts crumbs separated by crumb joiners': ( test ) ->
    ### TAINT test will fail for Unicode 32bit code points ###
    G       = @
    $       = G.$
    joiner  = $[ 'crumb/joiner' ]
    probes_and_matchers  = [
      [ "abc#{joiner}def", {"type":"Literal","x-subtype":"relative-route","raw":"abc/def","value":[{"type":"Identifier","x-subtype":"identifier-without-sigil","name":"abc"},{"type":"Identifier","x-subtype":"identifier-without-sigil","name":"def"}]}, ]
      [ "foo#{joiner}bar#{joiner}baz", {"type":"Literal","x-subtype":"relative-route","raw":"foo/bar","value":[{"type":"Identifier","x-subtype":"identifier-without-sigil","name":"foo"},{"type":"Identifier","x-subtype":"identifier-without-sigil","name":"bar"}]}, ]
      [ "foo#{joiner}bar", {"type":"Literal","x-subtype":"relative-route","raw":"foo/bar","value":[{"type":"Identifier","x-subtype":"identifier-without-sigil","name":"foo"},{"type":"Identifier","x-subtype":"identifier-without-sigil","name":"bar"}]}, ]
      [ "Super#{joiner}cali#{joiner}fragilistic#{joiner}expialidocious", {"type":"Literal","x-subtype":"relative-route","raw":"Super/cali/fragilistic/expialidocious","value":[{"type":"Identifier","x-subtype":"identifier-without-sigil","name":"Super"},{"type":"Identifier","x-subtype":"identifier-without-sigil","name":"cali"},{"type":"Identifier","x-subtype":"identifier-without-sigil","name":"fragilistic"},{"type":"Identifier","x-subtype":"identifier-without-sigil","name":"expialidocious"}]}, ]
      [ "#{joiner}abc#{joiner}def", {"type":"Literal","x-subtype":"absolute-route","raw":"/abc/def","value":[{"type":"Identifier","x-subtype":"identifier-without-sigil","name":"abc"},{"type":"Identifier","x-subtype":"identifier-without-sigil","name":"def"}]}, ]
      ]
    #.......................................................................................................
    for [ probe, matcher, ] in probes_and_matchers
      result = ƒ.new._delete_grammar_references G.route.run probe
      debug result
      test.eq result, matcher

  #---------------------------------------------------------------------------------------------------------
  'route: accepts leading slash': ( test ) ->
    ### TAINT test will fail for Unicode 32bit code points ###
    G       = @
    $       = G.$
    joiner  = $[ 'crumb/joiner' ]
    probes_and_matchers  = [
      [ "#{joiner}abc#{joiner}def", {"type":"Literal","x-subtype":"absolute-route","raw":"/abc/def","value":[{"type":"Identifier","x-subtype":"identifier-without-sigil","name":"abc"},{"type":"Identifier","x-subtype":"identifier-without-sigil","name":"def"}]}, ]
      [ "#{joiner}foo#{joiner}bar", {"type":"Literal","x-subtype":"absolute-route","raw":"/foo/bar","value":[{"type":"Identifier","x-subtype":"identifier-without-sigil","name":"foo"},{"type":"Identifier","x-subtype":"identifier-without-sigil","name":"bar"}]}, ]
      [ "#{joiner}Super#{joiner}cali#{joiner}fragilistic#{joiner}expialidocious", {"type":"Literal","x-subtype":"absolute-route","raw":"/Super/cali/fragilistic/expialidocious","value":[{"type":"Identifier","x-subtype":"identifier-without-sigil","name":"Super"},{"type":"Identifier","x-subtype":"identifier-without-sigil","name":"cali"},{"type":"Identifier","x-subtype":"identifier-without-sigil","name":"fragilistic"},{"type":"Identifier","x-subtype":"identifier-without-sigil","name":"expialidocious"}]}, ]
      [ "#{joiner}abc#{joiner}def", {"type":"Literal","x-subtype":"absolute-route","raw":"/abc/def","value":[{"type":"Identifier","x-subtype":"identifier-without-sigil","name":"abc"},{"type":"Identifier","x-subtype":"identifier-without-sigil","name":"def"}]}, ]
      ]
    #.......................................................................................................
    for [ probe, matcher, ] in probes_and_matchers
      result = ƒ.new._delete_grammar_references G.route.run probe
      # debug JSON.stringify G.route.run probe
      test.eq result, matcher

  #---------------------------------------------------------------------------------------------------------
  'route: accepts crumbs with sigils': ( test ) ->
    ### TAINT test will fail for Unicode 32bit code points ###
    G       = @
    $       = G.$
    joiner  = $[ 'crumb/joiner' ]
    probes_and_matchers  = [
      [ "!abc#{joiner}def", {"type":"Literal","x-subtype":"relative-route","raw":"!abc/def","value":[{"type":"Identifier","x-subtype":"identifier-with-sigil","x-sigil":"!","name":"!abc"},{"type":"Identifier","x-subtype":"identifier-without-sigil","name":"def"}]}, ]
      [ "foo#{joiner}%bar", {"type":"Literal","x-subtype":"relative-route","raw":"foo/%bar","value":[{"type":"Identifier","x-subtype":"identifier-without-sigil","name":"foo"},{"type":"Identifier","x-subtype":"identifier-with-sigil","x-sigil":"%","name":"%bar"}]}, ]
      [ "Super#{joiner}_cali#{joiner}fragilistic#{joiner}expialidocious", {"type":"Literal","x-subtype":"relative-route","raw":"Super/_cali/fragilistic/expialidocious","value":[{"type":"Identifier","x-subtype":"identifier-without-sigil","name":"Super"},{"type":"Identifier","x-subtype":"identifier-with-sigil","x-sigil":"_","name":"_cali"},{"type":"Identifier","x-subtype":"identifier-without-sigil","name":"fragilistic"},{"type":"Identifier","x-subtype":"identifier-without-sigil","name":"expialidocious"}]}, ]
      [ "#{joiner}abc#{joiner}~def", {"type":"Literal","x-subtype":"absolute-route","raw":"/abc/~def","value":[{"type":"Identifier","x-subtype":"identifier-without-sigil","name":"abc"},{"type":"Identifier","x-subtype":"identifier-with-sigil","x-sigil":"~","name":"~def"}]}, ]
      ]
    #.......................................................................................................
    for [ probe, matcher, ] in probes_and_matchers
      result = ƒ.new._delete_grammar_references G.route.run probe
      debug JSON.stringify result
      test.eq result, matcher

  # #=========================================================================================================
  # # TRANSLATORS
  # #---------------------------------------------------------------------------------------------------------
  # 'as.coffee: render relative route as CoffeeScript': ( test ) ->
  #   G       = @
  #   $       = G.$
  #   probes_and_matchers = [
  #     [ """foo/bar/!baz""", "$FM[ 'scope' ][ 'foo' ][ 'bar' ][ '!baz' ]" ]
  #     ]
  #   for [ probe, matcher, ] in probes_and_matchers
  #     node    = G.route.run probe
  #     result  = ( G.as.coffee node )[ 'target' ]
  #     # debug JSON.stringify result
  #     test.eq result, matcher

  # #---------------------------------------------------------------------------------------------------------
  # 'as.coffee: render absolute route as CoffeeScript': ( test ) ->
  #   G       = @
  #   $       = G.$
  #   probes_and_matchers = [
  #     [ """/foo/bar/!baz""", "$FM[ 'global' ][ 'foo' ][ 'bar' ][ '!baz' ]" ]
  #     ]
  #   for [ probe, matcher, ] in probes_and_matchers
  #     node    = G.route.run probe
  #     result  = ( G.as.coffee node )[ 'target' ]
  #     # debug JSON.stringify result
  #     test.eq result, matcher


  # #---------------------------------------------------------------------------------------------------------
  # 'as.js: render relative route as JavaScript': ( test ) ->
  #   G       = @
  #   $       = G.$
  #   probes_and_matchers = [
  #     [ """foo/bar/!baz""", "$FM['scope']['foo']['bar']['!baz'];\n" ]
  #     ]
  #   for [ probe, matcher, ] in probes_and_matchers
  #     node    = G.route.run probe
  #     result  = ( G.as.js node )[ 'target' ]
  #     # debug JSON.stringify result
  #     test.eq result, matcher

  # #---------------------------------------------------------------------------------------------------------
  # 'as.standard: standardize relative route': ( test ) ->
  #   G       = @
  #   $       = G.$
  #   probes_and_matchers = [
  #     [ """foo/bar/!baz""", {"type":"Program","body":[{"type":"ExpressionStatement","expression":{"type":"MemberExpression","computed":true,"object":{"type":"MemberExpression","computed":true,"object":{"type":"MemberExpression","computed":true,"object":{"type":"MemberExpression","computed":true,"object":{"type":"Identifier","name":"$FM"},"property":{"type":"Literal","value":"scope","raw":"'scope'"}},"property":{"type":"Literal","value":"foo","raw":"'foo'"}},"property":{"type":"Literal","value":"bar","raw":"'bar'"}},"property":{"type":"Literal","value":"!baz","raw":"'!baz'"}}}]} ]
  #     ]
  #   for [ probe, matcher, ] in probes_and_matchers
  #     node    = G.route.run probe
  #     result  = G.as.standard node
  #     # debug JSON.stringify result
  #     test.eq result, matcher

  # #---------------------------------------------------------------------------------------------------------
  # 'as.js: render absolute route as JavaScript': ( test ) ->
  #   G       = @
  #   $       = G.$
  #   probes_and_matchers = [
  #     [ """/foo/bar/!baz""", "$FM['global']['foo']['bar']['!baz'];\n" ]
  #     ]
  #   for [ probe, matcher, ] in probes_and_matchers
  #     node    = G.route.run probe
  #     result  = ( G.as.js node )[ 'target' ]
  #     # debug JSON.stringify result
  #     test.eq result, matcher

  # #---------------------------------------------------------------------------------------------------------
  # 'as.standard: standardize absolute route': ( test ) ->
  #   G       = @
  #   $       = G.$
  #   probes_and_matchers = [
  #     [ """/foo/bar/!baz""", {"type":"Program","body":[{"type":"ExpressionStatement","expression":{"type":"MemberExpression","computed":true,"object":{"type":"MemberExpression","computed":true,"object":{"type":"MemberExpression","computed":true,"object":{"type":"MemberExpression","computed":true,"object":{"type":"Identifier","name":"$FM"},"property":{"type":"Literal","value":"global","raw":"'global'"}},"property":{"type":"Literal","value":"foo","raw":"'foo'"}},"property":{"type":"Literal","value":"bar","raw":"'bar'"}},"property":{"type":"Literal","value":"!baz","raw":"'!baz'"}}}]} ]
  #     ]
  #   for [ probe, matcher, ] in probes_and_matchers
  #     node    = G.route.run probe
  #     result  = G.as.standard node
  #     # debug JSON.stringify result
  #     test.eq result, matcher
