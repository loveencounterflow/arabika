
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

  #.........................................................................................................
  ### Names: ###
  ### Leading character in names (excluding sigils): ###
  'name-first-chr':     XRE '\\p{L}'
  ### Trailing characters in names: ###
  'name-trailing-chrs': XRE '(?:-|\\p{L}|\\d)*'
  ### Character used to form URL-like routes out of crumbs: ###
  'crumbs-joiner':       '/'
  ### Sigils may start and classify simple names: ###
  'sigils':
    '@':        'attribute' # ??? used for `this`
    '~':        'system'
    '.':        'hidden'
    '_':        'private'
    # '$':        'special' # used for interpolation!
    '%':        'cached'
    '!':        'attention'
    # '°':        ''
    # '^':        ''



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


#===========================================================================================================
# APPLY NEW TO MODULE
#-----------------------------------------------------------------------------------------------------------
### Run `@$new` to make `@` (`this`) an instance of this grammar with default options: ###
@$new @, null


#===========================================================================================================
@$TESTS =
#-----------------------------------------------------------------------------------------------------------

  #---------------------------------------------------------------------------------------------------------
  '$name_first_chr: matches first character of names': ( test ) ->
    probes = [ 'a', 'A', '𠀁',  ]
    for probe in probes
      test.eq ( @$name_first_chr.run probe ), probe

  #---------------------------------------------------------------------------------------------------------
  '$name_trailing_chrs: matches trailing characters of names': ( test ) ->
    probes = [ 'abc', 'abc-def', 'abc-def-45',  ]
    for probe in probes
      # whisper probe
      test.eq ( @$name_trailing_chrs.run probe ), probe

  #---------------------------------------------------------------------------------------------------------
  '$name: matches names': ( test ) ->
    probes = [ 'n', 'n0', 'readable-names', 'foo-32', ]
    for probe in probes
      # whisper probe
      test.eq ( @$name.run probe ), probe

  #---------------------------------------------------------------------------------------------------------
  '$name: matches names with sigils': ( test ) ->
    probes = [ '@n', '%n0', '_readable-names', '.foo-32', '~isa', ]
    for probe in probes
      # whisper probe
      test.eq ( @$name.run probe ), probe

  #---------------------------------------------------------------------------------------------------------
  '$name: rejects non-names': ( test ) ->
    probes = [ '034', '-/-', '()', '؟?', ]
    for probe in probes
      # whisper probe
      test.throws ( => @$name.run probe ), /Expected/


