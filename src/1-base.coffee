

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
π                         = require 'coffeenode-packrattle'
NEW                       = require './NEW'
WS                        = require './3-ws'
NUMBER                    = require './4-number'
TEXT                      = require './2-text'
CHR                       = require './8-character'
XRE                       = require './9-xre'


#-----------------------------------------------------------------------------------------------------------
@$ =
  'symbol-sigil':   ':'
  'use-keyword':    'use'

#-----------------------------------------------------------------------------------------------------------
### TAINT `π.alt` is an expedient here ###
@$_symbol_sigil    = π.alt => π.string @$[ 'symbol-sigil' ]

#-----------------------------------------------------------------------------------------------------------
@symbol           = ( π.seq @$_symbol_sigil, WS.nws )
  .onMatch ( match ) =>
    [ sigil, { raw, value } ] = match
    return NEW.literal 'symbol', sigil + raw, value

#-----------------------------------------------------------------------------------------------------------
### TAINT `π.alt` is an expedient here ###
@$_use_keyword     = π.alt => π.string @$[ 'use-keyword' ]

#-----------------------------------------------------------------------------------------------------------
@use_argument     = π.alt @symbol, NUMBER.digits, TEXT.literal

#-----------------------------------------------------------------------------------------------------------
@use_statement    = ( π.seq @$_use_keyword, WS.ilws, @use_argument )
  .onMatch ( match ) =>
    [ keyword, { raw, value } ] = match
    return NEW.x_use_statement keyword, raw


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
      test.eq ( @symbol.run probe ), ( NEW.literal 'symbol', probe, probe[ 1 .. ] )

  #---------------------------------------------------------------------------------------------------------
  'use_argument: accepts symbols, digits, strings': ( test ) ->
    sigil = @$[ 'symbol-sigil' ]
    probes_and_results = [
      [ "#{sigil}x",      NEW.literal 'symbol', "#{sigil}x",   "x" ]
      [ "#{sigil}foo",    NEW.literal 'symbol', "#{sigil}foo", "foo" ]
      [ "12349876",       NEW.literal 'digits', "12349876", "12349876" ]
      [ "'some text'",    NEW.literal 'text', "'some text'", "some text" ]
      [ '"other text"' ,  NEW.literal 'text', '"other text"', 'other text' ]
      ]
    #.......................................................................................................
    for [ probe, result, ] in probes_and_results
      test.eq ( @use_argument.run probe ), result

  #---------------------------------------------------------------------------------------------------------
  'use_statement: accepts symbols, digits, strings': ( test ) ->
    sigil   = @$[ 'symbol-sigil' ]
    keyword = @$[ 'use-keyword' ]
    probes_and_results = [
      [ "use #{sigil}x",      NEW.x_use_statement keyword, "#{sigil}x",   "x" ]
      [ "use #{sigil}foo",    NEW.x_use_statement keyword, "#{sigil}foo", "foo" ]
      [ "use 12349876",       NEW.x_use_statement keyword, "12349876", "12349876" ]
      [ "use 'some text'",    NEW.x_use_statement keyword, "'some text'", "some text" ]
      [ 'use "other text"' ,  NEW.x_use_statement keyword, '"other text"', 'other text' ]
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










