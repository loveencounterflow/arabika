
############################################################################################################
# njs_util                  = require 'util'
# njs_path                  = require 'path'
# njs_fs                    = require 'fs'
#...........................................................................................................
TRM                       = require 'coffeenode-trm'
rpr                       = TRM.rpr.bind TRM
badge                     = '﴾4-number﴿'
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


#-----------------------------------------------------------------------------------------------------------
@digits = ( π.regex /[0-9]+/ )
  .onMatch ( match ) => NEW.literal 'digits', match[ 0 ], match[ 0 ]

#-----------------------------------------------------------------------------------------------------------
### TAINT `π.alt` is an expedient here ###
@integer = ( π.alt @digits )
  .onMatch ( match ) =>
    match[ 'x-subtype'  ] = 'integer'
    match[ 'value'      ] = parseInt match[ 'raw' ], 10
    return match

#-----------------------------------------------------------------------------------------------------------
@literal = π.alt @integer



#===========================================================================================================
# TESTS
#-----------------------------------------------------------------------------------------------------------
@$TESTS =

  #---------------------------------------------------------------------------------------------------------
  'digits: parses sequences of ASCII digits': ( test ) ->
    for probe in """0 12 7 1928374 080""".split /\s+/
      test.eq ( @digits.run probe ), ( NEW.literal 'digits', probe, probe )

  #---------------------------------------------------------------------------------------------------------
  'digits: does not parse sequences with non-digits (1)': ( test ) ->
    for probe in """0x 1q2 7# 192+8374 08.0""".split /\s+/
      test.throws ( => @digits.run probe ), /Expected end/

  #---------------------------------------------------------------------------------------------------------
  'digits: does not parse sequences with non-digits (2)': ( test ) ->
    for probe in """q192 +3 -42""".split /\s+/
      test.throws ( => @digits.run probe ), /Expected \/\[0-9\]\+\//

  #---------------------------------------------------------------------------------------------------------
  'integer: parses sequences of ASCII digits': ( test ) ->
    for probe in """0 12 7 1928374 080""".split /\s+/
      test.eq ( @integer.run probe ), ( NEW.literal 'integer', probe, parseInt probe, 10 )

  #---------------------------------------------------------------------------------------------------------
  'number: recognizes integers': ( test ) ->
    for probe in """0 12 7 1928374 080""".split /\s+/
      test.eq ( @literal.run probe ), ( NEW.literal 'integer', probe, parseInt probe, 10 )

  #---------------------------------------------------------------------------------------------------------
  'number: compiles integers to JS': ( test ) ->
    probes_and_results = [
      ['0',                           '0' ]
      ['000',                         '0' ]
      ['123',                         '123' ]
      ['00000123',                    '123' ]
      ['123456789123456789123456789', '1.2345678912345679e+26' ]
      ]
    for [ probe, result, ] in probes_and_results
      test.eq ( test.as_js @literal.run probe ), result



