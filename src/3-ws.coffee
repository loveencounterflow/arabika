
############################################################################################################
TRM                       = require 'coffeenode-trm'
rpr                       = TRM.rpr.bind TRM
badge                     = '﴾3-ws﴿'
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
### Linear WhiteSpace ###
@lws = ( π.regex /\x20+/ )
  .onMatch ( match ) -> return NEW.literal 'lws', match[ 0 ], match[ 0 ]

#-----------------------------------------------------------------------------------------------------------
### invisible LWS ###
@ilws = π.drop π.regex /\x20+/

#-----------------------------------------------------------------------------------------------------------
### no WhiteSpace ###
@nws = ( π.regex /[^\s\x85]+/ )
### TAINT better way to chain methods? ###
@nws = @nws.onMatch ( match ) => NEW.literal 'nws', match[ 0 ], match[ 0 ]
@nws = @nws.describe "no-whitespace"

#===========================================================================================================
# TESTS
#-----------------------------------------------------------------------------------------------------------
@TESTS =

  #---------------------------------------------------------------------------------------------------------
  'nws: rejects sequences defined as whitespace in Unicode 6.2': ( test ) ->
    errors  = []
    probes  = [
      '\u0009', '\u000A', '\u000B', '\u000C', '\u000D', '\u0020', '\u0085', '\u00A0', '\u1680', '\u2000',
      '\u2001', '\u2002', '\u2003', '\u2004', '\u2005', '\u2006', '\u2007', '\u2008', '\u2009', '\u200A',
      '\u2028', '\u2029', '\u202F', '\u205F', '\u3000', ]
    #.......................................................................................................
    for probe in probes
      try
        @nws.run probe
      catch error
        throw error unless error[ 'message' ] is 'Expected no-whitespace'
        continue
      errors.push probe
    #.......................................................................................................
    if errors.length isnt 0
      errors_txt = ( rpr text for text in errors ).join ', '
      throw new Error "wrongly recognized as non-whitespace: #{errors_txt}"

  #---------------------------------------------------------------------------------------------------------
  'nws: accepts sequences of non-whitespace characters': ( test ) ->
    probes = [
      "aeiou"
      "123/)zRT§"
      "中國皇帝🚂" ]
    #.......................................................................................................
    for probe in probes
      test.eq ( @nws.run probe ), ( NEW.literal 'nws', probe, probe )

  #---------------------------------------------------------------------------------------------------------
  'lws: accepts sequences of U+0020': ( test ) ->
    probes = [ ' ', '        ', ]
    for probe in probes
      test.eq ( @lws.run probe ), ( NEW.literal 'lws', probe, probe )

  #---------------------------------------------------------------------------------------------------------
  'ilws: accepts and drops sequences of U+0020': ( test ) ->
    probes = [ ' ', '        ', ]
    for probe in probes
      test.eq ( @ilws.run probe ), null


