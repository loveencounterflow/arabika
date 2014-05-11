
############################################################################################################
π                         = require 'coffeenode-packrattle'
NEW                       = require './NEW'
@TESTS                    = {}
test                      = NEW.test()


#-----------------------------------------------------------------------------------------------------------
@digits = ( π.regex /[0-9]+/ )
  .onMatch ( match ) => NEW.literal match[ 0 ], match[ 0 ]
#...........................................................................................................
@TESTS[ 'digits: parses sequences of ASCII digits'] = ->
  for probe in """0 12 7 1928374 080""".split /\s+/
    test.eq ( @digits.run probe ), ( NEW.literal probe, probe )
#...........................................................................................................
@TESTS[ 'digits: does not parse sequences with non-digits (1)'] = ->
  for probe in """0x 1q2 7# 192+8374 08.0""".split /\s+/
    test.throws ( => @digits.run probe ), /Expected end/
#...........................................................................................................
@TESTS[ 'digits: does not parse sequences with non-digits (2)'] = ->
  for probe in """q192 +3 -42""".split /\s+/
    test.throws ( => @digits.run probe ), /Expected \/\[0-9\]\+\//

#-----------------------------------------------------------------------------------------------------------
### TAINT `π.alt` is an expedient here ###
@integer = ( π.alt @digits )
  .onMatch ( match ) => match[ 'value' ] = parseInt match[ 'raw' ], 10; return match
#...........................................................................................................
@TESTS[ 'integer: parses sequences of ASCII digits'] = ->
  for probe in """0 12 7 1928374 080""".split /\s+/
    test.eq ( @integer.run probe ), ( NEW.literal probe, parseInt probe, 10 )

#-----------------------------------------------------------------------------------------------------------
@number = π.alt @digits

  # assert  = require 'assert'
  # _       = @
  # #---------------------------------------------------------------------------------------------------------
  # @_TESTS.digits = =>
  #   assert.deepEqual 1, 1



