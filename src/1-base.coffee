

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
@$new                     = ƒ.new.new @
$new                      = ƒ.new
TEXT                      = require './2-text'
CHR                       = require './3-chr'
NUMBER                    = require './4-number'
NAME                      = require './6-name'
XRE                       = require './9-xre'


#-----------------------------------------------------------------------------------------------------------
@$ =
  'use-keyword':    'use'

#-----------------------------------------------------------------------------------------------------------
### TAINT `ƒ.or` is an expedient here ###
@$_use_keyword     = ƒ.or => ƒ.string @$[ 'use-keyword' ]

#-----------------------------------------------------------------------------------------------------------
@use_argument     = ƒ.or NAME.$symbol, NUMBER.digits, TEXT.literal

#-----------------------------------------------------------------------------------------------------------
@use_statement    = ( ƒ.seq @$_use_keyword, CHR.ilws, @use_argument )
  .onMatch ( match ) =>
    [ keyword, { raw, value } ] = match
    return ƒ.new.x_use_statement keyword, raw


#===========================================================================================================
# TESTS
#-----------------------------------------------------------------------------------------------------------
@$TESTS =

  #---------------------------------------------------------------------------------------------------------
  'use_argument: accepts symbols': ( test ) ->
    G = @
    $ = G.$
    mark = NAME.$[ 'symbols-mark' ]
    probes_and_results = [
      [ "#{mark}x",      "#{mark}x"   ]
      [ "#{mark}foo",    "#{mark}foo" ]
      ]
    #.......................................................................................................
    for [ probe, result, ] in probes_and_results
      test.eq ( @use_argument.run probe ), result

  #---------------------------------------------------------------------------------------------------------
  'use_argument: accepts digits': ( test ) ->
    G = @
    $ = G.$
    probes_and_results = [
      [ "12349876",       ƒ.new.literal 'digits', "12349876", "12349876" ]
      ]
    #.......................................................................................................
    for [ probe, result, ] in probes_and_results
      test.eq ( @use_argument.run probe ), result

  #---------------------------------------------------------------------------------------------------------
  'use_argument: accepts strings': ( test ) ->
    G = @
    $ = G.$
    probes_and_results = [
      [ "'some text'",    ƒ.new.literal 'text', "'some text'", "some text" ]
      [ '"other text"' ,  ƒ.new.literal 'text', '"other text"', 'other text' ]
      ]
    #.......................................................................................................
    for [ probe, result, ] in probes_and_results
      test.eq ( @use_argument.run probe ), result

  #---------------------------------------------------------------------------------------------------------
  'use_statement: accepts symbols, digits, strings': ( test ) ->
    G       = @
    $       = G.$
    mark    = NAME.$[ 'symbols-mark' ]
    keyword = G.$[ 'use-keyword' ]
    probes_and_results = [
      [ "use #{mark}x",       ƒ.new.x_use_statement keyword, "#{mark}x",   "x" ]
      [ "use #{mark}foo",     ƒ.new.x_use_statement keyword, "#{mark}foo", "foo" ]
      [ "use 12349876",       ƒ.new.x_use_statement keyword, "12349876", "12349876" ]
      [ "use 'some text'",    ƒ.new.x_use_statement keyword, "'some text'", "some text" ]
      [ 'use "other text"' ,  ƒ.new.x_use_statement keyword, '"other text"', 'other text' ]
      ]
    #.......................................................................................................
    for [ probe, result, ] in probes_and_results
      test.eq ( @use_statement.run probe ), result

  #---------------------------------------------------------------------------------------------------------
  'use_statement: compilation to JS': ( test ) ->
    G       = @
    $       = G.$
    mark    = NAME.$[ 'symbols-mark' ]
    keyword = G.$[ 'use-keyword' ]
    probes_and_results = [
      [ "use #{mark}x",      """/* use ':x' */"""            ]
      [ "use #{mark}foo",    """/* use ':foo' */"""          ]
      [ "use 12349876",       """/* use '12349876' */"""      ]
      [ "use 'some text'",    """/* use '\\'some text\\'' */""" ]
      [ 'use "other text"' ,  """/* use '"other text"' */"""  ]
      ]
    #.......................................................................................................
    for [ probe, result, ] in probes_and_results
      test.eq ( test.as_js @use_statement.run probe ), result










