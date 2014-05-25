








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

show_matches = yes
show_matches = no
#-----------------------------------------------------------------------------------------------------------
### TAINT this or similar helper to be part of FlowMatic ###
show = ( name, state ) ->
  if show_matches
    whisper "matching: #{name}", rpr state[ 'internal' ][ 'text' ][ state.pos() ... state.endpos() ]
  return null

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
    show 'name', state
    ƒ.new.x_identifier_with_sigil match[ 0 ], match[ 1 ] + match[ 2 ]
  R = R.describe 'identifier-with-sigil'
  return R

#-----------------------------------------------------------------------------------------------------------
@$new.identifier_without_sigil = ( G, $ ) ->
  R = ƒ.seq ( -> G.$identifier_first_chr ), ( -> G.$identifier_trailing_chrs )
  R = R.onMatch ( match, state ) ->
    show '$name', state
    ƒ.new.x_identifier_without_sigil match[ 0 ] + match[ 1 ]
  R = R.describe 'name-without-sigil'
  return R

#-----------------------------------------------------------------------------------------------------------
@$new.identifier = ( G, $ ) ->
  R = ƒ.or ( -> G.identifier_with_sigil ), ( -> G.identifier_without_sigil )
  R = R.describe 'identifier'
  return R

#-----------------------------------------------------------------------------------------------------------
@$new.$crumb = ( G, $ ) ->
  # R = ƒ.seq ( ƒ.optional -> G.$sigil ), ( -> G.$identifier_first_chr ), ( -> G.$identifier_trailing_chrs )
  # R = R.onMatch ( match ) -> match.join ''
  # R = R.describe 'name'
  # return R


#===========================================================================================================
# ROUTES
#-----------------------------------------------------------------------------------------------------------
@$new.route = ( G, $ ) ->
  R = ƒ.repeatSeparated ( -> G.identifier ), $[ 'crumb/joiner' ]
  R = R.onMatch ( match ) ->
    whisper match
    ƒ.new.x_route ( match.join $[ 'crumb/joiner' ] ), match
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
    return ƒ.new.x_symbol mark, mark + identifier, identifier
  return R


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
      test.eq ( G.$identifier_first_chr.run probe ), probe

  #---------------------------------------------------------------------------------------------------------
  '$identifier_trailing_chrs: matches trailing characters of names': ( test ) ->
    G = @
    $ = G.$
    probes = [ 'abc', 'abc-def', 'abc-def-45',  ]
    for probe in probes
      # whisper probe
      test.eq ( G.$identifier_trailing_chrs.run probe ), probe

  #---------------------------------------------------------------------------------------------------------
  'identifier: matches identifiers': ( test ) ->
    G = @
    $ = G.$
    probes_and_results = [
      [ 'n', {"type":"Identifier","x-subtype":"identifier-without-sigil","name":"n"} ]
      [ 'n0', {"type":"Identifier","x-subtype":"identifier-without-sigil","name":"n0"} ]
      [ 'readable-names', {"type":"Identifier","x-subtype":"identifier-without-sigil","name":"readable-names"} ]
      [ 'foo-32', {"type":"Identifier","x-subtype":"identifier-without-sigil","name":"foo-32"} ]
      ]
    for [ probe, result, ] in probes_and_results
      # debug probe, JSON.stringify G.identifier.run probe
      test.eq ( G.identifier.run probe ), result

  #---------------------------------------------------------------------------------------------------------
  'identifier: matches identifiers with sigils': ( test ) ->
    G = @
    $ = G.$
    probes_and_results = [
      [ '~n', {"type":"Identifier","x-subtype":"identifier-with-sigil","x-sigil":"~","name":"n"} ]
      [ '.n0', {"type":"Identifier","x-subtype":"identifier-with-sigil","x-sigil":".","name":"n0"} ]
      [ '_readable-names', {"type":"Identifier","x-subtype":"identifier-with-sigil","x-sigil":"_","name":"readable-names"} ]
      [ '%foo-32', {"type":"Identifier","x-subtype":"identifier-with-sigil","x-sigil":"%","name":"foo-32"} ]
      [ '!foo-32', {"type":"Identifier","x-subtype":"identifier-with-sigil","x-sigil":"!","name":"foo-32"} ]
      ]
    for [ probe, result, ] in probes_and_results
      # debug probe, JSON.stringify G.identifier.run probe
      test.eq ( G.identifier.run probe ), result

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
    probes_and_results = [
      [ "#{mark}x", {"type":"Literal","x-subtype":"symbol","x-mark":":","raw":":x","value":"x"}, ]
      [ "#{mark}foo", {"type":"Literal","x-subtype":"symbol","x-mark":":","raw":":foo","value":"foo"}, ]
      [ "#{mark}Supercalifragilisticexpialidocious", {"type":"Literal","x-subtype":"symbol","x-mark":":","raw":":Supercalifragilisticexpialidocious","value":"Supercalifragilisticexpialidocious"}, ]
    ]
    #.......................................................................................................
    for [ probe, result, ] in probes_and_results
      # debug JSON.stringify G.symbol.run probe
      test.eq ( G.symbol.run probe ), result

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
    probes_and_results  = [
      [ "abc",      [ "abc", ] ]
      [ "國畫很美",     [ "國畫很美", ] ]
      ]
    #.......................................................................................................
    for [ probe, result, ] in probes_and_results
      debug JSON.stringify G.route.run probe
      # test.eq ( G.route.run probe ), result

  #---------------------------------------------------------------------------------------------------------
  'route: accepts crumbs separated by crumb joiners': ( test ) ->
    ### TAINT test will fail for Unicode 32bit code points ###
    G       = @
    $       = G.$
    joiner  = $[ 'crumbs-joiner' ]
    probes_and_results  = [
      [ "abc#{joiner}def", [ "abc", "def" ], ]
      [ "foo#{joiner}bar", [ "foo", "bar" ], ]
      [ "Super#{joiner}cali#{joiner}fragilistic#{joiner}expialidocious", ["Super", "cali", "fragilistic", "expialidocious" ], ]
      # [ "abc#{joiner}def#{joiner}", [ "abc", "def" ], ]
      [ "#{joiner}abc#{joiner}def", [ "abc", "def" ], ]
      ]
    #.......................................................................................................
    for [ probe, result, ] in probes_and_results
      debug JSON.stringify G.route.run probe
      test.eq ( G.route.run probe ), result

