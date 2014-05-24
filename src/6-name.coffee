








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

#-----------------------------------------------------------------------------------------------------------
@$ =

  #---------------------------------------------------------------------------------------------------------
  ### Names: ###

  #.........................................................................................................
  ### Leading character in names (excluding sigils): ###
  'name-first-chr':     XRE '\\p{L}'

  #.........................................................................................................
  ### Trailing characters in names: ###
  'name-trailing-chrs': XRE '(?:-|\\p{L}|\\d)*'

  #.........................................................................................................
  ### Character used to form URL-like routes out of crumbs: ###
  'crumbs-joiner':       '/'

  #---------------------------------------------------------------------------------------------------------
  ### Sigils: ###

  #.........................................................................................................
  ### Sigils may start and classify simple names: ###
  'sigils':
    # '$':        'special' # used for interpolation!
    # '°':        ''
    # '^':        ''
    '@':        'attribute' # ??? used for `this`
    '~':        'system'
    '.':        'hidden'
    '_':        'private'
    '%':        'cached'
    '!':        'attention'


  #.........................................................................................................
  ### Marks are like sigils, but with slightly different semantics. ###
  'symbols-mark':  ':'


#===========================================================================================================
# NAMES
#-----------------------------------------------------------------------------------------------------------
@$new.$name_first_chr = ( G, $ ) ->
  R = ƒ.regex $[ 'name-first-chr' ]
  R = R.onMatch ( match ) -> match[ 0 ]
  R = R.describe 'first character of name'
  return R

#-----------------------------------------------------------------------------------------------------------
@$new.$name_trailing_chrs = ( G, $ ) ->
  R = ƒ.regex $[ 'name-trailing-chrs' ]
  R = R.onMatch ( match ) -> match[ 0 ]
  R = R.describe 'trailing characters of name'
  return R

#-----------------------------------------------------------------------------------------------------------
@$new.$name_sigil = ( G, $ ) ->
  sigils = ( XRE.$esc key for key of $[ 'sigils'] ).join ''
  R = ƒ.regex XRE "[#{sigils}]"
  R = R.onMatch ( match ) -> match[ 0 ]
  R = R.describe 'name'
  return R

# #-----------------------------------------------------------------------------------------------------------
# @$new.$name = ( G, $ ) ->
#   sigils = ( XRE.$esc key for key of $[ 'sigils'] ).join ''
#   R = ƒ.seq ( XRE "[#{sigils}]?" ), ( -> G.$name_first_chr ), ( -> G.$name_trailing_chrs )
#   R = R.onMatch ( match ) -> match.join ''
#   R = R.describe 'name'
#   return R

#-----------------------------------------------------------------------------------------------------------
@$new.$name = ( G, $ ) ->
  R = ƒ.seq ( ƒ.optional -> G.$name_sigil ), ( -> G.$name_first_chr ), ( -> G.$name_trailing_chrs )
  R = R.onMatch ( match ) -> match.join ''
  R = R.describe 'name'
  return R

#-----------------------------------------------------------------------------------------------------------
@$new.$crumb = ( G, $ ) ->
  # R = ƒ.seq ( ƒ.optional -> G.$name_sigil ), ( -> G.$name_first_chr ), ( -> G.$name_trailing_chrs )
  # R = R.onMatch ( match ) -> match.join ''
  # R = R.describe 'name'
  # return R


#===========================================================================================================
# ROUTES
#-----------------------------------------------------------------------------------------------------------
@$new.$route = ( G, $ ) ->
  R = ƒ.repeatSeparated ( -> G.$name ), $[ 'crumbs-joiner' ]
  # R = R.onMatch ( match ) -> match.join ''
  R = R.describe 'route'
  return R


#===========================================================================================================
# SYMBOLS
### TAINT `ƒ.or` is an expedient here ###
# @$_symbol_sigil    = ƒ.or => ƒ.string @$[ 'symbol-sigil' ]

#-----------------------------------------------------------------------------------------------------------
@$new.$symbol = ( G, $ ) ->
  R = ƒ.seq $[ 'symbols-mark' ], ( -> G.$name )
  R = R.onMatch ( match ) -> match.join ''
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
  '$name_first_chr: matches first character of names': ( test ) ->
    G = @
    $ = G.$
    probes = [ 'a', 'A', '𠀁',  ]
    for probe in probes
      test.eq ( G.$name_first_chr.run probe ), probe

  #---------------------------------------------------------------------------------------------------------
  '$name_trailing_chrs: matches trailing characters of names': ( test ) ->
    G = @
    $ = G.$
    probes = [ 'abc', 'abc-def', 'abc-def-45',  ]
    for probe in probes
      # whisper probe
      test.eq ( G.$name_trailing_chrs.run probe ), probe

  #---------------------------------------------------------------------------------------------------------
  '$name: matches names': ( test ) ->
    G = @
    $ = G.$
    probes = [ 'n', 'n0', 'readable-names', 'foo-32', ]
    for probe in probes
      # whisper probe
      test.eq ( G.$name.run probe ), probe

  #---------------------------------------------------------------------------------------------------------
  '$name: matches names with sigils': ( test ) ->
    G = @
    $ = G.$
    probes = [ '@n', '%n0', '_readable-names', '.foo-32', '~isa', ]
    for probe in probes
      # whisper probe
      test.eq ( G.$name.run probe ), probe

  #---------------------------------------------------------------------------------------------------------
  '$name: rejects non-names': ( test ) ->
    G = @
    $ = G.$
    probes = [ '034', '-/-', '()', '؟?', ]
    for probe in probes
      # whisper probe
      test.throws ( => G.$name.run probe ), /Expected/


  #=========================================================================================================
  # SYMBOLS
  #---------------------------------------------------------------------------------------------------------
  '$[ "symbols-mark" ]: is a single character': ( test ) ->
    ### TAINT test will fail for Unicode 32bit code points ###
    G = @
    $ = G.$
    TYPES = require 'coffeenode-types'
    test.ok TYPES.isa_text $[ 'symbols-mark' ]
    test.ok $[ 'symbols-mark' ].length is 1

  #---------------------------------------------------------------------------------------------------------
  '$symbol: accepts sequences of symbols-mark, name chr': ( test ) ->
    G       = @
    $       = G.$
    mark    = @$[ 'symbols-mark' ]
    probes  = [
      "#{mark}x"
      "#{mark}foo"
      "#{mark}Supercalifragilisticexpialidocious" ]
    #.......................................................................................................
    for probe in probes
      test.eq ( G.$symbol.run probe ), probe

  #---------------------------------------------------------------------------------------------------------
  '$symbol: rejects names with whitespace': ( test ) ->
    G       = @
    $       = G.$
    mark    = @$[ 'symbols-mark' ]
    probes  = [
      "#{mark}xxx xxx"
      "#{mark}foo\tbar"
      "#{mark}Super/cali/fragilistic/expialidocious" ]
    #.......................................................................................................
    for probe in probes
      test.throws ( -> G.$symbol.run probe ), /Expected/


  #=========================================================================================================
  # ROUTES
  #---------------------------------------------------------------------------------------------------------
  '$route: accepts single name': ( test ) ->
    ### TAINT test will fail for Unicode 32bit code points ###
    G = @
    $ = G.$
    probes_and_results  = [
      [ "abc",      [ "abc", ] ]
      [ "國畫很美",     [ "國畫很美", ] ]
      ]
    #.......................................................................................................
    for [ probe, result, ] in probes_and_results
      test.eq ( G.$route.run probe ), result

  #---------------------------------------------------------------------------------------------------------
  '$route: accepts crumbs separated by crumb joiners': ( test ) ->
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
      debug G.$route.run probe
      test.eq ( G.$route.run probe ), result

