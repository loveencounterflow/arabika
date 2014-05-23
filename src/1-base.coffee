

############################################################################################################
TRM                       = require 'coffeenode-trm'
rpr                       = TRM.rpr.bind TRM
badge                     = '﴾1-base﴿'
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
$new                      = ƒ.new
CHR                       = require './3-chr'
NUMBER                    = require './4-number'
TEXT                      = require './2-text'
XRE                       = require './9-xre'


#-----------------------------------------------------------------------------------------------------------
@$ =
  'symbol-sigil':   ':'
  'use-keyword':    'use'

#-----------------------------------------------------------------------------------------------------------
### TAINT `ƒ.or` is an expedient here ###
@$_symbol_sigil    = ƒ.or => ƒ.string @$[ 'symbol-sigil' ]

#-----------------------------------------------------------------------------------------------------------
@symbol           = ( ƒ.seq @$_symbol_sigil, CHR.nws )
  .onMatch ( match ) =>
    [ sigil, { raw, value } ] = match
    return $new.literal 'symbol', sigil + raw, value

#-----------------------------------------------------------------------------------------------------------
### TAINT `ƒ.or` is an expedient here ###
@$_use_keyword     = ƒ.or => ƒ.string @$[ 'use-keyword' ]

#-----------------------------------------------------------------------------------------------------------
@use_argument     = ƒ.or @symbol, NUMBER.digits, TEXT.literal

#-----------------------------------------------------------------------------------------------------------
@use_statement    = ( ƒ.seq @$_use_keyword, CHR.ilws, @use_argument )
  .onMatch ( match ) =>
    [ keyword, { raw, value } ] = match
    return $new.x_use_statement keyword, raw


#===========================================================================================================
# TESTS
#-----------------------------------------------------------------------------------------------------------
@$TESTS =

  #---------------------------------------------------------------------------------------------------------
  '_symbol_sigil: is a single character': ( test ) ->
    TYPES = require 'coffeenode-types'
    test.ok TYPES.isa_text @$[ 'symbol-sigil' ]
    test.ok @$[ 'symbol-sigil' ].length is 1

  #---------------------------------------------------------------------------------------------------------
  'symbol: accepts sequences of [ symbol-sigil, nws ]': ( test ) ->
    sigil = @$[ 'symbol-sigil' ]
    probes = [
      "#{sigil}x"
      "#{sigil}foo"
      "#{sigil}Supercalifragilisticexpialidocious" ]
    #.......................................................................................................
    for probe in probes
      test.eq ( @symbol.run probe ), ( $new.literal 'symbol', probe, probe[ 1 .. ] )

  #---------------------------------------------------------------------------------------------------------
  'use_argument: accepts symbols, digits, strings': ( test ) ->
    sigil = @$[ 'symbol-sigil' ]
    probes_and_results = [
      [ "#{sigil}x",      $new.literal 'symbol', "#{sigil}x",   "x" ]
      [ "#{sigil}foo",    $new.literal 'symbol', "#{sigil}foo", "foo" ]
      [ "12349876",       $new.literal 'digits', "12349876", "12349876" ]
      [ "'some text'",    $new.literal 'text', "'some text'", "some text" ]
      [ '"other text"' ,  $new.literal 'text', '"other text"', 'other text' ]
      ]
    #.......................................................................................................
    for [ probe, result, ] in probes_and_results
      test.eq ( @use_argument.run probe ), result

  #---------------------------------------------------------------------------------------------------------
  'use_statement: accepts symbols, digits, strings': ( test ) ->
    sigil   = @$[ 'symbol-sigil' ]
    keyword = @$[ 'use-keyword' ]
    probes_and_results = [
      [ "use #{sigil}x",      $new.x_use_statement keyword, "#{sigil}x",   "x" ]
      [ "use #{sigil}foo",    $new.x_use_statement keyword, "#{sigil}foo", "foo" ]
      [ "use 12349876",       $new.x_use_statement keyword, "12349876", "12349876" ]
      [ "use 'some text'",    $new.x_use_statement keyword, "'some text'", "some text" ]
      [ 'use "other text"' ,  $new.x_use_statement keyword, '"other text"', 'other text' ]
      ]
    #.......................................................................................................
    for [ probe, result, ] in probes_and_results
      test.eq ( @use_statement.run probe ), result

  #---------------------------------------------------------------------------------------------------------
  'use_statement: compilation to JS': ( test ) ->
    sigil   = @$[ 'symbol-sigil' ]
    keyword = @$[ 'use-keyword' ]
    probes_and_results = [
      [ "use #{sigil}x",      """/* use ':x' */"""            ]
      [ "use #{sigil}foo",    """/* use ':foo' */"""          ]
      [ "use 12349876",       """/* use '12349876' */"""      ]
      [ "use 'some text'",    """/* use '\\'some text\\'' */""" ]
      [ 'use "other text"' ,  """/* use '"other text"' */"""  ]
      ]
    #.......................................................................................................
    for [ probe, result, ] in probes_and_results
      test.eq ( test.as_js @use_statement.run probe ), result










